# Change Log

All notable changes to this project will be documented in this file.

## 2.0.0

  - Approximate comparison (#88) (Thanks to @nap-sam-dean)
  - Swift support (#87) (Thanks to @pietbrauer)

## 1.8.1

### Fixed

  - Prevent mangling of C function names when compiled with a C++ compiler. (#79)

## 1.8.0

### Changed

  - The default directories for snapshots images are now **ReferenceImages_32** (32bit) and **ReferenceImages_64** (64bit) and the suffix depends on the architecture when the test is running. (#77) 
  	- If a test fails for a given suffix, it will try to load and compare all other suffixes before failing.
  - Added assertion on setRecordMode. (#76)
