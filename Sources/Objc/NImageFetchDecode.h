//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <CoreServices/CoreServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface NImageFetchDecode : NSObject

+ (nullable UIImage*)decodeImageAtLocation:(NSURL*)location pointSize:(CGSize)pointSize scale:(CGFloat)scale shouldDecodeAsPdf:(BOOL*)shouldDecodeAsPdf;

@end

NS_ASSUME_NONNULL_END
