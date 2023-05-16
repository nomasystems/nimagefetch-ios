//  Copyright © 2016 Nomasystems. All rights reserved.

#import "NImageFetch.h"

#import "NImageFetchTaskI.h"
#import "NImageFetchError.h"
#import "NImageFetchCache.h"
#import "NImageFetchMemoryCache.h"
#import "NImageFetchDecode.h"
#import "NImageFetchFileCache.h"
#import "NImageVectorDecoder.h"

@interface NImageFetchRequest ()
@property (readwrite, nonatomic) NSURLRequest *urlRequest;
@end

@implementation NImageFetchRequest

+ (instancetype)requestWithUrlRequest:(NSURLRequest*)urlRequest
{
    return [[self alloc] initWithUrlRequest:urlRequest];
}

- (instancetype)initWithUrlRequest:(NSURLRequest*)urlRequest
{
    if(self = [super init]) {
        _urlRequest = urlRequest;
        _scale = 1;
    }
    return self;
}

@end

static NImageFetch *sharedInstance;

@interface NImageFetch () <NSURLSessionDelegate>
// Queue for serializing access to task NImageFetchTaskI object properties
@property (nonatomic) dispatch_queue_t taskDispatchQueue;
// Operation queue for decoding image files (also used as the NSURLSession delegateQueue)
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSURLSession *URLSession;
@property (nonatomic, strong) NImageFetchFileCache *fileCache;
@property (nonatomic, strong) NImageFetchMemoryCache *memoryCache;
@property (readwrite, nonatomic) BOOL isMemoryCacheDeactivated;
@end

@interface NSURLResponse (NMAContentTypePdf)
- (BOOL)nma_isContentTypePDF;
@end

@implementation NImageFetch

+ (instancetype)sharedImageFetch
{
    if(sharedInstance == nil) {
        sharedInstance = [[NImageFetch alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init
{
    if(self = [super init]) {
        self.taskDispatchQueue =  dispatch_queue_create("com.nomasystems.NImageFetch.taskDispatchQueue",
                                                        dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                                QOS_CLASS_UTILITY, 0));
        
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.qualityOfService = NSQualityOfServiceUtility;
        self.operationQueue = operationQueue;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // Disable HTTP caching as we handle memory and disk caching explicitly
        configuration.URLCache = nil;
        configuration.HTTPCookieStorage = nil;
        

        NSURLSession *URLSession = [NSURLSession sessionWithConfiguration:configuration
                                                                 delegate:self
                                                            delegateQueue:operationQueue];
        self.URLSession = URLSession;

        self.memoryCache = [[NImageFetchMemoryCache alloc] init];
        self.fileCache = [[NImageFetchFileCache alloc] init];
    }
    return self;
}

#if defined(DEBUG) || defined(NOMATESTFLIGHT)

/* In DEBUG mode, blindly trust any server certificate */

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

#endif

- (void)deactivateMemoryCache
{
    self.isMemoryCacheDeactivated = YES;
    self.memoryCache = nil;
}

- (nullable id<NImageFetchTask>)fetchImageForRequest:(NImageFetchRequest*)request
                                          completion:(NImageFetchCompletion)completion
{
    NImageFetchTaskI *imageFetchTask = nil;
    NSString * memoryCacheKey = [NImageFetchCache cacheKeyForURL:request.urlRequest.URL size:request.pointSize scale:request.scale];
    
    // First check if image is in memory cache, don't create any fetch task if it is
    UIImage *imageInMemoryCache = [self.memoryCache imageForKey:memoryCacheKey];
    if(imageInMemoryCache && request.urlRequest.cachePolicy != NSURLRequestReloadIgnoringCacheData) {
        completion(imageInMemoryCache, nil, NImageFetchFlagSync);
    } else {
        imageFetchTask = [[NImageFetchTaskI alloc] initWithCompletion:completion];
        
        NSOperation *fileCacheReadOperation = [NSBlockOperation blockOperationWithBlock:^{
            if(imageFetchTask.isCancelled) return;

            UIImage *imageInFileCache = nil;
            
            NSURL *fileCacheURL = [self.fileCache cacheFileURLForURL:request.urlRequest.URL];
            
            BOOL shouldDecodeAsPdf = NO;
            imageInFileCache = [NImageFetchDecode decodeImageAtLocation:fileCacheURL
                                                              pointSize:request.pointSize
                                                                  scale:request.scale
                                                      shouldDecodeAsPdf:&shouldDecodeAsPdf];
            
            if(!imageInFileCache && shouldDecodeAsPdf) {
                // First check the disk cache for a renderered image file of the pdf with the desired size
                NSURL *prerenderedPdfFileCacheUrl = [self.fileCache cacheFileURLForRenderedPdfWithSourceURL:request.urlRequest.URL size:request.pointSize scale:request.scale];
                imageInFileCache = [NImageFetchDecode decodeImageAtLocation:prerenderedPdfFileCacheUrl pointSize:CGSizeZero scale:1 shouldDecodeAsPdf:&shouldDecodeAsPdf];

                if(!imageInFileCache) {
                    // Try to render from pdf in disk cache
                    UIImage * renderedPdfImage = [NImageVectorDecoder drawPDFfromURL:fileCacheURL targetWidthInPoints:request.pointSize.width];
                    if(renderedPdfImage) {
                        imageInFileCache = renderedPdfImage;
                        [self.fileCache saveRenderedPdfImage:renderedPdfImage size:request.pointSize scale:request.scale sourceUrl:request.urlRequest.URL];
                    }
                               }
            }
            
            if(imageInFileCache && request.urlRequest.cachePolicy != NSURLRequestReloadIgnoringCacheData) {
                [self callAsyncCompletionForImageFetchTask:imageFetchTask image:imageInFileCache error:nil];
                [self.memoryCache cacheImage:imageInFileCache forKey:memoryCacheKey];
            } else {
                // Image not in file cache, download it

                // All accesses to the task object (except completed flag and completion) must be done on the taskDispatchQueue
                dispatch_async(self.taskDispatchQueue, ^{
                    if(imageFetchTask.isCancelled) return;
                    imageFetchTask.fileCacheReadOperation = nil;
                    [self startImageFetchTask:imageFetchTask
                              downloadRequest:request
                                 fileCacheURL:fileCacheURL
                               memoryCacheKey:memoryCacheKey];
                });
            }
        }];
        
        imageFetchTask.fileCacheReadOperation = fileCacheReadOperation;
        [self.operationQueue addOperation:fileCacheReadOperation];
    }
    
    return imageFetchTask;
}

- (void)cancel:(id<NImageFetchTask>)imageFetchTask
{
    if(!imageFetchTask) {
        return;
    }
    
    NImageFetchTaskI *imageFetchTaskInternal = (NImageFetchTaskI*)imageFetchTask;
    // Some users of this function (such as NImageFetchView) are dependent on the completion block being
    // called synchronously on the main thread, so for now we need to keep the same behaviour
    if(atomic_fetch_or(&imageFetchTaskInternal->completed, true) == false) {
        imageFetchTaskInternal.completion(nil, [NImageFetchError errorWithCode:NImageFetchCancelledError url:nil underlyingError:nil statusCode:nil], 0);
        // Although NSURLSessionTask cancel is thread safe, we must call cancel on the taskDispatchQueue:
        // All accesses to the task object (except completed flag and completion) must be done on the taskDispatchQueue
        dispatch_async(self.taskDispatchQueue, ^{
            [imageFetchTaskInternal cancel];
        });
    }
}

- (id<NImageFetchTask>)fetchImageForURLRequest:(NSURLRequest *)urlRequest completion:(NImageFetchCompletion)completion
{
    NImageFetchRequest *request = [NImageFetchRequest requestWithUrlRequest:urlRequest];
    return [self fetchImageForRequest:request completion:completion];
}

- (void)purgeCachesWithCompletion:(void (^)(void))completion
{
    if(!self.isMemoryCacheDeactivated) {
        self.memoryCache = [[NImageFetchMemoryCache alloc] init];
    }
    [self.fileCache purgeCacheWithCompletion:completion];
}

#pragma mark - Private methods

- (void)startImageFetchTask:(NImageFetchTaskI*)imageFetchTask
            downloadRequest:(NImageFetchRequest*)request
               fileCacheURL:(NSURL*)fileCacheURL
             memoryCacheKey:(NSString*)memoryCacheKey
{
    // Do not start download if already cancelled
    if(atomic_load(&imageFetchTask->completed) == 1) {
        return;
    }
    
    // Use download task rather than data task to keep memory usage low during download
    NSURLSessionTask *URLSessionTask = [self.URLSession downloadTaskWithRequest:request.urlRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Do not decode if already cancelled
        if(imageFetchTask->completed == 1) {
            return;
        }

        if(location) {
            if([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                // Do not cache errors
                if(statusCode < 200 || statusCode > 299) {
                    NSError *fetchError = [NImageFetchError errorWithCode:NImageFetchOtherError url:request.urlRequest.URL underlyingError:error statusCode:[NSNumber numberWithInteger:statusCode]];
                    [self callAsyncCompletionForImageFetchTask:imageFetchTask image:nil error:fetchError];
                    return;
                }
            }

            [self.fileCache moveFileAtURL:location toFileCacheURL:fileCacheURL];
            if ([response nma_isContentTypePDF]) {
                [self decodeAsPdfImageFetchTask:imageFetchTask request:request fileCacheURL:fileCacheURL memoryCacheKey:memoryCacheKey];
            } else {
                BOOL shouldDecodeAsPdf = NO;
                UIImage * image = [NImageFetchDecode decodeImageAtLocation:fileCacheURL pointSize:request.pointSize scale:request.scale shouldDecodeAsPdf:&shouldDecodeAsPdf];
                if(image) {
                    [self callAsyncCompletionForImageFetchTask:imageFetchTask image:image error:nil];
                    [self.memoryCache cacheImage:image forKey:memoryCacheKey];
                } else if(shouldDecodeAsPdf) {
                    [self decodeAsPdfImageFetchTask:imageFetchTask request:request fileCacheURL:fileCacheURL memoryCacheKey:memoryCacheKey];
                } else {
                    [self.fileCache removeFileAtURL:fileCacheURL];
                    NSError *fetchError = [NImageFetchError errorWithCode:NImageFetchOtherError url:request.urlRequest.URL underlyingError:error statusCode:nil];
                    [self callAsyncCompletionForImageFetchTask:imageFetchTask image:nil error:fetchError];
                }
            }
        } else {
            NSError *fetchError = [NImageFetchError errorWithCode:NImageFetchNetworkError url:request.urlRequest.URL underlyingError:error statusCode:nil];
            [self callAsyncCompletionForImageFetchTask:imageFetchTask image:nil error:fetchError];
        }
    }];

//WORKAROUND: There's a bug including session task priority symbols on iOS8.
//See https://openradar.appspot.com/23956486
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0 || tvOS
    switch(request.priority) {
        case NImageFetchPriorityDefault:
            URLSessionTask.priority = NSURLSessionTaskPriorityDefault;
        case NImageFetchPriorityHigh:
            URLSessionTask.priority = NSURLSessionTaskPriorityHigh;
    }
#endif
    
    imageFetchTask.URLSessionTask = URLSessionTask;
    [URLSessionTask resume];
}

- (void)decodeAsPdfImageFetchTask:(NImageFetchTaskI*)imageFetchTask
                          request:(NImageFetchRequest*)request
                     fileCacheURL:(NSURL*)fileCacheURL
                   memoryCacheKey:(NSString*)memoryCacheKey
{
    UIImage * renderedPdfImage = [NImageVectorDecoder drawPDFfromURL:fileCacheURL targetWidthInPoints:request.pointSize.width];
    if (renderedPdfImage) {
        [self.fileCache saveRenderedPdfImage:renderedPdfImage size:request.pointSize scale:request.scale sourceUrl:request.urlRequest.URL];
        [self callAsyncCompletionForImageFetchTask:imageFetchTask image:renderedPdfImage error:nil];
        [self.memoryCache cacheImage:renderedPdfImage forKey:memoryCacheKey];
    } else {
        [self.fileCache removeFileAtURL:fileCacheURL];
        NSError *fetchError = [NImageFetchError errorWithCode:NImageFetchOtherError url:request.urlRequest.URL underlyingError:nil statusCode:nil];
        [self callAsyncCompletionForImageFetchTask:imageFetchTask image:nil error:fetchError];
    }
}

- (void)callAsyncCompletionForImageFetchTask:(NImageFetchTaskI *)imageFetchTask
                                       image:(UIImage *)image
                                       error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(atomic_fetch_or(&imageFetchTask->completed, true) == false) {
            imageFetchTask.completion(image, error, 0);
        }
    });
}

@end

@implementation NSURLResponse (NMAContentTypePdf)

- (BOOL)nma_isContentTypePDF
{
    if([self isKindOfClass:[NSHTTPURLResponse class]]) {
        NSString * contentType = [((NSHTTPURLResponse *)self) allHeaderFields][@"Content-Type"];
        return [contentType caseInsensitiveCompare:@"application/pdf"] == NSOrderedSame;
    }
    return NO;
}

@end
