//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "ProfileRegistrationViewController.h"
#import "AppDelegate.h"
#import "AvatarViewHelper.h"
#import "ConversationListViewController.h"
#import "OWSNavigationController.h"
#import "Signal-Swift.h"
#import "UIFont+OWS.h"
#import "UIView+OWS.h"
#import <PromiseKit/AnyPromise.h>
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalCoreKit/NSString+OWS.h>
#import <SignalMessaging/OWSNavigationController.h>
#import <SignalMessaging/OWSProfileManager.h>
#import <SignalMessaging/SignalMessaging-Swift.h>
#import <SignalMessaging/UIUtil.h>
#import <SignalMessaging/UIViewController+OWS.h>

@import SafariServices;

NS_ASSUME_NONNULL_BEGIN

NSString *const kProfileRegistrationView_LastPresentedDate = @"kProfileRegistrationView_LastPresentedDate";

@interface ProfileRegistrationViewController () <UITextFieldDelegate, AvatarViewHelperDelegate>

@property (nonatomic, readonly) AvatarViewHelper *avatarViewHelper;

@property (strong, nonatomic) IBOutlet AvatarImageView *avatarView;
@property (strong, nonatomic) IBOutlet UIView *displayNameContainer;
@property (strong, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (strong, nonatomic) IBOutlet STPrimaryButton *saveButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageCameraView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, nullable) NSData *avatarData;

@property (nonatomic) void (^completionHandler)(ProfileRegistrationViewController *);

@end

#pragma mark -

@implementation ProfileRegistrationViewController

#pragma mark - Dependencies

+ (SDSDatabaseStorage *)databaseStorage
{
    return SDSDatabaseStorage.shared;
}

+ (SDSKeyValueStore *)keyValueStore
{
    return [[SDSKeyValueStore alloc] initWithCollection:@"kProfileRegistrationView_Collection"];
}

- (id<SSKReachabilityManager>)reachabilityManager
{
    return SSKEnvironment.shared.reachabilityManager;
}

#pragma mark -

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return self;
    }

    DatabaseStorageWrite(self.databaseStorage, ^(SDSAnyWriteTransaction *transaction) {
        [ProfileRegistrationViewController.keyValueStore setDate:[NSDate new]
                                                 key:kProfileRegistrationView_LastPresentedDate
                                         transaction:transaction];
    });

    return self;
}

- (void)updateСompletionHandler:(void (^)(ProfileRegistrationViewController *))completionHandler {
    self.completionHandler = completionHandler;
}

- (void)loadView
{
    [super loadView];

    self.title = NSLocalizedString(@"PROFILE_VIEW_TITLE", @"Title for the profile view.");

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _avatarViewHelper = [AvatarViewHelper new];
    _avatarViewHelper.delegate = self;

    _avatarData = [OWSProfileManager.shared localProfileAvatarData];

    [self.imageCameraView setBackgroundColor:UIColor.st_accentGreen];
    self.imageCameraView.layer.cornerRadius = self.imageCameraView.frame.size.height / 2;
    
    [self configureViews];
    [self setupKeyboardNotifications];
}

- (void)configureViews
{
    self.view.backgroundColor = Theme.backgroundColor;
    self.displayNameContainer.backgroundColor = [UIColor st_neutralGrayMessege];
    self.displayNameContainer.layer.cornerRadius = 10;
    self.descriptionLabel.font = [UIFont st_sfUiTextRegularFontWithSize:16];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.text = NSLocalizedString(@"PROFILE_VIEW_GIVEN_NAME_DESCRIPTION_TEXT", @"");
    
    // Avatar
    
    [self.avatarView setUserInteractionEnabled:YES];
    [self.avatarView addGestureRecognizer:[
        [UITapGestureRecognizer alloc] initWithTarget:self                                                                         action:@selector(avatarViewTapped:)
    ]];
    self.avatarView.backgroundColor = UIColor.st_accentGreen;
    self.avatarView.layer.cornerRadius = self.avatarSize/2;
    
    [self updateAvatarView];
    
    // Given Name

    [self.displayNameTextField addGestureRecognizer:
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                        action:@selector(displayNameRowTapped:)
    ]];
    self.displayNameTextField.borderStyle = UITextBorderStyleNone;
    self.displayNameTextField.backgroundColor = [UIColor clearColor];
    self.displayNameTextField.returnKeyType = UIReturnKeyNext;
    self.displayNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.displayNameTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.displayNameTextField.font = [UIFont ows_dynamicTypeBodyClampedFont];
    self.displayNameTextField.textColor = Theme.lightThemePrimaryColor;
    self.displayNameTextField.placeholder = NSLocalizedString(
        @"PROFILE_VIEW_GIVEN_NAME_DEFAULT_TEXT", @"Default text for the given name field of the profile view.");
    self.displayNameTextField.delegate = self;
    self.displayNameTextField.text = OWSProfileManager.shared.localGivenName;
    [self changeStyle:self.displayNameTextField.text.length > 0];
    // Big Button
    [self.saveButton setTitle:NSLocalizedString(@"PROFILE_VIEW_SAVE_BUTTON", @"")
                     forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.displayNameTextField becomeFirstResponder];
    });
}

- (void)avatarTapped
{
    [self.avatarViewHelper showChangeAvatarUI];
}

- (IBAction)saveButtonPressed:(id)sender {
    [self updateProfile];
}

- (void)updateProfile
{
    __weak ProfileRegistrationViewController *weakSelf = self;

    NSString *normalizedGivenName = [self normalizedGivenName];

    if (normalizedGivenName.length <= 0) {
        [OWSActionSheets showErrorAlertWithMessage:
                             NSLocalizedString(@"PROFILE_VIEW_ERROR_GIVEN_NAME_REQUIRED",
                                 @"Error message shown when user tries to update profile without a given name")];
        return;
    }

    if ([OWSProfileManager.shared isProfileNameTooLong:normalizedGivenName]) {
        [OWSActionSheets
            showErrorAlertWithMessage:NSLocalizedString(@"PROFILE_VIEW_ERROR_GIVEN_NAME_TOO_LONG",
                                          @"Error message shown when user tries to update profile with a given name "
                                          @"that is too long.")];
        return;
    }

    if (!self.reachabilityManager.isReachable) {
        [OWSActionSheets
            showErrorAlertWithMessage:
                NSLocalizedString(@"PROFILE_VIEW_NO_CONNECTION",
                    @"Error shown when the user tries to update their profile when the app is not connected to the "
                    @"internet.")];
        return;
    }

    // Show an activity indicator to block the UI during the profile upload.
    [ModalActivityIndicatorViewController
        presentFromViewController:self
                        canCancel:NO
                  backgroundBlock:^(ModalActivityIndicatorViewController *modalActivityIndicator) {
                      [OWSProfileManager updateLocalProfilePromiseWithProfileGivenName:normalizedGivenName
                                                                     profileFamilyName:@""
                                                                            profileBio:nil
                                                                       profileBioEmoji:nil
                                                                     profileAvatarData:weakSelf.avatarData]

                              .then(^{
                                  [modalActivityIndicator dismissWithCompletion:^{
                                      [weakSelf updateProfileCompleted];

//                                      // Clear the profile name experience upgrade if the user edits their profile name,
//                                      // even if they didn't dismiss the reminder directly.
//                                      [ProfileRegistrationViewController.databaseStorage
//                                          asyncWriteWithBlock:^(SDSAnyWriteTransaction *transaction) {
//                                              [ExperienceUpgradeManager
//                                                  clearProfileNameReminderWithTransaction:transaction.unwrapGrdbWrite];
//                                          }];
                                  }];
                              })
                              .catch(^(NSError *error) {
                                  //OWSFailDebug(@"Error: %@", error);

                                  [modalActivityIndicator dismissWithCompletion:^{
                                      // Don't show an error alert; the profile update
                                      // is enqueued and will be completed later.
                                      [weakSelf updateProfileCompleted];
                                  }];
                              });
                  }];
}

- (NSString *)normalizedGivenName
{
    return [self.displayNameTextField.text ows_stripped];
}

- (void)updateProfileCompleted
{
    OWSLogVerbose(@"");
    [self profileCompleted];
}

- (void)profileCompleted
{
    OWSLogVerbose(@"");
    self.completionHandler(self);
}

- (void)showConversationSplitView
{
    OWSAssertIsOnMainThread();
    OWSLogVerbose(@"");
    [SignalApp.shared showConversationSplitView];
}

- (void)setupKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)handleKeyboardNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *_Nullable keyboardEndFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [keyboardEndFrameValue CGRectValue];
    CGRect keyboardEndFrameConverted = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    BOOL isKeyboardShowing = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    CGFloat bottomPadding = [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom;
    if (isKeyboardShowing) {
        [self.bottomConstraint setActive:NO];
        self.bottomConstraint.constant = keyboardEndFrameConverted.size.height - bottomPadding + 16;
        [self.bottomConstraint setActive:YES];
        [UIView animateWithDuration:0.25 animations: ^{
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.bottomConstraint setActive:NO];
        self.bottomConstraint.constant = 16;
        [self.bottomConstraint setActive:YES];
        [UIView animateWithDuration:0.25 animations: ^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)changeStyle:(BOOL)isFilled {
    [self.saveButton handleEnabled:isFilled];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)editingRange
                replacementString:(NSString *)insertionText
{
    NSString *userEnteredString = textField.text;
    NSString *newString = [userEnteredString stringByReplacingCharactersInRange:editingRange
                                                                     withString:insertionText];
    [self changeStyle:(newString.length > 0)];

    return [TextFieldHelper textField:textField
        shouldChangeCharactersInRange:editingRange
                    replacementString:insertionText
                         maxByteCount:kOWSProfileManager_NameDataLength];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Avatar

- (void)setAvatarImage:(nullable UIImage *)avatarImage
{
    OWSAssertIsOnMainThread();
    NSData *_Nullable avatarData = nil;
    if (avatarImage != nil) {
        avatarData = [OWSProfileManager avatarDataForAvatarImage:avatarImage];
    }
    _avatarData = avatarData;
    [self updateAvatarView];
}

- (NSUInteger)avatarSize
{
    return 96;
}

- (void)updateAvatarView
{
    if (self.avatarData != nil) {
        self.avatarView.image = [UIImage imageWithData:self.avatarData];
        self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageCameraView setHidden:NO];
    } else {
        self.avatarView.image = [UIImage imageNamed:@"profile_camera_large"];
        self.avatarView.contentMode = UIViewContentModeCenter;
        [self.imageCameraView setHidden:YES];
    }
}

- (void)displayNameRowTapped:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self.displayNameTextField becomeFirstResponder];
    }
}

- (void)dismissKeyboard
{
    [self.view endEditing:true];
}

- (void)usernameRowTapped:(UIGestureRecognizer *)sender
{
    UsernameViewController *usernameVC = [UsernameViewController new];
    usernameVC.modalPresentation = YES;
    [self presentFormSheetViewController:[[OWSNavigationController alloc] initWithRootViewController:usernameVC]
                                animated:YES
                              completion:nil];
}

- (BOOL)shouldShowUsernameRow
{
    return false;
}

- (void)avatarViewTapped:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self avatarTapped];
    }
}

#pragma mark - AvatarViewHelperDelegate

+ (BOOL)shouldDisplayProfileViewOnLaunch
{
    if ([OWSProfileManager shared].localGivenName.length > 0) {
        return NO;
    }

    NSTimeInterval kProfileNagFrequency = kDayInterval * 30;
    __block NSDate *_Nullable lastPresentedDate;
    [self.databaseStorage readWithBlock:^(SDSAnyReadTransaction *transaction) {
        lastPresentedDate =
            [ProfileRegistrationViewController.keyValueStore getDate:kProfileRegistrationView_LastPresentedDate transaction:transaction];
    }];

    return (!lastPresentedDate || fabs([lastPresentedDate timeIntervalSinceNow]) > kProfileNagFrequency);
}

#pragma mark - AvatarViewHelperDelegate

- (nullable NSString *)avatarActionSheetTitle
{
    return NSLocalizedString(
        @"PROFILE_VIEW_AVATAR_ACTIONSHEET_TITLE", @"Action Sheet title prompting the user for a profile avatar");
}

- (void)avatarDidChange:(UIImage *)image
{
    OWSAssertIsOnMainThread();
    OWSAssertDebug(image);

    [self setAvatarImage:[image resizedImageToFillPixelSize:CGSizeMake(kOWSProfileManager_MaxAvatarDiameter,
                                                                kOWSProfileManager_MaxAvatarDiameter)]];
}

- (UIViewController *)fromViewController
{
    return self;
}

- (BOOL)hasClearAvatarAction
{
    return self.avatarData != nil;
}

- (NSString *)clearAvatarActionLabel
{
    return NSLocalizedString(@"PROFILE_VIEW_CLEAR_AVATAR", @"Label for action that clear's the user's profile avatar");
}

- (void)clearAvatar
{
    [self setAvatarImage:nil];
}

@end

NS_ASSUME_NONNULL_END
