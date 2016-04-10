/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/FBSnapshotTestCasePlatform.h>
#import <FBSnapshotTestCase/UIApplication+StrictKeyWindow.h>
#import <UIKit/UIKit.h>

BOOL FBSnapshotTestCaseIs64Bit(void)
{
#if __LP64__
  return YES;
#else
  return NO;
#endif
}

NSOrderedSet *FBSnapshotTestCaseDefaultSuffixes(void)
{
  NSMutableOrderedSet *suffixesSet = [[NSMutableOrderedSet alloc] init];
  [suffixesSet addObject:@"_32"];
  [suffixesSet addObject:@"_64"];
  if (FBSnapshotTestCaseIs64Bit()) {
    return [suffixesSet reversedOrderedSet];
  } 
  return [suffixesSet copy];
}

NSString *FBDeviceAgnosticNormalizedFileName(NSString *fileName, BOOL includeOSVersion)
{
  NSMutableString *deviceAgnosticFilename = [fileName mutableCopy];

  UIDevice *device = [UIDevice currentDevice];
  [deviceAgnosticFilename appendFormat:@"_%@", device.model];

  if (includeOSVersion) {
    [deviceAgnosticFilename appendFormat:@"%@", device.systemVersion];
  }

  UIWindow *keyWindow = [[UIApplication sharedApplication] fb_strictKeyWindow];
  CGSize screenSize = keyWindow.bounds.size;
  [deviceAgnosticFilename appendFormat:@"_%.0fx%.0f", screenSize.width, screenSize.height];

  NSMutableCharacterSet *invalidCharacters = [NSMutableCharacterSet new];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
  NSArray *validComponents = [deviceAgnosticFilename componentsSeparatedByCharactersInSet:invalidCharacters];

  return [validComponents componentsJoinedByString:@"_"];
}
