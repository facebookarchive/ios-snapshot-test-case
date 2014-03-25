//
//  FBSnapshotTestCaseDemoTestsLandscape.m
//  FBSnapshotTestCaseDemo
//
//  Created by Daniel Doubrovkine on 3/24/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBSnapshotTestCase.h"
#import "FBExampleView.h"
#import "FBExampleViewController.h"
#import <objc/message.h>

@interface FBSnapshotTestCaseDemoTestsWithRotation : FBSnapshotTestCase

@end

@implementation FBSnapshotTestCaseDemoTestsWithRotation

- (void)setUp
{
    [super setUp];

    // Flip this to YES to record images in the reference image directory.
    // You need to do this the first time you create a test and whenever you change the snapshotted views.
    // Be careful not to commit with recordMode on though, or your tests will never fail.
    self.recordMode = NO;
}

- (void)tearDown
{
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationPortrait);
}

- (void)testExamplePortrait
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    FBExampleViewController *vc = [[FBExampleViewController alloc] init];
    window.rootViewController = vc;
    [window makeKeyAndVisible];
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationPortrait);
    [self waitFor:1];
    FBSnapshotVerifyView(window, nil);
    [window removeFromSuperview];
}

- (void)testExampleLandscape
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    FBExampleViewController *vc = [[FBExampleViewController alloc] init];
    window.rootViewController = vc;
    [window makeKeyAndVisible];
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeLeft);
    [self waitFor:2];
    FBSnapshotVerifyView(window, nil);
    [window removeFromSuperview];
}

- (void)waitFor:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    while(true) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) break;
    }
}

@end