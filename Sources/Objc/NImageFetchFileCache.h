//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** Image file cache in NSCachesDirectory */
@interface NImageFetchFileCache : NSObject

- (NSURL*)cacheFileURLForURL:(NSURL*)url;

- (NSURL*)cacheFileURLForRenderedPdfWithSourceURL:(NSURL*)url size:(CGSize)size scale:(CGFloat)scale;

- (void)moveFileAtURL:(NSURL*)URL toFileCacheURL:(NSURL*)toURL;

- (void)saveRenderedPdfImage:(UIImage *)image size:(CGSize)size scale:(CGFloat)scale sourceUrl:(NSURL *)url;

- (void)removeFileAtURL:(NSURL *)URL;

- (void)purgeCacheWithCompletion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
