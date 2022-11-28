//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import "NImageFetchError.h"

NSString * const NImageFetchErrorDomain = @"NImageFetchErrorDomain";
NSString * const NImageFetchErrorStatusCodeKey = @"StatusCode";


@implementation NImageFetchError

+ (NSError*)errorWithCode:(NImageFetchErrorCode)code
                      url:(nullable NSURL*)url
          underlyingError:(nullable NSError*)underlyingError
               statusCode:(nullable NSNumber*)statusCode
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if(url) {
       [userInfo setObject:url forKey:NSURLErrorKey];
    }
    
    if(underlyingError) {
        [userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    }
    
    if(statusCode) {
        [userInfo setValue:statusCode forKey:NImageFetchErrorStatusCodeKey];
    }
    
    return [NSError errorWithDomain:NImageFetchErrorDomain code:code userInfo:userInfo];
}

@end
