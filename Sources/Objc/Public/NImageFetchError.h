//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** NImageFetch Error Domain */
extern NSString * const NImageFetchErrorDomain NS_SWIFT_UNAVAILABLE("Use ImageFetch.ImageFetchError instead");

/** NImageFetchError status code key */
extern NSString * const NImageFetchErrorStatusCodeKey;


typedef NS_CLOSED_ENUM(NSInteger, NImageFetchErrorCode) {
    /** A network error occured.
     *  The NSUnderlyingErrorKey value is an NSError with the domain NSURLErrorDomain.
     */
    NImageFetchNetworkError = 1,
    /** The image loading request was cancelled */
    NImageFetchCancelledError = 2,
    /** Other error loading the image (for example a HTTP 404) */
    NImageFetchOtherError = 3,
} NS_REFINED_FOR_SWIFT;


NS_SWIFT_UNAVAILABLE("Use ImageFetch.ImageFetchError instead")
@interface NImageFetchError : NSObject

+ (NSError*)errorWithCode:(NImageFetchErrorCode)code
                      url:(nullable NSURL*)url
          underlyingError:(nullable NSError*)underlyingError
               statusCode:(nullable NSNumber*)statusCode;

@end

NS_ASSUME_NONNULL_END
