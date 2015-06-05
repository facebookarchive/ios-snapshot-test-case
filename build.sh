#!/bin/sh

set -eu

function ci_lib() {
    xcodebuild -project FBSnapshotTestCase.xcodeproj \
               -scheme FBSnapshotTestCase \
               -destination "platform=iOS Simulator,name=iPhone 6" \
               -sdk iphonesimulator \
               build test
}

function ci_demo() {
    pushd FBSnapshotTestCaseDemo
    pod install
    xcodebuild -workspace FBSnapshotTestCaseDemo.xcworkspace \
               -scheme FBSnapshotTestCaseDemo \
               -destination "platform=iOS Simulator,name=iPhone 6" \
               build test
    popd
}

ci_lib && ci_demo


