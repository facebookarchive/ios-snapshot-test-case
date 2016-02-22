//
//  Created by Gabriel Handford on 3/1/09.
//  Copyright 2009-2013. All rights reserved.
//  Created by John Boiles on 10/20/11.
//  Copyright (c) 2011. All rights reserved
//  Modified by Felix Schulze on 2/11/13.
//  Copyright 2013. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <FBSnapshotTestCase/UIImage+Compare.h>

// This makes debugging much more fun
typedef union {
    uint32_t raw;
    unsigned char bytes[4];
    struct {
        char red;
        char green;
        char blue;
        char alpha;
    } __attribute__ ((packed)) pixels;
} FBComparePixel;

@implementation UIImage (Compare)

- (BOOL)fb_compareWithImage:(UIImage *)image tolerance:(CGFloat)tolerance
{
  return [self fb_isEqualToImage:image] || (tolerance > 0.0 && [self fb_differenceFromImage:image] < tolerance);
}


- (BOOL)fb_isEqualToImage:(UIImage *)image {
  NSAssert(CGSizeEqualToSize(self.size, image.size), @"Images must be same size.");
  
  CGContextRef referenceContext = [self fb_bitmapContext];
  CGContextRef imageContext = [image fb_bitmapContext];
  
  size_t pixelCount = CGBitmapContextGetHeight(referenceContext) * CGBitmapContextGetBytesPerRow(referenceContext);
  BOOL matches = (memcmp(CGBitmapContextGetData(referenceContext), CGBitmapContextGetData(imageContext), pixelCount) == 0);
  
  CGContextRelease(referenceContext);
  CGContextRelease(imageContext);
  
  return matches;
}

- (CGFloat)fb_differenceFromImage:(UIImage *)image {
  NSAssert(CGSizeEqualToSize(self.size, image.size), @"Images must be same size.");

  // Go through each pixel in turn and see if it is different
  CGContextRef referenceContext = [self fb_bitmapContext];
  CGContextRef imageContext = [image fb_bitmapContext];
  
  FBComparePixel *p1 = CGBitmapContextGetData(referenceContext);
  FBComparePixel *p2 = CGBitmapContextGetData(imageContext);
  
  NSInteger pixelCount = CGBitmapContextGetWidth(referenceContext) * CGBitmapContextGetHeight(referenceContext);
  NSInteger numDiffPixels = 0;
  for (int n = 0; n < pixelCount; ++n) {
    // If this pixel is different, increment the pixel diff count and see
    // if we have hit our limit.
    if (p1->raw != p2->raw) {
      numDiffPixels++;
    }
    
    p1++;
    p2++;
  }
  
  return (CGFloat)numDiffPixels / pixelCount;
}

- (CGContextRef)fb_bitmapContext {
  CGContextRef context = CGBitmapContextCreate(NULL,
                                               self.size.width,
                                               self.size.height,
                                               CGImageGetBitsPerComponent(self.CGImage),
                                               CGImageGetBytesPerRow(self.CGImage),
                                               CGImageGetColorSpace(self.CGImage),
                                               (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
  
  CGContextDrawImage(context, (CGRect){.size = self.size}, self.CGImage);
  
  NSAssert(context != nil, @"Unable to create context for comparision.");
  return context;
}

@end
