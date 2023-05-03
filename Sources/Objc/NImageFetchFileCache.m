//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import "NImageFetchFileCache.h"
#import "NImageFetchCache.h"
#import "NImageFetchDecode.h"
#import "NImageFetchMemoryCache.h"


static NSString * const CacheDirName = @"Images";

@interface NImageFetchFileCache ()
@property (nonatomic, strong) NSURL *diskCacheURL;
@end

@implementation NImageFetchFileCache

- (instancetype)init
{
    if(self = [super init]) {
        NSURL *baseURL = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                                inDomains:NSUserDomainMask].firstObject;
        self.diskCacheURL = [baseURL URLByAppendingPathComponent:CacheDirName isDirectory:YES];
        [self createDiskCacheDirectoryIfNeeded];
    }
    return self;
}

- (NSURL*)cacheFileURLForURL:(NSURL*)url
{
    NSString *filename = [NImageFetchCache cacheKeyForURL:url];
    return [self cacheURLWithFilename:filename];
}

- (NSURL*)cacheFileURLForRenderedPdfWithSourceURL:(NSURL*)url size:(CGSize)size scale:(CGFloat)scale
{
    NSString *filename = [NImageFetchCache cacheKeyForURL:url size:size scale:scale];
    return [self cacheURLWithFilename:filename];
}

- (void)moveFileAtURL:(nonnull NSURL *)URL toFileCacheURL:(nonnull NSURL *)toURL
{
    [[NSFileManager defaultManager] removeItemAtURL:toURL error: nil];
    [[NSFileManager defaultManager] moveItemAtURL:URL toURL:toURL error:nil];
}

- (void)saveRenderedPdfImage:(UIImage *)image size:(CGSize)size scale:(CGFloat)scale sourceUrl:(NSURL *)sourceUrl
{
    NSData * binaryImageData = UIImagePNGRepresentation(image);
    [binaryImageData writeToURL:[self cacheFileURLForRenderedPdfWithSourceURL:sourceUrl size:size scale:scale] atomically:YES];
}

- (void)removeFileAtURL:(NSURL *)URL
{
    [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
}

- (void)purgeCacheWithCompletion:(void (^)(void))completion
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *tmpURL = [[fileManager URLForDirectory:NSItemReplacementDirectory
                                         inDomain:NSUserDomainMask
                                appropriateForURL:self.diskCacheURL
                                           create:YES
                                            error:nil]
                     URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    if(tmpURL) {
        [fileManager moveItemAtURL:self.diskCacheURL toURL:tmpURL error:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [fileManager removeItemAtURL:tmpURL error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createDiskCacheDirectoryIfNeeded];
                completion();
            });
        });
    }
}

#pragma - Private methods

- (NSURL *)cacheURLWithFilename:(NSString *)filename
{
    return [self.diskCacheURL URLByAppendingPathComponent:filename];
}

- (void)createDiskCacheDirectoryIfNeeded
{
    [[NSFileManager defaultManager] createDirectoryAtURL:self.diskCacheURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
}

@end
