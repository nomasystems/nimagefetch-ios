//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_CLOSED_ENUM(NSUInteger, NImageFetchViewAnimated) {
    /* Never animate image set */
    NImageFetchViewAnimatedNever = 0,
    /* Animate image set if loading image is asynchronous */
    NImageFetchViewAnimatedIfAsync,
    /* Always animate image set */
    NImageFetchViewAnimatedAlways,
};


typedef NS_CLOSED_ENUM(NSUInteger, NImageFetchViewStatus) {
    NImageFetchViewStatusNotLoaded = 0,
    NImageFetchViewStatusLoading,
    NImageFetchViewStatusLoaded
};

typedef void (^NImageFetchViewCompletion)(NSError * _Nullable);

@class NImageFetchView;
@class NImageFetchRequest;

@interface NImageFetchView : UIImageView

@property (readonly, nonatomic) NImageFetchViewStatus status;

/** Asynchronously downloads the image given by the specified NImageFetchRequest and sets it to the image view.
 @param request NImageFetchRequest to fetch
 @param animated Specifies whether to fade in the image with an animation.
 @param completion Specifies a block to receive the result of the fetch.
 */
- (void)setImageFromRequest:(NImageFetchRequest*)request
                   animated:(NImageFetchViewAnimated)animated
                 completion:(nullable NImageFetchViewCompletion)completion NS_SWIFT_UNAVAILABLE("Use setImage(from: .. instead");

/** Asynchronously downloads the image given by the specified NImageFetchRequest and sets it to the image view.
 @param request NImageFetchRequest to fetch
 @param animated Specifies whether to fade in the image with an animation.
 @param fallbackImage Optional image that will be set if the image load request fails
                      (but not if request is cancelled).
 @param completion Specifies a block to receive the result of the fetch.
 */
- (void)setImageFromRequest:(NImageFetchRequest*)request
                   animated:(NImageFetchViewAnimated)animated
              fallbackImage:(nullable UIImage*)fallbackImage
                 completion:(nullable NImageFetchViewCompletion)completion NS_REFINED_FOR_SWIFT;

/** Asynchronously downloads the image given by the specified NSURLRequest and sets it to the image view.
 @param request NSURLRequest to fetch
 @param animated Specifies whether to fade in the image with an animation.
 @param completion Specifies a block to receive the result of the fetch.
 */
- (void)setImageFromUrlRequest:(NSURLRequest*)request
                      animated:(NImageFetchViewAnimated)animated
                    completion:(nullable NImageFetchViewCompletion)completion NS_REFINED_FOR_SWIFT;;

+ (void)setErrorHandler:(void (^)(NSError *error))handler;

/** Cancel loading (no effect if image already loaded or cancelled) */
- (void)cancelLoading;

/** Show the activtiy indicator while the image is loading. */
- (void)showActivityIndicator;

- (void)hideActivityIndicator;

/** If the image failed to load then retry */
- (void)ensureImageIsBeingLoaded;

@end

NS_ASSUME_NONNULL_END
