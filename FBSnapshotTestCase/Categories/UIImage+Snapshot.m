/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/UIImage+Snapshot.h>

@implementation UIImage (Snapshot)

+ (UIImage *)fb_imageForViewOrLayer:(id)viewOrLayer
{
  if ([viewOrLayer isKindOfClass:[UIView class]]) {
    return [self fb_imageForView:viewOrLayer];
  } else if ([viewOrLayer isKindOfClass:[CALayer class]]) {
    CALayer *layer = (CALayer *)viewOrLayer;
    [layer layoutIfNeeded];
    return [self fb_imageForLayer:layer];
  } else {
    [NSException raise:@"Only UIView and CALayer classes can be snapshotted" format:@"%@", viewOrLayer];
  }
  return nil;
}

+ (UIImage *)fb_imageForLayer:(CALayer *)layer
{
  CGRect bounds = layer.bounds;
  NSAssert1(CGRectGetWidth(bounds), @"Zero width for layer %@", layer);
  NSAssert1(CGRectGetHeight(bounds), @"Zero height for layer %@", layer);

  UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  NSAssert1(context, @"Could not generate context for layer %@", layer);

  CGContextSaveGState(context);
  [layer renderInContext:context];
  CGContextRestoreGState(context);

  UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return snapshot;
}

+ (UIImage *)fb_imageForView:(UIView *)view
{
  [view layoutIfNeeded];
  return [self fb_imageForLayer:view.layer];
}

@end
