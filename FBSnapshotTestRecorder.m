//
//  FBSnapshotTestRecorder.m
//  FBSnapshotTestCaseDemo
//
//  Created by Daniel Doubrovkine on 1/14/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBSnapshotTestRecorder.h"

@implementation FBSnapshotTestRecorder

- (id) initWithController:(FBTestSnapshotController *)controller
{
    if (self = [super init]) {
        self.snapshotController = controller;
        self.recordMode = NO;
    }
    return self;
}

- (BOOL)compareSnapshotOfViewOrLayer:(id)viewOrLayer
            referenceImagesDirectory:(NSString *)referenceImagesDirectory
                          identifier:(NSString *)identifier
                               error:(NSError **)errorPtr
{
    _snapshotController.referenceImagesDirectory = referenceImagesDirectory;
    if (self.recordMode) {
        return [self recordSnapshotOfViewOrLayer:viewOrLayer identifier:identifier error:errorPtr];
    } else {
        return [self performPixelComparisonWithViewOrLayer:viewOrLayer identifier:identifier error:errorPtr];
    }
}

- (BOOL)performPixelComparisonWithViewOrLayer:(UIView *)viewOrLayer
                                    identifier:(NSString *)identifier
                                         error:(NSError **)errorPtr
{
    UIImage *referenceImage = [_snapshotController referenceImageForSelector:self.selector identifier:identifier error:errorPtr];
    if (nil != referenceImage) {
        UIImage *snapshot = [self snapshotViewOrLayer:viewOrLayer];
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

- (BOOL)recordSnapshotOfViewOrLayer:(id)viewOrLayer
                          identifier:(NSString *)identifier
                               error:(NSError **)errorPtr
{
    UIImage *snapshot = [self snapshotViewOrLayer:viewOrLayer];
    return [_snapshotController saveReferenceImage:snapshot selector:self.selector identifier:identifier error:errorPtr];
}

- (UIImage *)snapshotViewOrLayer:(id)viewOrLayer
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
        [NSException raise:@"Invalid view or layer" format:@"Only UIView and CALayer classes can be snapshotted!  %@", viewOrLayer];
    }
    
    return [self renderLayer:layer];
}

- (UIImage *)renderLayer:(CALayer *)layer
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
