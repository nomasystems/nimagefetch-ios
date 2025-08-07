//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import <Foundation/Foundation.h>

#if !defined(__cplusplus)
#include <stdatomic.h>
#endif

#import "NImageFetch.h"


NS_ASSUME_NONNULL_BEGIN

@interface NImageFetchTaskI : NSObject <NImageFetchTask>
{
@public atomic_bool completed;
}
@property (nonatomic, weak, nullable) NSOperation *fileCacheReadOperation;
@property (nonatomic, weak, nullable) NSURLSessionTask *URLSessionTask;
@property (nonatomic, copy, readonly) NImageFetchCompletion completion;
@property (nonatomic, readonly) BOOL isCancelled;

- (instancetype)initWithCompletion:(NImageFetchCompletion)completion;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
