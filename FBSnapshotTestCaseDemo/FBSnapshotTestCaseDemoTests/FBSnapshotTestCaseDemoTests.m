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
#import "FBExampleView.h"

@interface FBSnapshotTestCaseDemoTests : FBSnapshotTestCase

@end

@implementation FBSnapshotTestCaseDemoTests

- (void)setUp
{
  [super setUp];
  // Flip this to YES to record images in the reference image directory.
  // You need to do this the first time you create a test and whenever you change the snapshotted views.
  // Tests running in record mode will allways fail so that you know that you have to do something here before you commit.
  self.recordMode = NO;
}

- (void)testExample
{
  FBExampleView *v = [[FBExampleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
  FBSnapshotVerifyView(v, nil);
}

@end
