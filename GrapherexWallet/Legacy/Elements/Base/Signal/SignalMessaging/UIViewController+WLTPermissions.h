//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (WLTPermissions)

- (void)wlt_askForCameraPermissions:(void (^)(BOOL granted))callback
    NS_SWIFT_NAME(wlt_askForCameraPermissions(callback:));

- (void)wlt_askForMediaLibraryPermissions:(void (^)(BOOL granted))callbackParam
    NS_SWIFT_NAME(wlt_askForMediaLibraryPermissions(callback:));

- (void)wlt_askForMicrophonePermissions:(void (^)(BOOL granted))callback
    NS_SWIFT_NAME(wlt_askForMicrophonePermissions(callback:));

- (void)wlt_showNoMicrophonePermissionActionSheet;

@end

NS_ASSUME_NONNULL_END
