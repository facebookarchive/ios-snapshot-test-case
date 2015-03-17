/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <XCTest/XCTest.h>
#import "FBSnapshotTestController.h"

@interface FBSnapshotControllerTests : XCTestCase

@end

@implementation FBSnapshotControllerTests

- (UIImage *)bundledImageNamed:(NSString *)name type:(NSString *)type
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:name ofType:type];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [[UIImage alloc] initWithData:data];
}

- (void)testCompareReferenceImageToImageShouldBeEqual
{
    UIImage *referenceImage = [self bundledImageNamed:@"square" type:@"png"];
    XCTAssertNotNil(referenceImage, @"");
    UIImage *testImage = [self bundledImageNamed:@"square-copy" type:@"png"];
    XCTAssertNotNil(testImage, @"");
    FBSnapshotTestController *controller = [[FBSnapshotTestController alloc] initWithTestClass:nil];
    XCTAssertTrue([controller compareReferenceImage:referenceImage toImage:testImage error:nil], @"");
}

- (void)testCompareReferenceImageToImageShouldNotBeEqual
{
    UIImage *referenceImage = [self bundledImageNamed:@"square" type:@"png"];
    XCTAssertNotNil(referenceImage, @"");
    UIImage *testImage = [self bundledImageNamed:@"square_with_text" type:@"png"];
    XCTAssertNotNil(testImage, @"");
    FBSnapshotTestController *controller = [[FBSnapshotTestController alloc] initWithTestClass:nil];
    XCTAssertFalse([controller compareReferenceImage:referenceImage toImage:testImage error:nil], @"");
}

@end
