//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for SignalMessaging.
FOUNDATION_EXPORT double SignalMessagingVersionNumber;

//! Project version string for SignalMessaging.
FOUNDATION_EXPORT const unsigned char SignalMessagingVersionString[];

// The public headers of the framework
#import <StacleMessaging/AppSetup.h>
#import <StacleMessaging/AttachmentSharing.h>
#import <StacleMessaging/BlockListUIUtils.h>
#import <StacleMessaging/CVItemViewModel.h>
#import <StacleMessaging/ContactCellView.h>
#import <StacleMessaging/ContactTableViewCell.h>
#import <StacleMessaging/ContactsViewHelper.h>
#import <StacleMessaging/CountryCodeViewController.h>
#import <StacleMessaging/DebugLogger.h>
#import <StacleMessaging/Environment.h>
#import <StacleMessaging/OWSAnyTouchGestureRecognizer.h>
#import <StacleMessaging/OWSAudioPlayer.h>
#import <StacleMessaging/OWSBubbleShapeView.h>
#import <StacleMessaging/OWSBubbleView.h>
#import <StacleMessaging/OWSContactAvatarBuilder.h>
#import <StacleMessaging/OWSContactsManager.h>
#import <StacleMessaging/OWSConversationColor.h>
#import <StacleMessaging/OWSGroupAvatarBuilder.h>
#import <StacleMessaging/OWSMessageTextView.h>
#import <StacleMessaging/OWSNavigationController.h>
#import <StacleMessaging/OWSOrphanDataCleaner.h>
#import <StacleMessaging/OWSPreferences.h>
#import <StacleMessaging/OWSProfileManager.h>
#import <StacleMessaging/OWSQuotedReplyModel.h>
#import <StacleMessaging/OWSSearchBar.h>
#import <StacleMessaging/OWSSounds.h>
#import <StacleMessaging/OWSSyncManager.h>
#import <StacleMessaging/OWSTableViewController.h>
#import <StacleMessaging/OWSTextField.h>
#import <StacleMessaging/OWSTextView.h>
#import <StacleMessaging/OWSWindowManager.h>
#import <StacleMessaging/ScreenLockViewController.h>
#import <StacleMessaging/SelectThreadViewController.h>
#import <StacleMessaging/Theme.h>
#import <StacleMessaging/ThreadUtil.h>
#import <StacleMessaging/ThreadViewHelper.h>
#import <StacleMessaging/UIFont+OWS.h>
#import <StacleMessaging/UIUtil.h>
#import <StacleMessaging/UIView+OWS.h>
#import <StacleMessaging/UIViewController+OWS.h>
#import <StacleMessaging/UIViewController+Permissions.h>
#import <StacleMessaging/VersionMigrations.h>
#import <StacleMessaging/ViewControllerUtils.h>
#import <SignalServiceKit/OWSUserProfile.h>
#import <SignalServiceKit/UIImage+OWS.h>
