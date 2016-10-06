# Change Log

All notable changes to this project will be documented in this file.

## 2.1.4

  - Swift 3 suppport (#194)
  - Replace big macro with Objective-C method for easier debugging (#180)

## 2.1.3

  - Allow to compile with Xcode 7 and Xcode 8 Swift 2.3 (#179)

## 2.1.2

  - Disabled Bitcode for tvOS target (#169)
  - Added user target in podspec (#165)

## 2.1.1

  - Added tvOS support for cocoapods (#163)
  - Remove custom module map for cocoapods (#141)

## 2.1.0

  - Changed FBSnapshotTestController from private to public in the xcodeproj (#135)
  - Added device agnostic tests and assertions (#137)
  - Fixed fb_imageForView edge cases (#138, #153)
  - Changed project setting to match the code style (#139)
  - Fixed propagating the correct file name and line number on Swift (#140)
  - Added framework support for tvOS (#143)
  - Added optional tolerance parameter on Swift (#145)
  - Added images to comparison errors (#146)
  - Fixed build for Xcode 7.3 (#152)
  
## 2.0.7

  - Change FBSnapshotTestController from private to public (#129)

## 2.0.6

  - Added modulemap and podspec fixes to build with Xcode 7.1 (#127)

## 2.0.5

  - Swift 2.0 (#111, #120) (Thanks to @pietbrauer and @grantjk)
  - Fix pod spec by disabling bitcode (#115) (Thanks to @soleares)
  - Fix for incorrect errors with multiple suffixes (#119) (Thanks to @Grubas7)
  - Support for Model and OS in image names (#121 thanks to @esttorhe)

## 2.0.4

  - Support loading reference images from the test bundle (#104) (Thanks to @yiding)
  - Fix for retina tolerance comparisons (#107)

## 2.0.3

  - New property added `usesDrawViewHierarchyInRect` to handle cases like `UIVisualEffect` (#70), `UIAppearance` (#91) and Size Classes (#92) (#100)

## 2.0.2

  - Fix for retina comparisons (#96) 
  
## 2.0.1

  - Allow usage of Objective-C subspec only, for projects supporting iOS 7 (#93) (Thanks to @x2on)

## 2.0.0

  - Approximate comparison (#88) (Thanks to @nap-sam-dean)
  - Swift support (#87) (Thanks to @pietbrauer)

## 1.8.1

  - Prevent mangling of C function names when compiled with a C++ compiler. (#79)

## 1.8.0

  - The default directories for snapshots images are now **ReferenceImages_32** (32bit) and **ReferenceImages_64** (64bit) and the suffix depends on the architecture when the test is running. (#77) 
  	- If a test fails for a given suffix, it will try to load and compare all other suffixes before failing.
  - Added assertion on setRecordMode. (#76)
