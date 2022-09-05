//  Copyright (c) 2022 Nomasystems. All rights reserved.

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface NImageVectorDecoder : NSObject

+ (nullable UIImage *)drawPDFfromURL:(NSURL *)URL targetWidthInPoints:(CGFloat)targetWidthInPoints;

@end

NS_ASSUME_NONNULL_END
