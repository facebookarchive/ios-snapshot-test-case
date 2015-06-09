/*
*  Copyright (c) 2015, Facebook, Inc.
*  All rights reserved.
*
*  This source code is licensed under the BSD-style license found in the
*  LICENSE file in the root directory of this source tree. An additional grant
*  of patent rights can be found in the PATENTS file in the same directory.
*
*/

public extension FBSnapshotTestCase {
  public func FBSnapshotVerifyView(view: UIView, identifier: String = "", suffixes: NSOrderedSet = FBSnapshotTestCaseDefaultSuffixes(), file: String = __FILE__, line: UInt = __LINE__) {
    let envReferenceImageDirectory = NSProcessInfo.processInfo().environment["FB_REFERENCE_IMAGE_DIR"]

    if let envReferenceImageDirectory = envReferenceImageDirectory {
      for suffix in suffixes {
        let referenceImagesDirectory = "\(envReferenceImageDirectory)\(suffix)"
        do {
            try compareSnapshotOfView(view, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier)
            break
        } catch {
            assert(false, message: "Snapshot comparison failed: \(error)", file: file, line: line)
        }
        if recordMode {
          break
        }

        assert(recordMode == false, message: "Test ran in record mode. Reference image is now saved. Disable record mode to perform an actual snapshot comparison!", file: file, line: line)
      }
    } else {
      assert(false, message: "Missing value for referenceImagesDirectory - Set FB_REFERENCE_IMAGE_DIR as Environment variable in your scheme.", file: file, line: line)
    }
  }

  public func FBSnapshotVerifyLayer(layer: CALayer, identifier: String = "", suffixes: NSOrderedSet = FBSnapshotTestCaseDefaultSuffixes(), file: String = __FILE__, line: UInt = __LINE__) {
    let envReferenceImageDirectory = NSProcessInfo.processInfo().environment["FB_REFERENCE_IMAGE_DIR"]

    if let envReferenceImageDirectory = envReferenceImageDirectory {
      for suffix in suffixes {
        let referenceImagesDirectory = "\(envReferenceImageDirectory)\(suffix)"
        do {
            try compareSnapshotOfLayer(layer, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier)
            break
        } catch {
            assert(false, message: "Snapshot comparison failed: \(error)", file: file, line: line)
        }

        if recordMode {
          break
        }

        assert(recordMode == false, message: "Test ran in record mode. Reference image is now saved. Disable record mode to perform an actual snapshot comparison!", file: file, line: line)
      }
    } else {
      XCTFail("Missing value for referenceImagesDirectory - Set FB_REFERENCE_IMAGE_DIR as Environment variable in your scheme.")
    }
  }

  func assert(assertion: Bool, message: String, file: String, line: UInt) {
    if !assertion {
      XCTFail(message, file: file, line: line)
    }
  }
}
