// Copyright 2004-present Facebook. All Rights Reserved.

#import "FBExampleView.h"

@implementation FBExampleView

- (void)drawRect:(CGRect)rect
{
  [[UIColor redColor] setFill];
  CGContextFillRect(UIGraphicsGetCurrentContext(), [self bounds]);
}

@end
