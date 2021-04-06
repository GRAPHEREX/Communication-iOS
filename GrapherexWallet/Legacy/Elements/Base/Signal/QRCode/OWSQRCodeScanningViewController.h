//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>

NS_ASSUME_NONNULL_BEGIN

@class OWSQRCodeScanningViewController;

@protocol OWSQRScannerDelegate

@optional

- (void)controller:(OWSQRCodeScanningViewController *)controller didDetectQRCodeWithString:(NSString *)string;
- (void)controller:(OWSQRCodeScanningViewController *)controller didDetectQRCodeWithData:(NSData *)data;

@end

#pragma mark -
// MARK: - SINGAL DEPENDENCY – reimplement
// WLTViewController -> UIViewController
@interface OWSQRCodeScanningViewController: UIViewController <AVCaptureMetadataOutputObjectsDelegate, ZXCaptureDelegate>

@property (nonatomic, weak) UIViewController<OWSQRScannerDelegate> *scanDelegate;

- (void)startCapture;

@end

NS_ASSUME_NONNULL_END
