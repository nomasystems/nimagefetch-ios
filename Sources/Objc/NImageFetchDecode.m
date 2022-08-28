//  Copyright (c) 2016 Nomasystems. All rights reserved.

#import "NImageFetchDecode.h"

@implementation NImageFetchDecode

+ (nullable UIImage*)decodeImageAtLocation:(NSURL*)location pointSize:(CGSize)pointSize scale:(CGFloat)scale shouldDecodeAsPdf:(BOOL*)shouldDecodeAsPdf
{
    if(!CGSizeEqualToSize(pointSize, CGSizeZero)) {
        return [self decodeImageThumbnailAtLocation:location pointSize:pointSize scale:scale shouldDecodeAsPdf:shouldDecodeAsPdf];
    } else {
        // If point size is not specified decode pdf with CGImageSourceCreateImageAtIndex just
        // as any other image. It well end up rendered at original size, 72 dpi.
        *shouldDecodeAsPdf = NO;
    }
    
    CFStringRef optionKeys[] = {kCGImageSourceShouldCache, kCGImageSourceShouldCacheImmediately};
    CFTypeRef optionValues[] = {kCFBooleanTrue, kCFBooleanFalse};
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)location, NULL);
        
    UIImage *image = nil;
    if(source) {
        CFDictionaryRef options = CFDictionaryCreate(NULL,
                                                     (const void **) optionKeys,
                                                     (const void **) optionValues,
                                                     2,
                                                     &kCFTypeDictionaryKeyCallBacks,
                                                     & kCFTypeDictionaryValueCallBacks);
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, 0, options);
        CFRelease(options);
        CFRelease(source);
        if(cgImage) {
            image = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);
        }
    }
    
    return image;
}

// see Image and Graphics Best Practices, WWDC 2018 - Session 219
// https://developer.apple.com/videos/play/wwdc2018/219/
+ (nullable UIImage*)decodeImageThumbnailAtLocation:(NSURL*)location pointSize:(CGSize)pointSize scale:(CGFloat)scale shouldDecodeAsPdf:(BOOL*)shouldDecodeAsPdf
{
    CFStringRef createOptionKeys[] = {kCGImageSourceShouldCache };
    CFTypeRef createOptionValues[] = {kCFBooleanFalse};
    CFDictionaryRef createOptions = CFDictionaryCreate(NULL,
                                                       (const void **) createOptionKeys,
                                                       (const void **) createOptionValues,
                                                       1,
                                                       &kCFTypeDictionaryKeyCallBacks,
                                                       & kCFTypeDictionaryValueCallBacks);
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)location, createOptions);
    CFRelease(createOptions);
    
    UIImage *image = nil;
    if(source) {
        CFStringRef imageSourceType = CGImageSourceGetType(source);
        if(imageSourceType && UTTypeEqual(imageSourceType, kUTTypePDF)) {
            *shouldDecodeAsPdf = YES;
            CFRelease(source);
            return nil;
        } else {
            *shouldDecodeAsPdf = NO;
        }
        
        CGFloat maxDimensionInPixels = MAX(pointSize.width, pointSize.height) * scale;
        CFStringRef thumbnailOptionKeys[] = {
            kCGImageSourceCreateThumbnailFromImageAlways,
            kCGImageSourceShouldCacheImmediately,
            kCGImageSourceCreateThumbnailWithTransform,
            kCGImageSourceThumbnailMaxPixelSize,
        };
        CFNumberRef maxDimensionInPixelsNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &maxDimensionInPixels);
        CFTypeRef thumbnailOptionValues[] = {
            kCFBooleanTrue,
            kCFBooleanTrue,
            kCFBooleanTrue,
            maxDimensionInPixelsNumber
        };
        CFDictionaryRef thumbnailOptions = CFDictionaryCreate(NULL,
                                                              (const void **) thumbnailOptionKeys,
                                                              (const void **) thumbnailOptionValues,
                                                              4,
                                                              &kCFTypeDictionaryKeyCallBacks,
                                                              & kCFTypeDictionaryValueCallBacks);
        CGImageRef cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions);
        CFRelease(thumbnailOptions);
        CFRelease(maxDimensionInPixelsNumber);
        CFRelease(source);
        if(cgImage) {
            image = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);
        }
    }
    return image;
}

@end
