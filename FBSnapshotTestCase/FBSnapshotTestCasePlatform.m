/*
 *  Copyright (c) 2015-present, Facebook, Inc.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
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

NSString *FBDeviceAgnosticNormalizedFileName(NSString *fileName)
{
  UIDevice *device = [UIDevice currentDevice];
  UIWindow *keyWindow = [[UIApplication sharedApplication] fb_strictKeyWindow];
  CGSize screenSize = keyWindow.bounds.size;
  NSString *os = device.systemVersion;
  
  fileName = [NSString stringWithFormat:@"%@_%@%@_%.0fx%.0f", fileName, device.model, os, screenSize.width, screenSize.height];
  
  NSMutableCharacterSet *invalidCharacters = [NSMutableCharacterSet new];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
  NSArray *validComponents = [fileName componentsSeparatedByCharactersInSet:invalidCharacters];
  fileName = [validComponents componentsJoinedByString:@"_"];
  
  return fileName;
}