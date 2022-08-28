//  Copyright © 2018 Nomasystems. All rights reserved.

#import "NImageFetchCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NImageFetchCache

+ (NSString *)cacheKeyForURL:(NSURL *)url
{
    const char *str = [[url absoluteString] UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *hash = [NSString stringWithFormat:
                      @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                      r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7],
                      r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return hash;
}

+ (NSString *)cacheKeyForURL:(NSURL *)url size:(CGSize)size scale:(CGFloat)scale
{
    NSString *urlCacheKey = [self cacheKeyForURL:url];
    if(CGSizeEqualToSize(size, CGSizeZero)) {
        return urlCacheKey;
    } else {
        return [urlCacheKey stringByAppendingFormat:@"-%ldx%ld", (long)floor(size.width * scale), (long)floor(size.height * scale)];
    }
}

@end
