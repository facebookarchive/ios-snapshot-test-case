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
                                 error:(NSError **)errorPtr
{
  NSString *filePath = [self _referenceFilePathForSelector:selector identifier:identifier];
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
                     error:(NSError **)errorPtr
{
  BOOL didWrite = NO;
  if (nil != image) {
    NSString *filePath = [self _referenceFilePathForSelector:selector identifier:identifier];
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
                           error:(NSError **)errorPtr
{
  NSData *referencePNGData = UIImagePNGRepresentation(referenceImage);
  NSData *testPNGData = UIImagePNGRepresentation(testImage);

  NSString *referencePath = [self _failedFilePathForSelector:selector
                                                  identifier:identifier
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
                                           fileNameType:FBTestSnapshotFileNameTypeFailedTest];

  if (![testPNGData writeToFile:testPath options:NSDataWritingAtomic error:errorPtr]) {
    return NO;
  }

  NSLog(@"If you have Kaleidoscope installed you can run this command to see an image diff:\n"
        @"ksdiff \"%@\" \"%@\"", referencePath, testPath);

  return YES;
}

- (BOOL)compareReferenceImage:(UIImage *)referenceImage toImage:(UIImage *)image error:(NSError **)errorPtr
{
  if (CGSizeEqualToSize(referenceImage.size, image.size)) {

    BOOL imagesEqual = [self _compareReferenceImage:referenceImage toImage:image];
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
};

- (NSString *)_fileNameForSelector:(SEL)selector
                        identifier:(NSString *)identifier
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
    default:
      fileName = @"";
      break;
  }
  fileName = [fileName stringByAppendingString:NSStringFromSelector(selector)];
  if (0 < identifier.length) {
    fileName = [fileName stringByAppendingFormat:@"_%@", identifier];
  }
  if ([[UIScreen mainScreen] scale] >= 2.0) {
    fileName = [fileName stringByAppendingString:@"@2x"];
  }
  fileName = [fileName stringByAppendingPathExtension:@"png"];
  return fileName;
}

- (NSString *)_referenceFilePathForSelector:(SEL)selector identifier:(NSString *)identifier
{
  NSString *fileName = [self _fileNameForSelector:selector
                                       identifier:identifier
                                     fileNameType:FBTestSnapshotFileNameTypeReference];
  NSString *filePath = [_referenceImagesDirectory stringByAppendingPathComponent:NSStringFromClass(_testClass)];
  filePath = [filePath stringByAppendingPathComponent:fileName];
  return filePath;
}

- (NSString *)_failedFilePathForSelector:(SEL)selector
                              identifier:(NSString *)identifier
                            fileNameType:(FBTestSnapshotFileNameType)fileNameType
{
  NSString *fileName = [self _fileNameForSelector:selector
                                       identifier:identifier
                                     fileNameType:fileNameType];
  NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:NSStringFromClass(_testClass)];
  filePath = [filePath stringByAppendingPathComponent:fileName];
  return filePath;
}

- (BOOL)_compareReferenceImage:(UIImage *)referenceImage toImage:(UIImage *)image
{
  size_t maxBytesPerRow = MIN(CGImageGetBytesPerRow(referenceImage.CGImage), CGImageGetBytesPerRow(image.CGImage));
  size_t referenceImageSizeBytes = CGImageGetHeight(referenceImage.CGImage) * maxBytesPerRow;
  void *referenceImagePixels = calloc(1, referenceImageSizeBytes);
  void *imagePixels = calloc(1, referenceImageSizeBytes);

  if (!referenceImagePixels || !imagePixels) {
    free(referenceImagePixels);
    free(imagePixels);
    return NO;
  }
    
  CGContextRef referenceImageContext = CGBitmapContextCreate(referenceImagePixels,
                                                             CGImageGetWidth(referenceImage.CGImage),
                                                             CGImageGetHeight(referenceImage.CGImage),
                                                             CGImageGetBitsPerComponent(referenceImage.CGImage),
                                                             maxBytesPerRow,
                                                             CGImageGetColorSpace(referenceImage.CGImage),
                                                             (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                             );
  CGContextRef imageContext = CGBitmapContextCreate(imagePixels,
                                                    CGImageGetWidth(image.CGImage),
                                                    CGImageGetHeight(image.CGImage),
                                                    CGImageGetBitsPerComponent(image.CGImage),
                                                    maxBytesPerRow,
                                                    CGImageGetColorSpace(image.CGImage),
                                                    (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                    );
    
  if (!referenceImageContext || !imageContext) {
    CGContextRelease(referenceImageContext);
    CGContextRelease(imageContext);
    free(referenceImagePixels);
    free(imagePixels);
    return NO;
  }
    
  CGContextDrawImage(referenceImageContext, CGRectMake(0.0f, 0.0f, referenceImage.size.width, referenceImage.size.height), referenceImage.CGImage);
  CGContextDrawImage(imageContext, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
  CGContextRelease(referenceImageContext);
  CGContextRelease(imageContext);
    
  BOOL imageEqual = (memcmp(referenceImagePixels, imagePixels, referenceImageSizeBytes) == 0);
  free(referenceImagePixels);
  free(imagePixels);
  return imageEqual;
}

@end
