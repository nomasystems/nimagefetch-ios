//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import "NImageFetchTaskI.h"


@interface NImageFetchTaskI ()
@property (nonatomic, copy) NImageFetchCompletion completion;
@property (nonatomic) BOOL isCancelled;
@end

@implementation NImageFetchTaskI

- (instancetype)initWithCompletion:(NImageFetchCompletion)completion
{
    if(self = [super init]) {
        completed = ATOMIC_VAR_INIT(false);
        self.completion = completion;
    }
    return self;
}

- (void)cancel {
    [self.fileCacheReadOperation cancel];
    [self.URLSessionTask cancel];
    self.isCancelled = YES;
}

@end
