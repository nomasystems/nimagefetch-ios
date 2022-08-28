//  Copyright © 2018 Nomasystems. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface NImageFetchCache : NSObject

+ (NSString *)cacheKeyForURL:(NSURL *)url;

+ (NSString *)cacheKeyForURL:(NSURL *)url size:(CGSize)size scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
