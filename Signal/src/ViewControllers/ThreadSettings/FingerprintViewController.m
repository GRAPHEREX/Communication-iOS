//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "FingerprintViewController.h"
#import "FingerprintViewScanController.h"
#import "OWSBezierPathView.h"
#import "Signal-Swift.h"
#import "UIFont+OWS.h"
#import "UIView+OWS.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalMessaging/Environment.h>
#import <SignalMessaging/OWSContactsManager.h>
#import <SignalMessaging/UIUtil.h>
#import <SignalServiceKit/OWSError.h>
#import <SignalServiceKit/OWSFingerprint.h>
#import <SignalServiceKit/OWSFingerprintBuilder.h>
#import <SignalServiceKit/OWSIdentityManager.h>
#import <SignalServiceKit/TSAccountManager.h>
#import <SignalServiceKit/TSInfoMessage.h>

@import SafariServices;

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@implementation CustomLayoutView

- (instancetype)init
{
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.layoutBlock();
}

@end

#pragma mark -

@interface FingerprintViewController () <OWSCompareSafetyNumbersActivityDelegate>

@property (nonatomic) SignalServiceAddress *address;
@property (nonatomic) NSData *identityKey;
@property (nonatomic) TSAccountManager *accountManager;
@property (nonatomic) OWSFingerprint *fingerprint;
@property (nonatomic) NSString *contactName;

@property (nonatomic) UIBarButtonItem *shareButton;

@property (nonatomic) UILabel *verificationStateLabel;
@property (nonatomic) UIButton *verifyUnverifyButton;
@property (nonatomic) UIImageView *stateImageView;
@end

#pragma mark -

@implementation FingerprintViewController

#pragma mark - Dependencies

- (SDSDatabaseStorage *)databaseStorage
{
    return SDSDatabaseStorage.shared;
}

#pragma mark -

+ (void)presentFromViewController:(UIViewController *)viewController address:(SignalServiceAddress *)address
{
    OWSAssertDebug(address.isValid);

    OWSRecipientIdentity *_Nullable recipientIdentity =
        [[OWSIdentityManager shared] recipientIdentityForAddress:address];
    if (!recipientIdentity) {
        [OWSActionSheets showActionSheetWithTitle:NSLocalizedString(@"CANT_VERIFY_IDENTITY_ALERT_TITLE",
                                                      @"Title for alert explaining that a user cannot be verified.")
                                          message:NSLocalizedString(@"CANT_VERIFY_IDENTITY_ALERT_MESSAGE",
                                                      @"Message for alert explaining that a user cannot be verified.")];
        return;
    }

    FingerprintViewController *fingerprintViewController = [FingerprintViewController new];
    [fingerprintViewController configureWithAddress:address];
    OWSNavigationController *navigationController =
        [[OWSNavigationController alloc] initWithRootViewController:fingerprintViewController];
    [viewController presentFormSheetViewController:navigationController animated:YES completion:nil];
}

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return self;
    }

    _accountManager = [TSAccountManager shared];

    [self observeNotifications];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(identityStateDidChange:)
                                                 name:kNSNotificationNameIdentityStateDidChange
                                               object:nil];
}

- (void)configureWithAddress:(SignalServiceAddress *)address
{
    OWSAssertDebug(address.isValid);

    self.address = address;

    OWSContactsManager *contactsManager = Environment.shared.contactsManager;
    self.contactName = [contactsManager displayNameForAddress:address];

    OWSRecipientIdentity *_Nullable recipientIdentity =
        [[OWSIdentityManager shared] recipientIdentityForAddress:address];
    OWSAssertDebug(recipientIdentity);
    // By capturing the identity key when we enter these views, we prevent the edge case
    // where the user verifies a key that we learned about while this view was open.
    self.identityKey = recipientIdentity.identityKey;

    OWSFingerprintBuilder *builder =
        [[OWSFingerprintBuilder alloc] initWithAccountManager:self.accountManager contactsManager:contactsManager];
    self.fingerprint = [builder fingerprintWithTheirSignalAddress:address
                                                 theirIdentityKey:recipientIdentity.identityKey];
}

- (void)loadView
{
    [super loadView];

    self.title = NSLocalizedString(@"MAIN_PROFILE", @"Navbar title");

    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                      target:self
                                                      action:@selector(closeButton)
                                     accessibilityIdentifier:ACCESSIBILITY_IDENTIFIER_WITH_NAME(self, @"stop")];

    [self createViews];
}

- (void)createViews
{
    self.view.backgroundColor = Theme.backgroundColor;

    // Verify/Unverify Button
    self.stateImageView = [UIImageView new];
    self.stateImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.verificationStateLabel = [UILabel new];
    [self updateVerification];

    // Learn More
    UIView *learnMoreButton = [UIView new];
    [learnMoreButton
        addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(learnMoreButtonTapped:)]];
    [self.view addSubview:learnMoreButton];
    [learnMoreButton autoPinWidthToSuperview];
    [learnMoreButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.verifyUnverifyButton withOffset:-8];
    SET_SUBVIEW_ACCESSIBILITY_IDENTIFIER(self, learnMoreButton);

    UILabel *learnMoreLabel = [UILabel new];
    learnMoreLabel.hidden = YES;
    learnMoreLabel.text = CommonStrings.learnMore;
    learnMoreLabel.font = [UIFont ows_regularFontWithSize:ScaleFromIPhone5To7Plus(13.f, 16.f)];
    learnMoreLabel.textColor = UIColor.st_otherBlue;
    learnMoreLabel.textAlignment = NSTextAlignmentCenter;
    [learnMoreButton addSubview:learnMoreLabel];
    [learnMoreLabel autoPinWidthToSuperviewWithMargin:16.f];
    [learnMoreLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:ScaleFromIPhone5To7Plus(5.f, 10.f)];
    [learnMoreLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:ScaleFromIPhone5To7Plus(5.f, 10.f)];

    // Instructions
    NSString *instructionsFormat = NSLocalizedString(@"PRIVACY_VERIFICATION_INSTRUCTIONS",
        @"Paragraph(s) shown alongside the safety number when verifying privacy with {{contact name}}");
    UILabel *instructionsLabel = [UILabel new];
    instructionsLabel.text = [NSString stringWithFormat:instructionsFormat, self.contactName];
    instructionsLabel.font = [UIFont st_sfUiTextRegularFontWithSize:14];
    instructionsLabel.textColor = Theme.primaryTextColor;
    instructionsLabel.textAlignment = NSTextAlignmentCenter;
    instructionsLabel.numberOfLines = 0;
    instructionsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:instructionsLabel];
    [instructionsLabel autoPinLeadingToEdgeOfView:self.view offset:32];
    [instructionsLabel autoPinTrailingToEdgeOfView:self.view offset:-32];
    [instructionsLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:learnMoreButton withOffset:-8];

    // Fingerprint Label
    UILabel *fingerprintLabel = [UILabel new];
    fingerprintLabel.text = self.fingerprint.displayableText;
    fingerprintLabel.font = [UIFont st_sfUiTextSemiboldFontWithSize:16];
    fingerprintLabel.textAlignment = NSTextAlignmentCenter;
    fingerprintLabel.textColor = Theme.primaryTextColor;
    fingerprintLabel.numberOfLines = 3;
    fingerprintLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    fingerprintLabel.adjustsFontSizeToFitWidth = YES;
    [fingerprintLabel
        addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(fingerprintLabelTapped:)]];
    fingerprintLabel.userInteractionEnabled = YES;
    [self.view addSubview:fingerprintLabel];
    [fingerprintLabel autoPinWidthToSuperviewWithMargin:ScaleFromIPhone5To7Plus(50.f, 60.f)];
    [fingerprintLabel autoPinEdge:ALEdgeBottom
                           toEdge:ALEdgeTop
                           ofView:instructionsLabel
                       withOffset:-16];
    SET_SUBVIEW_ACCESSIBILITY_IDENTIFIER(self, fingerprintLabel);

    // Fingerprint Image
    CustomLayoutView *fingerprintView = [CustomLayoutView new];
    [self.view addSubview:fingerprintView];
    [fingerprintView autoPinWidthToSuperview];
    [fingerprintView autoPinEdge:ALEdgeBottom
                          toEdge:ALEdgeTop
                          ofView:fingerprintLabel
                      withOffset: -16];
    [fingerprintView
        addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(fingerprintViewTapped:)]];
    fingerprintView.userInteractionEnabled = YES;
    SET_SUBVIEW_ACCESSIBILITY_IDENTIFIER(self, fingerprintView);

    UIImageView *fingerprintImageView = [UIImageView new];
    fingerprintImageView.image = self.fingerprint.image;
    // Don't antialias QR Codes.
    fingerprintImageView.layer.magnificationFilter = kCAFilterNearest;
    fingerprintImageView.layer.minificationFilter = kCAFilterNearest;
    [fingerprintView addSubview:fingerprintImageView];

    fingerprintView.layoutBlock = ^{
        CGFloat size = round(MIN(fingerprintView.width, fingerprintView.height));
        fingerprintImageView.frame = CGRectMake(
            round((fingerprintView.width - size) * 0.5f), round((fingerprintView.height - size) * 0.5f), size, size);
    };

    // Verification State
    self.verificationStateLabel.font = [UIFont st_sfUiTextRegularFontWithSize:14];
    self.verificationStateLabel.textColor = Theme.primaryTextColor;
    self.verificationStateLabel.textAlignment = NSTextAlignmentCenter;
    self.verificationStateLabel.numberOfLines = 0;
    self.verificationStateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIView *verificationStateContainer = [UIView new];
    [self.view addSubview:verificationStateContainer];
    
    [verificationStateContainer addSubview:self.verificationStateLabel];
    [self.verificationStateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:verificationStateContainer];
    [self.verificationStateLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:verificationStateContainer];
    [self.verificationStateLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:verificationStateContainer];
    
    NSLayoutConstraint *containerCenterX = [NSLayoutConstraint constraintWithItem:verificationStateContainer
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0];
    [NSLayoutConstraint activateConstraints:@[containerCenterX]];

    [verificationStateContainer autoPinToTopLayoutGuideOfViewController:self withInset:ScaleFromIPhone5To7Plus(15.f, 20.f)];
    [verificationStateContainer autoPinEdge:ALEdgeBottom
                                 toEdge:ALEdgeTop
                                 ofView:fingerprintView
                             withOffset:-ScaleFromIPhone5To7Plus(10.f, 15.f)];
    verificationStateContainer.backgroundColor = UIColor.clearColor;
    [verificationStateContainer addSubview:self.stateImageView];
    [self.stateImageView autoPinTrailingToLeadingEdgeOfView:self.verificationStateLabel offset:4];
    [self.stateImageView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:verificationStateContainer];
    [self.stateImageView autoSetDimension:ALDimensionWidth toSize:24];
    [self.stateImageView autoSetDimension:ALDimensionHeight toSize:24];
    NSLayoutConstraint *imageViewCenterY = [NSLayoutConstraint constraintWithItem:self.stateImageView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:verificationStateContainer
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0];
    [NSLayoutConstraint activateConstraints:@[imageViewCenterY]];
}

- (void)updateVerification
{
    OWSAssertDebug(self.address.isValid);

    BOOL isVerified =
        [[OWSIdentityManager shared] verificationStateForAddress:self.address] == OWSVerificationStateVerified;

    if (isVerified) {
        UIImage *image = [Theme iconImage:ThemeIconVerificationActive alwaysTemplate:NO];
        self.stateImageView.image = image;
        self.verificationStateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PRIVACY_IDENTITY_IS_VERIFIED_FORMAT_new",
                                                                                        @"Label indicating that the user is verified. Embeds "
                                                                                        @"{{the user's name or phone number}}."),
                                            self.contactName];
        self.verifyUnverifyButton = [STSecondaryButton new];
        [self.verifyUnverifyButton setTitle:NSLocalizedString(@"PRIVACY_UNVERIFY_BUTTON",@"")
                                   forState: UIControlStateNormal ];
        [self.verifyUnverifyButton addTarget:self
                                      action:@selector(verifyUnverifyButtonTapped)
                            forControlEvents: UIControlEventTouchUpInside];
    } else {
        UIImage *image = [Theme iconImage:ThemeIconVerificationNonActive alwaysTemplate:NO];
        self.stateImageView.image = image;
        self.verificationStateLabel.text = [NSString
                                            stringWithFormat:NSLocalizedString(@"PRIVACY_IDENTITY_IS_NOT_VERIFIED_FORMAT_new",
                                                                               @"Label indicating that the user is not verified. Embeds {{the user's name or phone "
                                                                               @"number}}."),
                                            self.contactName];
        self.verifyUnverifyButton = [STPrimaryButton new];
        [self.verifyUnverifyButton setTitle:NSLocalizedString(@"PRIVACY_VERIFICATION_BUTTON",@"")
                                   forState: UIControlStateNormal ];
    }
    [self.verifyUnverifyButton addTarget:self
                                  action:@selector(verifyUnverifyButtonTapped)
                        forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:self.verifyUnverifyButton];
    [self.verifyUnverifyButton autoPinLeadingToEdgeOfView:self.view offset:16];
    [self.verifyUnverifyButton autoPinTrailingToEdgeOfView:self.view offset:-16];
    [self.verifyUnverifyButton autoPinToBottomLayoutGuideOfViewController:self withInset:56];
    SET_SUBVIEW_ACCESSIBILITY_IDENTIFIER(self, self.verifyUnverifyButton);

    [self.view setNeedsLayout];
}

#pragma mark -

- (void)showSharingActivityWithCompletion:(nullable void (^)(void))completionHandler
{
    OWSLogDebug(@"Sharing safety numbers");

    OWSCompareSafetyNumbersActivity *compareActivity = [[OWSCompareSafetyNumbersActivity alloc] initWithDelegate:self];

    NSString *shareFormat = NSLocalizedString(
        @"SAFETY_NUMBER_SHARE_FORMAT", @"Snippet to share {{safety number}} with a friend. sent e.g. via SMS");
    NSString *shareString = [NSString stringWithFormat:shareFormat, self.fingerprint.displayableText];

    UIActivityViewController *activityController =
        [[UIActivityViewController alloc] initWithActivityItems:@[ shareString ]
                                          applicationActivities:@[ compareActivity ]];

    activityController.completionWithItemsHandler = ^void(UIActivityType __nullable activityType,
        BOOL completed,
        NSArray *__nullable returnedItems,
        NSError *__nullable activityError) {
        if (completionHandler) {
            completionHandler();
        }
    };

    if (activityController.popoverPresentationController) {
        activityController.popoverPresentationController.barButtonItem = self.shareButton;
    }

    // This value was extracted by inspecting `activityType` in the activityController.completionHandler
    NSString *const iCloudActivityType = @"com.apple.CloudDocsUI.AddToiCloudDrive";
    activityController.excludedActivityTypes = @[
        UIActivityTypePostToFacebook,
        UIActivityTypePostToWeibo,
        UIActivityTypeAirDrop,
        UIActivityTypePostToTwitter,
        iCloudActivityType // This isn't being excluded. RADAR https://openradar.appspot.com/27493621
    ];

    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - OWSCompareSafetyNumbersActivityDelegate

- (void)compareSafetyNumbersActivitySucceededWithActivity:(OWSCompareSafetyNumbersActivity *)activity
{
    [self showVerificationSucceeded];
}

- (void)compareSafetyNumbersActivity:(OWSCompareSafetyNumbersActivity *)activity failedWithError:(NSError *)error
{
    [self showVerificationFailedWithError:error];
}

- (void)showVerificationSucceeded
{
    [FingerprintViewScanController showVerificationSucceeded:self
                                                 identityKey:self.identityKey
                                            recipientAddress:self.address
                                                 contactName:self.contactName
                                                         tag:self.logTag];
}

- (void)showVerificationFailedWithError:(NSError *)error
{

    [FingerprintViewScanController showVerificationFailedWithError:error
                                                    viewController:self
                                                        retryBlock:nil
                                                       cancelBlock:^{
                                                           // Do nothing.
                                                       }
                                                               tag:self.logTag];
}

#pragma mark - Action

- (void)closeButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapShareButton
{
    [self showSharingActivityWithCompletion:nil];
}

- (void)showScanner
{
    FingerprintViewScanController *scanView = [FingerprintViewScanController new];
    [scanView configureWithRecipientAddress:self.address];
    [self.navigationController pushViewController:scanView animated:YES];
}

- (void)learnMoreButtonTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        NSString *learnMoreURL = @"https://support.grapherex.com";

        SFSafariViewController *safariVC =
            [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:learnMoreURL]];
        [self presentViewController:safariVC animated:YES completion:nil];
    }
}

- (void)fingerprintLabelTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self showSharingActivityWithCompletion:nil];
    }
}

- (void)fingerprintViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self showScanner];
    }
}

- (void)verifyUnverifyButtonTapped
{
    DatabaseStorageWrite(self.databaseStorage, ^(SDSAnyWriteTransaction *transaction) {
        BOOL isVerified = [[OWSIdentityManager shared] verificationStateForAddress:self.address
                                                                       transaction:transaction]
        == OWSVerificationStateVerified;
        
        OWSVerificationState newVerificationState
        = (isVerified ? OWSVerificationStateDefault : OWSVerificationStateVerified);
        [[OWSIdentityManager shared] setVerificationState:newVerificationState
                                              identityKey:self.identityKey
                                                  address:self.address
                                    isUserInitiatedChange:YES
                                              transaction:transaction];
    });
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)identityStateDidChange:(NSNotification *)notification
{
    OWSAssertIsOnMainThread();

    [self updateVerification];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIDevice.currentDevice.isIPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

@end

NS_ASSUME_NONNULL_END
