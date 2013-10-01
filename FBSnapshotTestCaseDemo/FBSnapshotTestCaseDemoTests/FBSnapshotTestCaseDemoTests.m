// Copyright 2004-present Facebook. All Rights Reserved.

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
  // Be careful not to commit with recordMode on though, or your tests will never fail.
  self.recordMode = NO;
}

- (void)testExample
{
  FBExampleView *v = [[FBExampleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
  FBSnapshotVerifyView(v, nil);
}

@end
