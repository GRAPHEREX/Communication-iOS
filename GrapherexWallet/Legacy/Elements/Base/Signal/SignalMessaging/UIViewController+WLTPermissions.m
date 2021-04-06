//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "UIViewController+WLTPermissions.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
//#import <SignalCoreKit/Threading.h>
#import <GrapherexWallet/GrapherexWallet-Swift.h>
//#import <SignalMessaging/UIUtil.h>

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (WLTPermissions)

- (void)wlt_askForCameraPermissions:(void (^)(BOOL granted))callbackParam
{
    //OWSLogVerbose(@"[%@] wlt_askForCameraPermissions", NSStringFromClass(self.class));

    // Ensure callback is invoked on main thread.
    void (^callback)(BOOL) = ^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callbackParam(granted);
        });
    };

    // MARK: - SINGAL DEPENDENCY – reimplement
//    if (CurrentAppContext().reportedApplicationState == UIApplicationStateBackground) {
        //OWSLogError(@"Skipping camera permissions request when app is in background.");
//        callback(NO);
//        return;
//    }

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        /*&& !Platform.isSimulator*/) {
        //OWSLogError(@"Camera ImagePicker source not available");
        callback(NO);
        return;
    }

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        WTLActionSheetController *alert = [[WTLActionSheetController alloc]
            initWithTitle:NSLocalizedString(@"MISSING_CAMERA_PERMISSION_TITLE", @"Alert title")
                  message:NSLocalizedString(@"MISSING_CAMERA_PERMISSION_MESSAGE", @"Alert body")];

//        ActionSheetAction *_Nullable openSettingsAction = [CurrentAppContext() openSystemSettingsActionWithCompletion:^{
//            callback(NO);
//        }];
//        if (openSettingsAction != nil) {
//            [alert addAction:openSettingsAction];
//        }

//        WLTActionSheetAction *dismissAction = [[WLTActionSheetAction alloc] initWithTitle:@"Dismiss"
//                                                                              style:WLTActionSheetActionStyleCancel
//                                                                               handler:^( *action) {
//                                                                                callback(NO);
//                                                                            }];
        
//        [alert addAction:dismissAction];

        [self presentActionSheet:alert];
    } else if (status == AVAuthorizationStatusAuthorized) {
        callback(YES);
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:callback];
    } else {
        //OWSLogError(@"Unknown AVAuthorizationStatus: %ld", (long)status);
        callback(NO);
    }
}

- (void)wlt_askForMediaLibraryPermissions:(void (^)(BOOL granted))callbackParam
{
    //OWSLogVerbose(@"[%@] wlt_askForMediaLibraryPermissions", NSStringFromClass(self.class));

    // Ensure callback is invoked on main thread.
    void (^completionCallback)(BOOL) = ^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callbackParam(granted);
        });
    };

    void (^presentSettingsDialog)(void) = ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WTLActionSheetController *alert = [[WTLActionSheetController alloc]
                initWithTitle:NSLocalizedString(@"MISSING_MEDIA_LIBRARY_PERMISSION_TITLE",
                                  @"Alert title when user has previously denied media library access")
                      message:NSLocalizedString(@"MISSING_MEDIA_LIBRARY_PERMISSION_MESSAGE",
                                  @"Alert body when user has previously denied media library access")];

//            ActionSheetAction *_Nullable openSettingsAction =
            // MARK: - SINGAL DEPENDENCY – reimplement
//                [CurrentAppContext() openSystemSettingsActionWithCompletion:^() {
//                    completionCallback(NO);
//                }];
//            if (openSettingsAction) {
//                [alert addAction:openSettingsAction];
//            }

//            WTLActionSheetAction *dismissAction = [[WTLActionSheetAction alloc] initWithTitle:@"Dismiss"
//                                                                                  style:WLTActionSheetActionStyleCancel
//                                                                                      handler:^( *action) {
//                                                                                    completionCallback(NO);
//                                                                                }];
//            [alert addAction:dismissAction];

            [self presentActionSheet:alert];
        });
    };

    // MARK: - SINGAL DEPENDENCY – reimplement
//    if (CurrentAppContext().reportedApplicationState == UIApplicationStateBackground) {
//        //OWSLogError(@"Skipping media library permissions request when app is in background.");
//        completionCallback(NO);
//        return;
//    }

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //OWSLogError(@"PhotoLibrary ImagePicker source not available");
        completionCallback(NO);
    }

    // TODO Xcode 12: When we're compiling on in Xcode 12, adjust this to
    // use the new non-deprecated API that returns the "limited" status.
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    switch (status) {
        case PHAuthorizationStatusAuthorized: {
            completionCallback(YES);
            return;
        }
        case PHAuthorizationStatusDenied: {
            presentSettingsDialog();
            return;
        }
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
                if (newStatus == PHAuthorizationStatusAuthorized) {
                    completionCallback(YES);
                } else {
                    presentSettingsDialog();
                }
            }];
            return;
        }
        case PHAuthorizationStatusRestricted: {
            // when does this happen?
            //OWSFailDebug(@"PHAuthorizationStatusRestricted");
            return;
        }
        case PHAuthorizationStatusLimited: {
            completionCallback(YES);
            return;
        }
    }
}

- (void)wlt_askForMicrophonePermissions:(void (^)(BOOL granted))callbackParam
{
    //OWSLogVerbose(@"[%@] wlt_askForMicrophonePermissions", NSStringFromClass(self.class));

    // Ensure callback is invoked on main thread.
    void (^callback)(BOOL) = ^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callbackParam(granted);
        });
    };

    // MARK: - SINGAL DEPENDENCY – reimplement
    // We want to avoid asking for audio permission while the app is in the background,
    // as WebRTC can ask at some strange times. However, if we're currently in a call
    // it's important we allow you to request audio permission regardless of app state.
//    if (CurrentAppContext().reportedApplicationState == UIApplicationStateBackground
//        && !OWSWindowManager.shared.hasCall) {
        //OWSLogError(@"Skipping microphone permissions request when app is in background.");
//        callback(NO);
//        return;
//    }

    [[AVAudioSession sharedInstance] requestRecordPermission:callback];
}

- (void)wlt_showNoMicrophonePermissionActionSheet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        WTLActionSheetController *alert = [[WTLActionSheetController alloc]
            initWithTitle:NSLocalizedString(@"CALL_AUDIO_PERMISSION_TITLE",
                              @"Alert title when calling and permissions for microphone are missing")
                  message:NSLocalizedString(@"CALL_AUDIO_PERMISSION_MESSAGE",
                              @"Alert message when calling and permissions for microphone are missing")];

        // MARK: - SINGAL DEPENDENCY – reimplement
//        ActionSheetAction *_Nullable openSettingsAction =
//            [CurrentAppContext() openSystemSettingsActionWithCompletion:nil];
//        if (openSettingsAction) {
//            [alert addAction:openSettingsAction];
//        }

//        [alert addAction:OWSActionSheets.dismissAction];

        [self presentActionSheet:alert];
    });
}

@end

NS_ASSUME_NONNULL_END
