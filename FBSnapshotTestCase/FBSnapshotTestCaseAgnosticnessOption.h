//
//  FBSnapshotTestCaseAgnosticnessOption.h
//  FBSnapshotTestCase
//
//  Created by Anton Domashnev on 05/05/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

@import Foundation;

/**
 Each of the options except none represents a specific suffix for snapshot name
 */
typedef NS_OPTIONS(NSUInteger, FBSnapshotTestCaseAgnosticnessOption) {
  /**
   None of the available options
   */
  FBSnapshotTestCaseAgnosticnessOptionNone = 0,
  /**
   Appends the name of the device model to the snapshot file name.
   */
  FBSnapshotTestCaseAgnosticnessOptionDeviceModel = 1 << 0,
  /**
   Appends the screen size to the snapshot file name.
   */
  FBSnapshotTestCaseAgnosticnessOptionScreenSize = 1 << 1,
  /**
   Appends the localization identifier to the snapshot file name.
   */
  FBSnapshotTestCaseAgnosticnessOptionLocalization = 1 << 2,
  /**
   Appends the name of the OS version to the snapshot file name.
   */
  FBSnapshotTestCaseAgnosticnessOptionOSVersion = 1 << 3
};