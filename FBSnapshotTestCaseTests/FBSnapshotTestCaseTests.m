//
//  FBSnapshotTestCaseTests.m
//  FBSnapshotTestCase
//
//  Created by Anton Domashnev on 10/05/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

@import XCTest;

#import "FBSnapshotTestCase.h"

@interface FBSnapshotTestCaseTests : XCTestCase

@property (nonatomic, strong) FBSnapshotTestCase *testCase;

@end

@implementation FBSnapshotTestCaseTests

- (void)setUp {
  [super setUp];
  self.testCase = [FBSnapshotTestCase new];
  [self.testCase setUp];
}

- (void)tearDown {
  [self.testCase tearDown];
  [super tearDown];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)testThatSetDeviceAgnosticShouldSetCorrectAgnosticnessOptions {
  self.testCase.deviceAgnostic = YES;
  
  XCTAssertTrue(self.testCase.agnosticnessOptions & FBSnapshotTestCaseAgnosticnessOptionDeviceModel);
  XCTAssertTrue(self.testCase.agnosticnessOptions & FBSnapshotTestCaseAgnosticnessOptionScreenSize);
  XCTAssertTrue(self.testCase.agnosticnessOptions & FBSnapshotTestCaseAgnosticnessOptionOSVersion);
}

- (void)testThatDeviceAgnosticShouldReturnCorrectAgnosticnessOptions {
  self.testCase.agnosticnessOptions = FBSnapshotTestCaseAgnosticnessOptionDeviceModel;
  XCTAssertFalse(self.testCase.isDeviceAgnostic);
  
  self.testCase.agnosticnessOptions = FBSnapshotTestCaseAgnosticnessOptionDeviceModel | FBSnapshotTestCaseAgnosticnessOptionScreenSize;
  XCTAssertFalse(self.testCase.isDeviceAgnostic);
  
  self.testCase.agnosticnessOptions = FBSnapshotTestCaseAgnosticnessOptionDeviceModel | FBSnapshotTestCaseAgnosticnessOptionScreenSize | FBSnapshotTestCaseAgnosticnessOptionOSVersion;
  XCTAssertTrue(self.testCase.isDeviceAgnostic);
}

#pragma GCC diagnostic pop

@end
