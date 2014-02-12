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
#import "FBSnapshotTestRecorder.h"

@interface FBSnapshotTestCase ()

@property (readwrite, nonatomic, retain) FBTestSnapshotController *snapshotController;
@property (readwrite, nonatomic, retain) FBSnapshotTestRecorder *recorder;

@end

@implementation FBSnapshotTestCase

- (void)setUp
{
  [super setUp];
  self.snapshotController = [[FBTestSnapshotController alloc] initWithTestClass:[self class]];
  self.recorder = [[FBSnapshotTestRecorder alloc] initWithController:_snapshotController];
}

- (void)tearDown
{
  self.snapshotController = nil;
  self.recorder = nil;
  [super tearDown];
}

- (BOOL)compareSnapshotOfLayer:(CALayer *)layer
      referenceImagesDirectory:(NSString *)referenceImagesDirectory
                    identifier:(NSString *)identifier
                         error:(NSError **)errorPtr
                  testSelector:(SEL)selector
                    recordMode:(BOOL)record
{
    _recorder.selector = selector;
    _recorder.recordMode = record;
    return [_recorder compareSnapshotOfViewOrLayer:layer
                          referenceImagesDirectory:referenceImagesDirectory
                                        identifier:identifier
                                             error:errorPtr];
}

- (BOOL)compareSnapshotOfView:(UIView *)view
     referenceImagesDirectory:(NSString *)referenceImagesDirectory
                   identifier:(NSString *)identifier
                        error:(NSError **)errorPtr
                 testSelector:(SEL)selector
                   recordMode:(BOOL)record
{
    _recorder.selector = selector;
    _recorder.recordMode = record;
    return [_recorder compareSnapshotOfViewOrLayer:view
                          referenceImagesDirectory:referenceImagesDirectory
                                        identifier:identifier
                                             error:errorPtr];
}

@end
