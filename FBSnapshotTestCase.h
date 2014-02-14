/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <QuartzCore/QuartzCore.h>

#import <UIKit/UIKit.h>

#import <XCTest/XCTest.h>

#ifndef FB_REFERENCE_IMAGE_DIR
#define FB_REFERENCE_IMAGE_DIR "\"$(SOURCE_ROOT)/$(PROJECT_NAME)Tests/ReferenceImages\""
#endif

/**
 Similar to our much-loved XCTAssert() macros. Use this to perform your test. No need to write an explanation, though.
 @param view The view to snapshot
 @param identifier An optional identifier, used is there are multiple snapshot tests in a given -test method.
 */
#define FBSnapshotVerifyView(view__, identifier__) \
{ \
  NSError *error__ = nil; \
  self.snapshotController.referenceImagesDirectory = [NSString stringWithFormat:@"%s", FB_REFERENCE_IMAGE_DIR]; \
  BOOL comparisonSuccess__ = [self.snapshotController compareSnapshotOfView:(view__) selector:self.selector identifier:(identifier__) error:&error__]; \
  XCTAssertTrue(comparisonSuccess__, @"Snapshot comparison failed: %@", error__); \
}

/**
 Similar to our much-loved XCTAssert() macros. Use this to perform your test. No need to write an explanation, though.
 @param layer The layer to snapshot
 @param identifier An optional identifier, used is there are multiple snapshot tests in a given -test method.
 */
#define FBSnapshotVerifyLayer(layer__, identifier__) \
{ \
  NSError *error__ = nil; \
  self.snapshotController.referenceImagesDirectory = [NSString stringWithFormat:@"%s", FB_REFERENCE_IMAGE_DIR]; \
  BOOL comparisonSuccess__ = [self.snapshotController compareSnapshotOfLayer:(layer__) selector:self.selector identifier:(identifier__) error:&error__]; \
  XCTAssertTrue(comparisonSuccess__, @"Snapshot comparison failed: %@", error__); \
}

@class FBTestSnapshotController;

/**
 The base class of view snapshotting tests. If you have small UI component, it's often easier to configure it in a test
 and compare an image of the view to a reference image that write lots of complex layout-code tests.

 In order to flip the tests in your subclass to record the reference images set `recordMode` to YES before calling
 -[super setUp].
 */
@interface FBSnapshotTestCase : XCTestCase
@property (readwrite, nonatomic, retain) FBTestSnapshotController *snapshotController;
@property(readwrite, nonatomic, assign) BOOL recordMode;
@end
