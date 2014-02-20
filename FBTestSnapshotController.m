/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "FBTestSnapshotController.h"

#import "UIImage+Compare.h"
#import "UIImage+Diff.h"

#import <objc/runtime.h>

#import <UIKit/UIKit.h>

NSString *const FBTestSnapshotControllerErrorDomain = @"FBTestSnapshotControllerErrorDomain";

NSString *const FBReferenceImageFilePathKey = @"FBReferenceImageFilePathKey";

typedef struct RGBAPixel {
  char r;
  char g;
  char b;
  char a;
} RGBAPixel;

@interface FBTestSnapshotController ()

@property (readonly, nonatomic, retain) Class testClass;

@end

@implementation FBTestSnapshotController
{
  NSFileManager *_fileManager;
}

#pragma mark -
#pragma mark Lifecycle

- (id)initWithTestClass:(Class)testClass;
{
  if ((self = [super init])) {
    _testClass = testClass;
    _fileManager = [[NSFileManager alloc] init];
  }
  return self;
}

#pragma mark -
#pragma mark Properties

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ %@", [super description], _referenceImagesDirectory];
}

#pragma mark -
#pragma mark Public API

- (UIImage *)referenceImageForSelector:(SEL)selector
                            identifier:(NSString *)identifier
                          languageCode:(NSString *)languageCode
                                 error:(NSError **)errorPtr
{
  NSString *filePath = [self _referenceFilePathForSelector:selector identifier:identifier languageCode:languageCode];
  UIImage *image = [UIImage imageWithContentsOfFile:filePath];
  if (nil == image && NULL != errorPtr) {
    BOOL exists = [_fileManager fileExistsAtPath:filePath];
    if (!exists) {
      *errorPtr = [NSError errorWithDomain:FBTestSnapshotControllerErrorDomain
                                      code:FBTestSnapshotControllerErrorCodeNeedsRecord
                                  userInfo:@{
               FBReferenceImageFilePathKey: filePath,
                 NSLocalizedDescriptionKey: @"Unable to load reference image.",
          NSLocalizedFailureReasonErrorKey: @"Reference image not found. You need to run the test in record mode",
                   }];
    } else {
      *errorPtr = [NSError errorWithDomain:FBTestSnapshotControllerErrorDomain
                                      code:FBTestSnapshotControllerErrorCodeUnknown
                                  userInfo:nil];
    }
  }
  return image;
}

- (BOOL)saveReferenceImage:(UIImage *)image
                  selector:(SEL)selector
                identifier:(NSString *)identifier
              languageCode:(NSString *)languageCode
                     error:(NSError **)errorPtr
{
  BOOL didWrite = NO;
  if (nil != image) {
    NSString *filePath = [self _referenceFilePathForSelector:selector identifier:identifier languageCode:languageCode];
    NSData *pngData = UIImagePNGRepresentation(image);
    if (nil != pngData) {
      NSError *creationError = nil;
      BOOL didCreateDir = [_fileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&creationError];
      if (!didCreateDir) {
        if (NULL != errorPtr) {
          *errorPtr = creationError;
        }
        return NO;
      }
      didWrite = [pngData writeToFile:filePath options:NSDataWritingAtomic error:errorPtr];
    } else {
      if (nil != errorPtr) {
        *errorPtr = [NSError errorWithDomain:FBTestSnapshotControllerErrorDomain
                                        code:FBTestSnapshotControllerErrorCodePNGCreationFailed
                                    userInfo:@{
                 FBReferenceImageFilePathKey: filePath,
                     }];
      }
    }
  }
  return didWrite;
}

- (BOOL)saveFailedReferenceImage:(UIImage *)referenceImage
                       testImage:(UIImage *)testImage
                        selector:(SEL)selector
                      identifier:(NSString *)identifier
                    languageCode:(NSString *)languageCode
                           error:(NSError **)errorPtr
{
  NSData *referencePNGData = UIImagePNGRepresentation(referenceImage);
  NSData *testPNGData = UIImagePNGRepresentation(testImage);

  NSString *referencePath = [self _failedFilePathForSelector:selector
                                                  identifier:identifier
                                                languageCode:languageCode
                                                fileNameType:FBTestSnapshotFileNameTypeFailedReference];

  NSError *creationError = nil;
  BOOL didCreateDir = [_fileManager createDirectoryAtPath:[referencePath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&creationError];
  if (!didCreateDir) {
    if (NULL != errorPtr) {
      *errorPtr = creationError;
    }
    return NO;
  }

  if (![referencePNGData writeToFile:referencePath options:NSDataWritingAtomic error:errorPtr]) {
    return NO;
  }

  NSString *testPath = [self _failedFilePathForSelector:selector
                                             identifier:identifier
                                           languageCode:languageCode
                                           fileNameType:FBTestSnapshotFileNameTypeFailedTest];

  if (![testPNGData writeToFile:testPath options:NSDataWritingAtomic error:errorPtr]) {
    return NO;
  }
    
  NSString *diffPath = [self _failedFilePathForSelector:selector
                                             identifier:identifier
                                           languageCode:languageCode
                                           fileNameType:FBTestSnapshotFileNameTypeFailedTestDiff];
    
  UIImage *diffImage = [referenceImage diffWithImage:testImage];
  NSData *diffImageData = UIImagePNGRepresentation(diffImage);
    
  if (![diffImageData writeToFile:diffPath options:NSDataWritingAtomic error:errorPtr]) {
    return NO;
  }

  NSLog(@"If you have Kaleidoscope installed you can run this command to see an image diff:\n"
        @"ksdiff \"%@\" \"%@\"", referencePath, testPath);

  return YES;
}

- (BOOL)compareReferenceImage:(UIImage *)referenceImage toImage:(UIImage *)image error:(NSError **)errorPtr
{
  if (CGSizeEqualToSize(referenceImage.size, image.size)) {

    BOOL imagesEqual = [referenceImage compareWithImage:image];
    if (NULL != errorPtr) {
      *errorPtr = [NSError errorWithDomain:FBTestSnapshotControllerErrorDomain
                                      code:FBTestSnapshotControllerErrorCodeImagesDifferent
                                  userInfo:@{
                 NSLocalizedDescriptionKey: @"Images different",
                   }];
    }
    return imagesEqual;
  }
  if (NULL != errorPtr) {
    *errorPtr = [NSError errorWithDomain:FBTestSnapshotControllerErrorDomain
                                    code:FBTestSnapshotControllerErrorCodeImagesDifferentSizes
                                userInfo:@{
               NSLocalizedDescriptionKey: @"Images different sizes",
        NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"referenceImage:%@, image:%@",
                                           NSStringFromCGSize(referenceImage.size),
                                           NSStringFromCGSize(image.size)],
                 }];
  }
  return NO;
}

#pragma mark -
#pragma mark Private API

typedef NS_ENUM(NSUInteger, FBTestSnapshotFileNameType) {
  FBTestSnapshotFileNameTypeReference,
  FBTestSnapshotFileNameTypeFailedReference,
  FBTestSnapshotFileNameTypeFailedTest,
  FBTestSnapshotFileNameTypeFailedTestDiff,
};

- (NSString *)_fileNameForSelector:(SEL)selector
                        identifier:(NSString *)identifier
                      languageCode:(NSString *)languageCode
                      fileNameType:(FBTestSnapshotFileNameType)fileNameType
{
  NSString *fileName = nil;
  switch (fileNameType) {
    case FBTestSnapshotFileNameTypeFailedReference:
      fileName = @"reference_";
      break;
    case FBTestSnapshotFileNameTypeFailedTest:
      fileName = @"failed_";
      break;
    case FBTestSnapshotFileNameTypeFailedTestDiff:
      fileName = @"diff_";
      break;
    default:
      fileName = @"";
      break;
  }
  fileName = [fileName stringByAppendingString:NSStringFromSelector(selector)];
  if (0 < identifier.length) {
    fileName = [fileName stringByAppendingFormat:@"_%@", identifier];
  }
  if (languageCode) {
      fileName = [fileName stringByAppendingFormat:@"_%@", languageCode];
  }
  if ([[UIScreen mainScreen] scale] >= 2.0) {
    fileName = [fileName stringByAppendingString:@"@2x"];
  }
  fileName = [fileName stringByAppendingPathExtension:@"png"];
  return fileName;
}

- (NSString *)_referenceFilePathForSelector:(SEL)selector
                                 identifier:(NSString *)identifier
                               languageCode:(NSString *)languageCode
{
  NSString *fileName = [self _fileNameForSelector:selector
                                       identifier:identifier
                                     languageCode:languageCode
                                     fileNameType:FBTestSnapshotFileNameTypeReference];
  NSString *filePath = [_referenceImagesDirectory stringByAppendingPathComponent:NSStringFromClass(_testClass)];
  filePath = [filePath stringByAppendingPathComponent:fileName];
  return filePath;
}

- (NSString *)_failedFilePathForSelector:(SEL)selector
                              identifier:(NSString *)identifier
                            languageCode:(NSString *)languageCode
                            fileNameType:(FBTestSnapshotFileNameType)fileNameType
{
  NSString *fileName = [self _fileNameForSelector:selector
                                       identifier:identifier
                                     languageCode:languageCode
                                     fileNameType:fileNameType];
  NSString *folderPath = NSTemporaryDirectory();
  if (getenv("IMAGE_DIFF_DIR")) {
    folderPath = @(getenv("IMAGE_DIFF_DIR"));
  }
  NSString *filePath = [folderPath stringByAppendingPathComponent:NSStringFromClass(_testClass)];
  filePath = [filePath stringByAppendingPathComponent:fileName];
  return filePath;
}

@end
