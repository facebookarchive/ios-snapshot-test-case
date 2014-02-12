//
//  FBSnapshotTestRecorder.h
//  FBSnapshotTestCaseDemo
//
//  Created by Daniel Doubrovkine on 1/14/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FBTestSnapshotController.h"

@interface FBSnapshotTestRecorder : NSObject

@property (readwrite, nonatomic, assign) BOOL recordMode;
@property (readwrite, nonatomic, assign) SEL selector;
@property (readwrite, nonatomic, retain) FBTestSnapshotController *snapshotController;

- (id)initWithController:(FBTestSnapshotController *)controller;

- (BOOL)compareSnapshotOfViewOrLayer:(id)viewOrLayer
            referenceImagesDirectory:(NSString *)referenceImagesDirectory
                          identifier:(NSString *)identifier
                               error:(NSError **)errorPtr;

- (BOOL)performPixelComparisonWithViewOrLayer:(UIView *)viewOrLayer
                                   identifier:(NSString *)identifier
                                        error:(NSError **)errorPtr;

- (BOOL)recordSnapshotOfViewOrLayer:(id)viewOrLayer
                          identifier:(NSString *)identifier
                               error:(NSError **)errorPtr;

- (UIImage *)snapshotViewOrLayer:(id)viewOrLayer;

- (UIImage *)renderLayer:(CALayer *)layer;

@end
