//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** In-memory image cache. Takes 25% of available physical memory */
@interface NImageFetchMemoryCache : NSObject

- (nullable UIImage *)imageForKey:(NSString *)key;
- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
