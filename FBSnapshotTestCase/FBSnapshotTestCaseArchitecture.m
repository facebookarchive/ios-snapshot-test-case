/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/FBSnapshotTestCaseArchitecture.h>

NSString *const FBSnapshotTestArchitectureType32BitKey = @"FBSnapshotTestArchitectureType32Bit";
NSString *const FBSnapshotTestArchitectureType64BitKey = @"FBSnapshotTestArchitectureType64Bit";

/// Returns true if the test is running in 64bit, otherwise returns NO.
NS_INLINE BOOL FBSnapshotTestIs64Bit(void)
{
#if __LP64__
  return YES;
#else
  return NO;
#endif
}

NSOrderedSet* FBSuffixesForArchitectureTypes(NSDictionary *architectureTypes)
{
  NSCAssert(([architectureTypes objectForKey:FBSnapshotTestArchitectureType32BitKey] &&
             [architectureTypes objectForKey:FBSnapshotTestArchitectureType64BitKey]),
            @"architectureTypes need to contain both keys.");
  NSMutableOrderedSet *suffixesSet = [[NSMutableOrderedSet alloc] init];
  [suffixesSet addObject:architectureTypes[FBSnapshotTestArchitectureType32BitKey]];
  [suffixesSet addObject:architectureTypes[FBSnapshotTestArchitectureType64BitKey]];
  if (FBSnapshotTestIs64Bit()) {
    return [suffixesSet reversedOrderedSet];
  } 
  return [suffixesSet copy];
}