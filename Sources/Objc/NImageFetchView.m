//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import "NImageFetchView.h"
#import "NImageFetch.h"


@interface NImageFetchView ()
@property (readwrite, nonatomic) NImageFetchViewStatus status;
@property (nonatomic, strong) id<NImageFetchTask> imageFetchTask;
@property (nonatomic, strong) NImageFetchRequest * request;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@end

static void (^errorHandler)(NSError *error) = nil;

@implementation NImageFetchView

+ (void)setErrorHandler:(void (^)(NSError *error))handler {
    errorHandler = [handler copy];
}

- (void)dealloc
{
    /* Do not notify delegate while deallocating */
    [self cancelLoading];
}


- (void)setImage:(UIImage *)image
{
    if(image == nil) {
        self.status = NImageFetchViewStatusNotLoaded;
        self.request = nil;
    }
    [super setImage:image];
}

- (void)setImageFromRequest:(NImageFetchRequest*)request
                   animated:(NImageFetchViewAnimated)animated
                 completion:(nullable NImageFetchViewCompletion)completion
{
    [self setImageFromRequest:request animated:animated fallbackImage:nil completion:completion];
}

- (void)setImageFromRequest:(NImageFetchRequest*)request
                   animated:(NImageFetchViewAnimated)animated
              fallbackImage:(UIImage*)fallbackImage
                 completion:(nullable NImageFetchViewCompletion)completion
{
    NSParameterAssert(request);
    
    /* Cancel the old image fetch task, if any. Otherwise the old image may end up completing
     loading after the new one, and override it */
    [self cancelLoading];

    /* Save the urlRequest in order to make possible to retry the load */
    self.request = request;

    /* Avoid retain loop in block */
    __weak NImageFetchView *weakSelf = self;
    id<NImageFetchTask> anImageFetchTask =
    [[NImageFetch sharedImageFetch] fetchImageForRequest:request
                             completion:^(UIImage *image, NSError *error, NImageFetchFlag flags) {
                                 __strong NImageFetchView *strongSelf = weakSelf;
                                 if(error) {
                                     if(error.code != NImageFetchCancelledError) {
                                         strongSelf.image = fallbackImage;
                                     }
                                     strongSelf.status = NImageFetchViewStatusNotLoaded;
                                     [strongSelf hideActivityIndicator];
                                     if (errorHandler != nil) {
                                         errorHandler(error);
                                     }
                                     if (completion != nil) {
                                         completion(error);
                                     }
                                 } else if(image) {
                                     [strongSelf hideActivityIndicator];
                                     [strongSelf setImage:image];
                                     strongSelf.status = NImageFetchViewStatusLoaded;
                                     if(strongSelf.superview && !weakSelf.hidden &&
                                        ((animated == NImageFetchViewAnimatedAlways) ||
                                        ((animated == NImageFetchViewAnimatedIfAsync) &&
                                         ((flags & NImageFetchFlagSync) == 0)))) {
                                         strongSelf.alpha = 0.0;
                                        [UIView animateWithDuration:0.5
                                                              delay:0
                                                            options:UIViewAnimationOptionAllowUserInteraction|
                                                                    UIViewAnimationOptionCurveEaseInOut
                                                         animations:^{
                                            strongSelf.alpha = 1.0;
                                        } completion:NULL];
                                     }
                                     if (completion != nil) {
                                         completion(nil);
                                     }
                                 } else {
                                     strongSelf.status = NImageFetchViewStatusNotLoaded;
                                     [strongSelf hideActivityIndicator];
                                 }
                             }];
    if(anImageFetchTask) {
        self.status = NImageFetchViewStatusLoading;
    } else {
        self.status = NImageFetchViewStatusLoaded;
    }
    self.imageFetchTask = anImageFetchTask;
}

- (void)setImageFromUrlRequest:(NSURLRequest *)urlRequest
                      animated:(NImageFetchViewAnimated)animated
                    completion:(nullable NImageFetchViewCompletion)completion
{
    NImageFetchRequest *request = [NImageFetchRequest requestWithUrlRequest:urlRequest];
    [self setImageFromRequest:request animated:animated completion:completion];
}

- (void)ensureImageIsBeingLoaded
{
    if ((self.status == NImageFetchViewStatusNotLoaded) &&
        (self.request) &&
        (!self.image)) {
        [self setImageFromRequest:self.request animated:NImageFetchViewAnimatedAlways completion:nil];
    }
}

- (void)cancelLoading
{
    if(self.status == NImageFetchViewStatusLoading) {
        NImageFetch *imageFetch = [NImageFetch sharedImageFetch];
        [imageFetch cancel:self.imageFetchTask];
        self.imageFetchTask = nil;
        self.status = NImageFetchViewStatusNotLoaded;
    }
}

- (void)showActivityIndicator
{
    if(self.status != NImageFetchViewStatusLoading) {
        return;
    }
    
    if(!self.activityIndicator) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        // Center the activity indicator in the UIImageView
        activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        activityIndicator.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        activityIndicator.hidesWhenStopped = YES;
        [self addSubview:activityIndicator];
        self.activityIndicator = activityIndicator;
    }
    [self.activityIndicator startAnimating];
}


- (void)hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
}


@end
