/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/FBSnapshotTestCase.h>

@interface FBSnapshotTestCaseDeviceAgnosticTests : FBSnapshotTestCase

@end

@implementation FBSnapshotTestCaseDeviceAgnosticTests

- (void)setUp
{
    [super setUp];
    self.deviceAgnostic = YES;
    self.recordMode = NO;
}

- (void)testSuccessfulComparisonOfDeviceAgnosticReferenceImages
{
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    redView.backgroundColor = [UIColor redColor];
    FBSnapshotVerifyView(redView, nil);
    FBSnapshotVerifyLayer(redView.layer, nil);
}

@end
