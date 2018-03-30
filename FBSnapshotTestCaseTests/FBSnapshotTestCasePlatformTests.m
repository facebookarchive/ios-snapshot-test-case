//
//  FBSnapshotTestCasePlatformTests.m
//  FBSnapshotTestCase
//
//  Created by Anton Domashnev on 05/05/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

@import XCTest;
@import UIKit;

#import <OCMock/OCMock.h>

#import "FBSnapshotTestCasePlatform.h"

@interface FBSnapshotTestCasePlatformTests : XCTestCase

@end

@implementation FBSnapshotTestCasePlatformTests

- (void)testAgnosticNormalizedFileNameShouldReturnFileNameWithModelNameIfModelNameOptionPresented {
  UIDevice *currentDeviceMock = OCMPartialMock([UIDevice new]);
  id deviceMock = OCMClassMock([UIDevice class]);
  OCMStub([deviceMock currentDevice]).andReturn(currentDeviceMock);
  OCMStub([currentDeviceMock model]).andReturn(@"iPhone");
  
  NSString *normalizedFileName = FBAgnosticNormalizedFileName(@"testFileName", FBSnapshotTestCaseAgnosticnessOptionDeviceModel);
  
  XCTAssertTrue([normalizedFileName hasSuffix:@"_iPhone"]);
  
  [deviceMock stopMocking];
}

- (void)testAgnosticNormalizedFileNameShouldReturnFileNameWithOSIfOSOptionPresented {
  UIDevice *currentDeviceMock = OCMPartialMock([UIDevice new]);
  id deviceMock = OCMClassMock([UIDevice class]);
  OCMStub([deviceMock currentDevice]).andReturn(currentDeviceMock);
  OCMStub([currentDeviceMock systemVersion]).andReturn(@"4.0");
  
  NSString *normalizedFileName = FBAgnosticNormalizedFileName(@"testFileName", FBSnapshotTestCaseAgnosticnessOptionOSVersion);
  
  XCTAssertTrue([normalizedFileName hasSuffix:@"_4_0"]);
  
  [deviceMock stopMocking];
}

- (void)testAgnosticNormalizedFileNameShouldReturnFileNameWithScreenSizeIfScreenSizeOptionPresented {
  NSString *normalizedFileName = FBAgnosticNormalizedFileName(@"testFileName", FBSnapshotTestCaseAgnosticnessOptionScreenSize);
  
  XCTAssertTrue([normalizedFileName hasSuffix:@"_0x0"]);
}

- (void)testAgnosticNormalizedFileNameShouldReturnFileNameWithLocalizationIdentifierIfLocalizationOptionPresented {
  NSUserDefaults *defaults = OCMPartialMock([NSUserDefaults new]);
  id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
  OCMStub([userDefaultsMock standardUserDefaults]).andReturn(defaults);
  [defaults setObject:@[@"ru-RU"] forKey:@"AppleLanguages"];
  
  NSString *normalizedFileName = FBAgnosticNormalizedFileName(@"testFileName", FBSnapshotTestCaseAgnosticnessOptionLocalization);
  
  XCTAssertTrue([normalizedFileName hasSuffix:@"_ru_RU"]);
  
  [userDefaultsMock stopMocking];
}

- (void)testAgnosticNormalizedFileNameShouldReturnFileNameWithAllProvidedOptions {
  UIDevice *currentDeviceMock = OCMPartialMock([UIDevice new]);
  id deviceMock = OCMClassMock([UIDevice class]);
  OCMStub([deviceMock currentDevice]).andReturn(currentDeviceMock);
  OCMStub([currentDeviceMock model]).andReturn(@"iPhone");
  OCMStub([currentDeviceMock systemVersion]).andReturn(@"4.0");
  
  NSUserDefaults *defaults = OCMPartialMock([NSUserDefaults new]);
  id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
  OCMStub([userDefaultsMock standardUserDefaults]).andReturn(defaults);
  [defaults setObject:@[@"ru-RU"] forKey:@"AppleLanguages"];
  
  NSString *normalizedFileName = FBAgnosticNormalizedFileName(@"testFileName", (FBSnapshotTestCaseAgnosticnessOption)(FBSnapshotTestCaseAgnosticnessOptionOSVersion | FBSnapshotTestCaseAgnosticnessOptionScreenSize | FBSnapshotTestCaseAgnosticnessOptionDeviceModel | FBSnapshotTestCaseAgnosticnessOptionLocalization));
  
  XCTAssertTrue([normalizedFileName hasSuffix:@"_iPhone4_0_0x0_ru_RU"]);
  
  [deviceMock stopMocking];
  [userDefaultsMock stopMocking];
}

@end
