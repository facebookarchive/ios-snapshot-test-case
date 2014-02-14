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

- (BOOL) recordMode
{
    return self.snapshotController.recordMode;
}

- (void) setRecordMode:(BOOL)recordMode
{
    self.snapshotController.recordMode = recordMode;
}

@end
