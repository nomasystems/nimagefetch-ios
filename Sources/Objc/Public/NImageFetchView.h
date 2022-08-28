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

@class NImageFetchView;
@class NImageFetchRequest;

@protocol NImageFetchViewDelegate <NSObject>

@optional

/** Called when the requested image has been loaded and set on the image view */
- (void)imageViewDidSetRequestedImage:(NImageFetchView*)imageView;

/** Called if the image request failed */
- (void)imageView:(NImageFetchView*)imageView requestFailedWithError:(NSError*)error;

@end


@interface NImageFetchView : UIImageView

@property (readonly, nonatomic) NImageFetchViewStatus status;
@property (weak, nonatomic) id<NImageFetchViewDelegate> imageFetchViewDelegate;

- (void)setImageFromRequest:(NImageFetchRequest*)request
                   animated:(NImageFetchViewAnimated)animated NS_SWIFT_UNAVAILABLE("Use setImage(from: .. instead");

/** Asynchronously downloads the image given by the specified URL, and sets it to the image view.
 @param request Request to fetch
 @param animated Specifies whether to fade in the image with an animation.
 @param fallbackImage Optional image that will be set if the image load request fails
                      (but not if request is cancelled).
 */
- (void)setImageFromRequest:(NImageFetchRequest*)request
                   animated:(NImageFetchViewAnimated)animated
              fallbackImage:(nullable UIImage*)fallbackImage NS_REFINED_FOR_SWIFT;

- (void)setImageFromUrlRequest:(NSURLRequest*)request
                      animated:(NImageFetchViewAnimated)animated NS_REFINED_FOR_SWIFT;

/** Cancel loading (no effect if image already loaded or cancelled) */
- (void)cancelLoading;

/** Show the activtiy indicator, while the image is loading. */
- (void)showActivityIndicator;

- (void)hideActivityIndicator;

/** If the image failed to load, then retry */
- (void)ensureImageIsBeingLoaded;

@end

NS_ASSUME_NONNULL_END
