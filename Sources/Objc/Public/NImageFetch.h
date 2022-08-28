//  Copyright © 2016 Nomasystems. All rights reserved.

@import Foundation;
@import UIKit;
@import Darwin.C.stdatomic;
@import CoreServices;

#import "NImageFetchError.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, NImageFetchFlag) {
    /* The image was loaded synchronously (i.e. the completion block was called synchronusly) */
    NImageFetchFlagSync NS_SWIFT_NAME(synchronous) = 1 << 0
} NS_SWIFT_NAME(ImageFetchFlags);


typedef NS_CLOSED_ENUM(NSUInteger, NImageFetchPriority) {
    NImageFetchPriorityDefault,
    /* Load the image with high priority */
    NImageFetchPriorityHigh,
} NS_SWIFT_NAME(ImageFetchPriority);

typedef void (^NImageFetchCompletion)(UIImage * _Nullable image, NSError* _Nullable error, NImageFetchFlag flags) NS_SWIFT_UNAVAILABLE("");

NS_SWIFT_NAME(ImageFetchRequest)
@interface NImageFetchRequest : NSObject
@property (readonly, nonatomic) NSURLRequest *urlRequest;
/** Defaults to NImageFetchPriorityDefault */
@property (readwrite, nonatomic) NImageFetchPriority priority;
/** The image will be downsampled to this size. Defaults to CGSizeZero - do not downscale.
    If the content type of the image application/pdf, this size specifies the size of the image
    to render from the first page of the pdf document.
 */
@property (readwrite, nonatomic) CGSize pointSize;
/** The image will be downsampled with this screen scale. Defaults to 1 */
@property (readwrite, nonatomic) CGFloat scale;

/** Content type hint.
 Only kUTTypePDF has any effect - makes NImageFetch look for a rendered image of the pdf, or the original pdf, in the disk cache.
 Defaults to nil.
 DEPRECATED: this property no longer does anything. The actual file type in the disk cache
 is considered. Note that the pointSize and scale should be set, or the pdf will be decoded at its original size at 72 dpi.
 */
@property (readwrite, nonatomic) NSString *contentTypeHint DEPRECATED_MSG_ATTRIBUTE("No longer has any effect");

+ (instancetype)requestWithUrlRequest:(NSURLRequest*)urlRequest NS_SWIFT_UNAVAILABLE("");

- (instancetype)initWithUrlRequest:(NSURLRequest*)urlRequest NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end


NS_SWIFT_NAME(ImageFetchTask)
@protocol NImageFetchTask
@end

NS_SWIFT_NAME(ImageFetch)
@interface NImageFetch : NSObject

@property (nonatomic, class, readonly) NImageFetch *sharedImageFetch;

/** Start fetching the image specified by the URL request.
 *  @param request Request to fetch
 *  @return An NImageFetchTask, or nil if the image did need to be fetched (already in cache).
 */
- (nullable id<NImageFetchTask>)fetchImageForRequest:(NImageFetchRequest*)request
                                          completion:(NImageFetchCompletion)completion NS_REFINED_FOR_SWIFT;

- (void)cancel:(nullable id<NImageFetchTask>)imageFetchTask;

- (void)deactivateMemoryCache;

- (void)purgeCaches;

@end

NS_ASSUME_NONNULL_END
