//  Copyright (c) 2022 Nomasystems. All rights reserved.

#import "NImageVectorDecoder.h"

@implementation NImageVectorDecoder

+ (nullable UIImage *)drawPDFfromURL:(NSURL *)URL targetWidthInPoints:(CGFloat)targetWidthInPoints
{
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)URL);
    if (document) {
        CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
        if (page) {
            CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            CGSize targetSize = CGSizeMake(targetWidthInPoints, targetWidthInPoints * pageRect.size.height/pageRect.size.width);
            UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:targetSize];
            UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull ctx) {
                CGContextRef cgContext = ctx.CGContext;
                CGContextTranslateCTM(cgContext, 0, targetSize.height);
                CGContextScaleCTM(cgContext, targetSize.width / pageRect.size.width, -(targetSize.height / pageRect.size.height));
                CGContextDrawPDFPage(cgContext, page);
            }];
            CGPDFDocumentRelease(document);
            return image;
        }
    }
    return nil;
}

@end

