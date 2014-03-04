/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FBTestSnapshotControllerErrorCode) {
  FBTestSnapshotControllerErrorCodeUnknown,
  FBTestSnapshotControllerErrorCodeNeedsRecord,
  FBTestSnapshotControllerErrorCodePNGCreationFailed,
  FBTestSnapshotControllerErrorCodeImagesDifferentSizes,
  FBTestSnapshotControllerErrorCodeImagesDifferent,
};
/**
 Errors returned by the methods of FBTestSnapshotController use this domain.
 */
extern NSString *const FBTestSnapshotControllerErrorDomain;

/**
 Errors returned by the methods of FBTestSnapshotController sometimes contain this key in the `userInfo` dictionary.
 */
extern NSString *const FBReferenceImageFilePathKey;

/**
 Provides the heavy-lifting for FBSnapshotTestCase. It loads and saves images, along with performing the actual pixel-
 by-pixel comparison of images.
 Instances are initialized with the test class, and directories to read and write to.
 */
@interface FBTestSnapshotController : NSObject

/**
 Designated initializer.
 Before this methods returns the controller enumerates over the test methods in `testClass` and loads the images
 for those tests.
 @param testClass The subclass of FBSnapshotTestCase that is using this controller.
 @param referenceImagesDirectory The directory where the reference images are stored.
 @returns An instance of FBTestSnapshotController.
 */
- (id)initWithTestClass:(Class)testClass;

/**
 The directory in which referfence images are stored.
 */
@property (readwrite, nonatomic, copy) NSString *referenceImagesDirectory;

/**
 Loads a reference image.
 @param selector The test method being run.
 @param identifier The optional identifier, used when multiple images are tested in a single -test method.
 @param error An error, if this methods returns nil, the error will be something useful.
 @returns An image.
 */
- (UIImage *)referenceImageForSelector:(SEL)selector
                            identifier:(NSString *)identifier
                                 error:(NSError **)error;

/**
 Saves a reference image.
 @param selector The test method being run.
 @param identifier The optional identifier, used when multiple images are tested in a single -test method.
 @param error An error, if this methods returns NO, the error will be something useful.
 @returns An image.
 */
- (BOOL)saveReferenceImage:(UIImage *)image
                  selector:(SEL)selector
                identifier:(NSString *)identifier
                     error:(NSError **)errorPtr;

/**
 Performs a pixel-by-pixel comparison of the two images.
 @param referenceImage The reference (correct) image.
 @param image The image to test against the reference.
 @param error An error that indicates why the comparison failed if it does.
 @param YES if the comparison succeeded and the images are the same.
 */
- (BOOL)compareReferenceImage:(UIImage *)referenceImage
                      toImage:(UIImage *)image
                        error:(NSError **)errorPtr;

/**
 Saves the reference image and the test image to `failedOutputDirectory`.
 @param referenceImage The reference (correct) image.
 @param testImage The image to test against the reference.
 @param selector The test method being run.
 @param identifier The optional identifier, used when multiple images are tested in a single -test method.
 @param error An error that indicates why the comparison failed if it does.
 @param YES if the save succeeded.
 */
- (BOOL)saveFailedReferenceImage:(UIImage *)referenceImage
                       testImage:(UIImage *)testImage
                        selector:(SEL)selector
                      identifier:(NSString *)identifier
                           error:(NSError **)errorPtr;
@end
