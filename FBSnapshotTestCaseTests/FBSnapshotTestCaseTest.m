//
//  Created by Gabriel Radu on 1/5/2016.
//  Copyright (c) 2016. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//


#import <XCTest/XCTest.h>
#import "FBSnapshotTestCase.h"


#define TestableFBSnapshotVerifyViewLayerOrImage(what__, viewLayerOrImage__, identifier__) \
  TestableFBSnapshotVerifyViewLayerOrImageWithOptions(what__, viewLayerOrImage__, identifier__, FBSnapshotTestCaseDefaultSuffixes(), 0)


#define TestableFBSnapshotVerifyViewLayerOrImageWithOptions(what__, viewLayerOrImage__, identifier__, suffixes__, tolerance__) \
  \
  BOOL testSuccess__ = NO; \
  NSMutableArray *errors__ = [NSMutableArray array]; \
  \
  _FBSnapshotVerifyViewOrLayerWithOptions(what__, viewLayerOrImage__, identifier__, suffixes__, tolerance__) \


@interface FBSnapshotTestCaseTest : FBSnapshotTestCase

@end

@implementation FBSnapshotTestCaseTest

- (void)setUp {
    [super setUp];
    //self.recordMode = YES;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testVerifyView
{
  UIView *testView = [self createTestViewWithSubViewColor:[UIColor redColor]];
  FBSnapshotVerifyView(testView, nil)
}

- (void)testVerifyViewWithNonMatchingImage
{
  UIView *testView = [self createTestViewWithSubViewColor:[UIColor redColor]];
  if (self.recordMode) {
    testView = [self createTestViewWithSubViewColor:[UIColor blueColor]];
  }
  
  TestableFBSnapshotVerifyViewLayerOrImage(View, testView, @"testVerifyImageWithWrongImage")
  
  XCTAssertFalse(testSuccess__);
  NSError *firstError = errors__.firstObject;
  XCTAssertNotNil(firstError);
  XCTAssertEqualObjects(firstError.domain, @"FBSnapshotTestControllerErrorDomain");
  XCTAssertEqual(firstError.code, 4);
}

- (void)testVerifyLayer
{
  UIView *testView = [self createTestViewWithSubViewColor:[UIColor redColor]];
  FBSnapshotVerifyLayer(testView.layer, nil)
}

- (void)testVerifyLayerWithNonMatchingImage
{
  UIView *testView = [self createTestViewWithSubViewColor:[UIColor redColor]];
  if (self.recordMode) {
    testView = [self createTestViewWithSubViewColor:[UIColor blueColor]];
  }
  
  TestableFBSnapshotVerifyViewLayerOrImage(Layer, testView.layer, @"testVerifyImageWithWrongImage")
  
  XCTAssertFalse(testSuccess__);
  NSError *firstError = errors__.firstObject;
  XCTAssertNotNil(firstError);
  XCTAssertEqualObjects(firstError.domain, @"FBSnapshotTestControllerErrorDomain");
  XCTAssertEqual(firstError.code, 4);
}

#pragma mark - Private helper methods

- (UIView *)createTestViewWithSubViewColor:(UIColor *)subViewColor
{
  UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
  testView.backgroundColor = [UIColor whiteColor];
  
  UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
  subview.backgroundColor = subViewColor;
  [testView addSubview:subview];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
  label.text = @"Some Text";
  [testView addSubview:label];
  
  return testView;
}

- (UIImage *)_bundledImageNamed:(NSString *)name type:(NSString *)type
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:name ofType:type];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [[UIImage alloc] initWithData:data];
}

@end
