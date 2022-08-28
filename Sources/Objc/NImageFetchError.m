//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import "NImageFetchError.h"

NSString * const NImageFetchErrorDomain = @"NImageFetchErrorDomain";

@implementation NImageFetchError

+ (NSError*)errorWithCode:(NImageFetchErrorCode)code
                      url:(NSURL*)url
          underlyingError:(NSError*)underlyingError
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if(url) {
       [userInfo setObject:url forKey:NSURLErrorKey];
    }
    
    if(underlyingError) {
        [userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    }
    
    return [NSError errorWithDomain:NImageFetchErrorDomain code:code userInfo:userInfo];
}

@end
