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

NSString *FBAgnosticNormalizedFileName(NSString *fileName, FBSnapshotTestCaseAgnosticnessOption options)
{
  if (options == FBSnapshotTestCaseAgnosticnessOptionNone) {
    return fileName;
  }
  
  NSMutableString *mutableFileName = [fileName mutableCopy];
  if (options & FBSnapshotTestCaseAgnosticnessOptionDeviceModel) {
    UIDevice *device = [UIDevice currentDevice];
    [mutableFileName appendFormat:@"_%@", device.model];
  }
  if (options & FBSnapshotTestCaseAgnosticnessOptionOSVersion) {
    UIDevice *device = [UIDevice currentDevice];
    [mutableFileName appendFormat:@"%@%@", (options & FBSnapshotTestCaseAgnosticnessOptionDeviceModel) ? @"" : @"_", device.systemVersion];
  }
  if (options & FBSnapshotTestCaseAgnosticnessOptionScreenSize) {
    UIWindow *keyWindow = [[UIApplication sharedApplication] fb_strictKeyWindow];
    CGSize screenSize = keyWindow.bounds.size;
    [mutableFileName appendFormat:@"_%.0fx%.0f", screenSize.width, screenSize.height];
  }
  if (options & FBSnapshotTestCaseAgnosticnessOptionLocalization) {
    [mutableFileName appendFormat:@"_%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject]];
  }

  NSMutableCharacterSet *invalidCharacters = [NSMutableCharacterSet new];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
  NSArray *validComponents = [mutableFileName componentsSeparatedByCharactersInSet:invalidCharacters];
  NSString *resultFileName = [validComponents componentsJoinedByString:@"_"];
  
  return resultFileName;
}