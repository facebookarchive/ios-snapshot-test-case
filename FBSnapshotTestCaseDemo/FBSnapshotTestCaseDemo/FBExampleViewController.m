//
//  FBExampleViewController.m
//  FBSnapshotTestCaseDemo
//
//  Created by Daniel Doubrovkine on 3/24/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBExampleViewController.h"
#import "FBExampleView.h"

@implementation FBExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor yellowColor];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat factor = UIDeviceOrientationIsPortrait(orientation) ? 2 : 3;

    CGFloat width = CGRectGetWidth(self.view.bounds) / factor;
    CGFloat height = CGRectGetHeight(self.view.bounds) / factor;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);

    CGFloat marginX = (screenWidth - width) / 2;
    CGFloat marginY = (screenHeight - height) / 2;

    CGRect rect = CGRectMake(marginX, marginY, width, height);
    FBExampleView *subView = [[FBExampleView alloc] initWithFrame:rect];
    [self.view addSubview:subView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self loadView];
    [self viewDidLoad];
}


@end
