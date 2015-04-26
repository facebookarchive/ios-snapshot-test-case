/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>

extern NSString *const FBSnapshotTestArchitectureType32BitKey;
extern NSString *const FBSnapshotTestArchitectureType64BitKey;

/// Returns an ordered set of suffixes based on the FBSnapshotTestArchitectureType, 
extern NSOrderedSet *FBSuffixesArchitectureTypes(NSDictionary *architectureTypes);