//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "AboutTableViewController.h"
#import "AdvancedSettingsTableViewController.h"
#import "DebugUITableViewController.h"
#import "NotificationSettingsViewController.h"
#import "OWSBackup.h"
#import "OWSBackupSettingsViewController.h"
#import "OWSNavigationController.h"
#import "PrivacySettingsTableViewController.h"
#import "Signal-Swift.h"
#import <SignalMessaging/Environment.h>
#import <SignalMessaging/OWSContactsManager.h>
#import <SignalMessaging/UIUtil.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <SignalServiceKit/TSAccountManager.h>
#import <SignalServiceKit/TSSocketManager.h>

@interface AppSettingsViewController ()

@property (nonatomic, readonly) OWSContactsManager *contactsManager;
@property (nonatomic, nullable) OWSInviteFlow *inviteFlow;

@end

#pragma mark -

@implementation AppSettingsViewController

/**
 * We always present the settings controller modally, from within an OWSNavigationController
 */
+ (OWSNavigationController *)inModalNavigationController
{
    AppSettingsViewController *viewController = [AppSettingsViewController new];
    OWSNavigationController *navController =
        [[OWSNavigationController alloc] initWithRootViewController:viewController];

    return navController;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return self;
    }

    _contactsManager = Environment.shared.contactsManager;

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)loadView
{
    self.tableViewStyle = UITableViewStylePlain;
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];

    OWSAssertDebug([self.navigationController isKindOfClass:[OWSNavigationController class]]);
    
    [self observeNotifications];

    [self updateTableContents];

    [self.bulkProfileFetch fetchProfileWithAddress:self.tsAccountManager.localAddress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self updateTableContents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Table Contents

- (void)updateTableContents
{
    OWSTableContents *contents = [OWSTableContents new];

    __weak AppSettingsViewController *weakSelf = self;

#ifdef INTERNAL
    OWSTableSection *internalSection = [OWSTableSection new];
    [section addItem:[OWSTableItem softCenterLabelItemWithText:@"Internal Build"]];
    [contents addSection:internalSection];
#endif

    OWSTableSection *section = [OWSTableSection new];
    OWSTableItem *profileHeaderItem = [OWSTableItem
        itemWithCustomCellBlock:^{ return [weakSelf profileHeaderCell]; }
        actionBlock:^{ [weakSelf showProfile]; }];
    profileHeaderItem.customRowHeight = @(100.f);
    [section addItem:profileHeaderItem];

//    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_INVITE_TITLE",
//                                                              @"Settings table view cell label")
//                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"invite")
//                                              actionBlock:^{
//                                                  [weakSelf showInviteFlow];
//                                              }]];

        [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_APPEARANCE_TITLE",
                                                                  @"The title for the appearance settings.")
                                      accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"appearance")
                                                  actionBlock:^{
                                                      [weakSelf showAppearance];
                                                  }]];

    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_PRIVACY_TITLE",
                                                              @"Settings table view cell label")
                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"privacy")
                                              actionBlock:^{
                                                  [weakSelf showPrivacy];
                                              }]];
    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_NOTIFICATIONS", nil)
                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"notifications")
                                              actionBlock:^{
        [weakSelf showNotifications];
    }]];

    // There's actually nothing AFAIK preventing linking another linked device from an
    // existing linked device, but maybe it's not something we want to expose until
    // after unifying the other experiences between secondary/primary devices.
//    if (self.tsAccountManager.isRegisteredPrimaryDevice) {
//        [section
//            addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"LINKED_DEVICES_TITLE",
//                                                             @"Menu item and navbar title for the device manager")
//                                 accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"linked_devices")
//                                             actionBlock:^{
//                                                 [weakSelf showLinkedDevices];
//                                             }]];
//    }
    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_DATA",
                                                                            @"Label for the 'data' section of the app settings.")
                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"data")
                                              actionBlock:^{
        [weakSelf showData];
    }]];
//    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_ADVANCED_TITLE", @"")
//                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"advanced")
//                                              actionBlock:^{
//                                                  [weakSelf showAdvanced];
//                                              }]];
//    BOOL isBackupEnabled = [OWSBackup.shared isBackupEnabled];
//    BOOL showBackup = (OWSBackup.isFeatureEnabled && isBackupEnabled);
//    if (showBackup) {
//        [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_BACKUP",
//                                                                  @"Label for the backup view in app settings.")
//                                      accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"backup")
//                                                  actionBlock:^{
//                                                      [weakSelf showBackup];
//                                                  }]];
//    }
//    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_HELP",
//                                                              @"Title for support page in app settings.")
//                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"help")
//                                              actionBlock:^{ [weakSelf showHelp]; }]];
    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_SUPPORT", @"")
                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"suppot")
                                              actionBlock:^{
                                                  [weakSelf showSupport];
                                              }]];
//    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_FAQ", @"")
//                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"faq")
//                                              actionBlock:^{
//                                                  [weakSelf showFAQ];
//                                              }]];
    [section addItem:[OWSTableItem disclosureItemWithText:NSLocalizedString(@"SETTINGS_ABOUT", @"")
                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"about")
                                              actionBlock:^{
                                                  [weakSelf showAbout];
                                              }]];
//    [section addItem:[OWSTableItem actionItemWithText:NSLocalizedString(@"SETTINGS_DONATE",
//                                                          @"Title for the 'donate to signal' link in settings.")
//                                       accessoryImage:[UIImage imageNamed:@"open-externally-14"]
//                              accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"donate")
//                                          actionBlock:^{
//                                              [UIApplication.sharedApplication
//                                                            openURL:[NSURL URLWithString:@"https://grapherex.com"]
//                                                            options:@{}
//                                                  completionHandler:nil];
//                                          }]];

#ifdef USE_DEBUG_UI
    [section addItem:[OWSTableItem disclosureItemWithText:@"Debug UI"
                                  accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"debugui")
                                              actionBlock:^{
                                                  [weakSelf showDebugUI];
                                              }]];
#endif

    [contents addSection:section];

    self.contents = contents;
}

- (UITableViewCell *)profileHeaderCell
{
    UITableViewCell *cell = [OWSTableItem newCell];
    cell.preservesSuperviewLayoutMargins = YES;
    cell.contentView.preservesSuperviewLayoutMargins = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIImage *_Nullable localProfileAvatarImage = [OWSProfileManager.shared localProfileAvatarImage];
    UIImage *avatarImage = (localProfileAvatarImage
            ?: [[[OWSContactAvatarBuilder alloc] initForLocalUserWithDiameter:kMediumAvatarSize] buildDefaultImage]);
    OWSAssertDebug(avatarImage);

    AvatarImageView *avatarView = [[AvatarImageView alloc] initWithImage:avatarImage];
    [cell.contentView addSubview:avatarView];
    [avatarView autoVCenterInSuperview];
    [avatarView autoPinLeadingToSuperviewMargin];
    [avatarView autoSetDimension:ALDimensionWidth toSize:kMediumAvatarSize];
    [avatarView autoSetDimension:ALDimensionHeight toSize:kMediumAvatarSize];

    if (!localProfileAvatarImage) {
        UIImageView *cameraImageView = [UIImageView new];
        [cameraImageView setTemplateImageName:@"camera-outline-24" tintColor:Theme.secondaryTextAndIconColor];
        [cell.contentView addSubview:cameraImageView];

        [cameraImageView autoSetDimensionsToSize:CGSizeMake(32, 32)];
        cameraImageView.contentMode = UIViewContentModeCenter;
        cameraImageView.backgroundColor = Theme.backgroundColor;
        cameraImageView.layer.cornerRadius = 16;
        cameraImageView.layer.shadowColor =
            [(Theme.isDarkThemeEnabled ? Theme.darkThemeWashColor : Theme.primaryTextColor) CGColor];
        cameraImageView.layer.shadowOffset = CGSizeMake(1, 1);
        cameraImageView.layer.shadowOpacity = 0.5;
        cameraImageView.layer.shadowRadius = 4;

        [cameraImageView autoPinTrailingToEdgeOfView:avatarView];
        [cameraImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:avatarView];
    }

    UIView *nameView = [UIView containerView];
    [cell.contentView addSubview:nameView];
    [nameView autoVCenterInSuperview];
    [nameView autoPinLeadingToTrailingEdgeOfView:avatarView offset:16.f];

    UILabel *titleLabel = [UILabel new];
    NSString *_Nullable localProfileName = [OWSProfileManager.shared localFullName];
    if (localProfileName.length > 0) {
        titleLabel.text = localProfileName;
        titleLabel.textColor = Theme.primaryTextColor;
        titleLabel.font = [UIFont ows_dynamicTypeTitle2Font];
    } else {
        titleLabel.text = NSLocalizedString(
            @"APP_SETTINGS_EDIT_PROFILE_NAME_PROMPT", @"Text prompting user to edit their profile name.");
        titleLabel.textColor = Theme.accentBlueColor;
        titleLabel.font = [UIFont ows_dynamicTypeHeadlineFont];
    }
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [nameView addSubview:titleLabel];
    [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [titleLabel autoPinWidthToSuperview];

    __block UIView *lastTitleView = titleLabel;
    const CGFloat kSubtitlePointSize = 12.f;
    void (^addSubtitle)(NSString *) = ^(NSString *subtitle) {
        UILabel *subtitleLabel = [UILabel new];
        subtitleLabel.textColor = Theme.secondaryTextAndIconColor;
        subtitleLabel.font = [UIFont ows_regularFontWithSize:kSubtitlePointSize];
        subtitleLabel.text = subtitle;
        subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [nameView addSubview:subtitleLabel];
        [subtitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastTitleView];
        [subtitleLabel autoPinLeadingToSuperviewMargin];
        lastTitleView = subtitleLabel;
    };

    addSubtitle(
        [PhoneNumber bestEffortFormatPartialUserSpecifiedTextToLookLikeAPhoneNumber:[TSAccountManager localNumber]]);

    NSString *_Nullable username = [OWSProfileManager.shared localUsername];
    if (username.length > 0) {
        addSubtitle([CommonFormats formatUsername:username]);
    }

    [lastTitleView autoPinEdgeToSuperviewEdge:ALEdgeBottom];

    UIImage *disclosureImage = [UIImage imageNamed:(CurrentAppContext().isRTL ? @"NavBarBack" : @"NavBarBackRTL")];
    OWSAssertDebug(disclosureImage);
    UIImageView *disclosureButton =
        [[UIImageView alloc] initWithImage:[disclosureImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    disclosureButton.tintColor = [UIColor colorWithRGBHex:0xcccccc];
    [cell.contentView addSubview:disclosureButton];
    [disclosureButton autoVCenterInSuperview];
    [disclosureButton autoPinTrailingToSuperviewMargin];
    [disclosureButton autoPinLeadingToTrailingEdgeOfView:nameView offset:16.f];
    [disclosureButton setContentCompressionResistancePriority:(UILayoutPriorityDefaultHigh + 1)
                                                      forAxis:UILayoutConstraintAxisHorizontal];

    cell.accessibilityIdentifier = ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"profile");

    return cell;
}

- (void)showInviteFlow
{
    OWSInviteFlow *inviteFlow = [[OWSInviteFlow alloc] initWithPresentingViewController:self];
    self.inviteFlow = inviteFlow;
    [inviteFlow presentWithIsAnimated:YES completion:nil];
}

- (void)showPrivacy
{
    PrivacySettingsTableViewController *vc = [[PrivacySettingsTableViewController alloc] init];
    [self pushViewController:vc];
}

- (void)showAppearance
{
    AppearanceSettingsTableViewController *vc = [AppearanceSettingsTableViewController new];
    [self pushViewController:vc];
}

- (void)showNotifications
{
    NotificationSettingsViewController *vc = [[NotificationSettingsViewController alloc] init];
    [self pushViewController:vc];
}

- (void)showLinkedDevices
{
    LinkedDevicesTableViewController *vc = [LinkedDevicesTableViewController new];
    [self pushViewController:vc];
}

- (void)showProfile
{
    MyProfileViewController* vc = [[MyProfileViewController alloc] init];
    vc.completionHandler = ^(MyProfileViewController *completedVC) {
        [completedVC.navigationController popViewControllerAnimated:YES];
    };

    [self pushViewController:vc];
}

- (void)showData
{
    DataSettingsTableViewController *vc = [[DataSettingsTableViewController alloc] init];
    [self pushViewController:vc];
}

- (void)showAdvanced
{
    AdvancedSettingsTableViewController *vc = [[AdvancedSettingsTableViewController alloc] init];
    [self pushViewController:vc];
}

- (void)showHelp
{
    OWSHelpViewController *vc = [[OWSHelpViewController alloc] init];
    [self pushViewController:vc];
}

- (void)showSupport
{
    WebViewController *vc = [[WebViewController alloc] init];
    [vc setTitle:NSLocalizedString(@"SETTINGS_SUPPORT", nil)];
    [vc setLink:@"https://support.grapherex.com/hc/en-150"];
    [self pushViewController:vc];
}

- (void)showFAQ
{
    WebViewController *vc = [[WebViewController alloc] init];
    [vc setTitle:NSLocalizedString(@"SETTINGS_FAQ", nil)];
    [vc setLink:@"https://grapherex.com/faq/en"];
    [self pushViewController:vc];
}

- (void)showAbout
{
    AboutTableViewController *vc = [[AboutTableViewController alloc] init];
    [self pushViewController:vc];
}

- (void)showBackup
{
    OWSBackupSettingsViewController *vc = [OWSBackupSettingsViewController new];
    [self pushViewController:vc];
}

#ifdef USE_DEBUG_UI
- (void)showDebugUI
{
    [DebugUITableViewController presentDebugUIFromViewController:self];
}
#endif

- (void)dismissWasPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Dark Theme

- (UIBarButtonItem *)darkThemeBarButton
{
    UIBarButtonItem *barButtonItem;
    if (Theme.isDarkThemeEnabled) {
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_dark_theme_on"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(didPressDisableDarkTheme:)];
    } else {
        barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_dark_theme_off"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(didPressEnableDarkTheme:)];
    }
    barButtonItem.accessibilityIdentifier = ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"dark_theme");
    return barButtonItem;
}

- (void)didPressEnableDarkTheme:(id)sender
{
    [Theme setCurrentTheme:ThemeMode_Dark];
    [self updateTableContents];
}

- (void)didPressDisableDarkTheme:(id)sender
{
    [Theme setCurrentTheme:ThemeMode_Light];
    [self updateTableContents];
}

- (void)pushViewController:(UIViewController *)vc {
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notifications

- (void)observeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localProfileDidChange:)
                                                 name:kNSNotificationNameLocalProfileDidChange
                                               object:nil];
}

- (void)localProfileDidChange:(id)notification
{
    OWSAssertIsOnMainThread();

    [self updateTableContents];
}

@end
