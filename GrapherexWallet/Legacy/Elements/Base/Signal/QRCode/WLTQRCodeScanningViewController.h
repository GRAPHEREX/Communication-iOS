//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>

NS_ASSUME_NONNULL_BEGIN

@class WLTQRCodeScanningViewController;

@protocol WLTQRScannerDelegate

@optional

- (void)controller:(WLTQRCodeScanningViewController *)controller didDetectQRCodeWithString:(NSString *)string;
- (void)controller:(WLTQRCodeScanningViewController *)controller didDetectQRCodeWithData:(NSData *)data;

@end

#pragma mark -
// MARK: - SINGAL DEPENDENCY – reimplement
// WLTViewController -> UIViewController
@interface WLTQRCodeScanningViewController: UIViewController <AVCaptureMetadataOutputObjectsDelegate, ZXCaptureDelegate>

@property (nonatomic, weak) UIViewController<WLTQRScannerDelegate> *scanDelegate;

- (void)startCapture;

@end

NS_ASSUME_NONNULL_END
