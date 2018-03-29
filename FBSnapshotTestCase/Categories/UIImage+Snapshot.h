/*
 *  Copyright (c) 2015-present, Facebook, Inc.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

#import <UIKit/UIKit.h>

@interface UIImage (Snapshot)

/// Uses renderInContext: to get a snapshot of the layer.
+ (UIImage *)fb_imageForLayer:(CALayer *)layer scale:(CGFloat)scale;

/// Uses renderInContext: to get a snapshot of the view layer.
+ (UIImage *)fb_imageForViewLayer:(UIView *)view scale:(CGFloat)scale;

/// Uses drawViewHierarchyInRect: to get a snapshot of the view and adds the view into a window if needed.
+ (UIImage *)fb_imageForView:(UIView *)view scale:(CGFloat)scale;

@end
