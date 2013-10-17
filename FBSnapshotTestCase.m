/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */
 
#import "FBSnapshotTestCase.h"

#import "FBTestSnapshotController.h"

@interface FBSnapshotTestCase ()

@property (readwrite, nonatomic, retain) FBTestSnapshotController *snapshotController;

@end

@implementation FBSnapshotTestCase

- (void)setUp
{
  [super setUp];
  self.snapshotController = [[FBTestSnapshotController alloc] initWithTestClass:[self class]];
}

- (void)tearDown
{
  self.snapshotController = nil;
  [super tearDown];
}

- (BOOL)compareSnapshotOfLayer:(CALayer *)layer
      referenceImagesDirectory:(NSString *)referenceImagesDirectory
                    identifier:(NSString *)identifier
                         error:(NSError **)errorPtr
{
  return [self _compareSnapshotOfViewOrLayer:layer
                    referenceImagesDirectory:referenceImagesDirectory
                                  identifier:identifier
                                       error:errorPtr];
}

- (BOOL)compareSnapshotOfView:(UIView *)view
     referenceImagesDirectory:(NSString *)referenceImagesDirectory
                   identifier:(NSString *)identifier
                        error:(NSError **)errorPtr
{
  return [self _compareSnapshotOfViewOrLayer:view
                    referenceImagesDirectory:referenceImagesDirectory
                                  identifier:identifier
                                       error:errorPtr];
}

#pragma mark -
#pragma mark Private API

- (BOOL)_compareSnapshotOfViewOrLayer:(id)viewOrLayer
             referenceImagesDirectory:(NSString *)referenceImagesDirectory
                           identifier:(NSString *)identifier
                                error:(NSError **)errorPtr
{
  _snapshotController.referenceImagesDirectory = referenceImagesDirectory;
  if (self.recordMode) {
    return [self _recordSnapshotOfViewOrLayer:viewOrLayer identifier:identifier error:errorPtr];
  } else {
    return [self _performPixelComparisonWithViewOrLayer:viewOrLayer identifier:identifier error:errorPtr];
  }
}

- (BOOL)_performPixelComparisonWithViewOrLayer:(UIView *)viewOrLayer
                                    identifier:(NSString *)identifier
                                         error:(NSError **)errorPtr
{
  UIImage *referenceImage = [_snapshotController referenceImageForSelector:self.selector identifier:identifier error:errorPtr];
  if (nil != referenceImage) {
    UIImage *snapshot = [self _snapshotViewOrLayer:viewOrLayer];
    BOOL imagesSame = [_snapshotController compareReferenceImage:referenceImage toImage:snapshot error:errorPtr];
    if (!imagesSame) {
      [_snapshotController saveFailedReferenceImage:referenceImage
                                          testImage:snapshot
                                           selector:self.selector
                                         identifier:identifier
                                              error:errorPtr];
    }
    return imagesSame;
  }
  return NO;
}

- (BOOL)_recordSnapshotOfViewOrLayer:(id)viewOrLayer
                          identifier:(NSString *)identifier
                               error:(NSError **)errorPtr
{
  UIImage *snapshot = [self _snapshotViewOrLayer:viewOrLayer];
  return [_snapshotController saveReferenceImage:snapshot selector:self.selector identifier:identifier error:errorPtr];
}

- (UIImage *)_snapshotViewOrLayer:(id)viewOrLayer
{
  CALayer *layer = nil;

  if ([viewOrLayer isKindOfClass:[UIView class]]) {
    UIView *view = (UIView *)viewOrLayer;
    [view layoutIfNeeded];
    layer = view.layer;
  } else if ([viewOrLayer isKindOfClass:[CALayer class]]) {
    layer = (CALayer *)viewOrLayer;
    [layer layoutIfNeeded];
  } else {
    XCTAssertTrue(NO, @"Only UIView and CALayer classes can be snapshotted!  %@", viewOrLayer);
  }

  return [self _renderLayer:layer];
}

- (UIImage *)_renderLayer:(CALayer *)layer
{
  CGRect bounds = layer.bounds;

  UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSaveGState(context);
  {
    [layer renderInContext:context];
  }
  CGContextRestoreGState(context);

  UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return snapshot;
}

@end
