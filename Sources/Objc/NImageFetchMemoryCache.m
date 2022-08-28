//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import "NImageFetchMemoryCache.h"
#import "NImageFetchDecode.h"

@interface NImageFetchMemoryCache ()
@property (nonatomic, strong) NSCache *cache;
@end


@implementation NImageFetchMemoryCache

- (id)init
{
    if(self = [super init]) {
        NSCache *cache = [[NSCache alloc] init];
        // Set the cost limit of the cache to 25% of available physical memory.
        // This limit is chosen based on (as of iOS 8/9) an app being allowed totally
        // use 50-60% percent of available physical memory
        // (see http://stackoverflow.com/questions/5887248/ios-app-maximum-memory-budget/15200855#15200855)
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSInteger totalCostLimitInBytes = processInfo.physicalMemory * 0.25;
        cache.totalCostLimit = totalCostLimitInBytes;
        self.cache = cache;
    }
    return self;
}

- (UIImage*)imageForKey:(NSString *)key
{
    return [self.cache objectForKey:key];
}

- (void)cacheImage:(UIImage*)image forKey:(NSString *)key
{
    NSUInteger estimatedCostInBytes = image.size.width * image.size.height * 4;
    // Only cache images whose cost is less than 25% of the total cost limit
    // This avoids caching really large images that would evict all the other images from the cache.
    if(estimatedCostInBytes * 4 <= self.cache.totalCostLimit) {
        NSUInteger estimatedCostInBytes = image.size.width * image.size.height * 4;
        [self.cache setObject:image forKey:key cost:estimatedCostInBytes];
    }
}

@end
