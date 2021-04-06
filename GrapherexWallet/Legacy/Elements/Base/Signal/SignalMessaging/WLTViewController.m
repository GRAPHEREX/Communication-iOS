//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "WLTViewController.h"
#import "UIView+OWS.h"
#import <GrapherexWallet/GrapherexWallet-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLTViewController ()

@property (nonatomic, weak) UIView *bottomLayoutView;
@property (nonatomic) NSLayoutConstraint *bottomLayoutConstraint;
@property (nonatomic) BOOL shouldAnimateBottomLayout;
@property (nonatomic) UIView *customStatusBar;
@property (nonatomic) CGFloat keyboardInset;
@property (nonatomic) BOOL saveInset;
@end

#pragma mark -

@implementation WLTViewController

- (void)dealloc
{
    // Surface memory leaks by logging the deallocation of view controllers.
//    OWSLogVerbose(@"Dealloc: %@", self.class);

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) {
        self.keyboardInset = 0;
        self.shouldUseTheme = YES;
        self.saveInset = YES;
        return self;
    }
    
    [self observeActivation];
    
    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        self.keyboardInset = 0;
        self.shouldUseTheme = YES;
        self.saveInset = YES;
        return self;
    }
    
    [self observeActivation];
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        self.keyboardInset = 0;
        self.shouldUseTheme = YES;
         self.saveInset = YES;
        return self;
    }

    [self observeActivation];

    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.shouldAnimateBottomLayout = YES;

#ifdef DEBUG
    [self ensureNavbarAccessibilityIds];
#endif
}

#ifdef DEBUG
- (void)ensureNavbarAccessibilityIds
{
    UINavigationBar *_Nullable navigationBar = self.navigationController.navigationBar;
    if (!navigationBar) {
        return;
    }
    // There isn't a great way to assign accessibilityIdentifiers to default
    // navbar buttons, e.g. the back button.  As a (DEBUG-only) hack, we
    // assign accessibilityIds to any navbar controls which don't already have
    // one.  This should offer a reliable way for automated scripts to find
    // these controls.
    //
    // UINavigationBar often discards and rebuilds new contents, e.g. between
    // presentations of the view, so we need to do this every time the view
    // appears.  We don't do any checking for accessibilityIdentifier collisions
    // so we're counting on the fact that navbar contents are short-lived.
    __block int accessibilityIdCounter = 0;
    [navigationBar wltTraverseViewHierarchyDownwardWithVisitor:^(UIView *view) {
        if ([view isKindOfClass:[UIControl class]] && view.accessibilityIdentifier == nil) {
            // The view should probably be an instance of _UIButtonBarButton or _UIModernBarButton.
            view.accessibilityIdentifier = [NSString stringWithFormat:@"navbar-%d", accessibilityIdCounter];
            accessibilityIdCounter++;
        }
    }];
}
#endif

- (void)setup
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    self.shouldAnimateBottomLayout = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.shouldUseTheme) {
//        self.view.backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor;
    }
    
    [self setup];
}

- (void)setupStatusBar:(CGSize)size color:(UIColor*)color
{
    UIView *customStatusBar = [UIView new];
    [self.view addSubview:customStatusBar];
    customStatusBar.backgroundColor = color;
    customStatusBar.frame = CGRectMake(0, 0, size.width, size.height);
    self.customStatusBar = customStatusBar;
}

- (void)updateStatusBarAppearance:(UIColor*)color
{
    self.customStatusBar.backgroundColor = color;
}

#pragma mark -
- (void)autoPinViewToBottomOfViewControllerOrKeyboard:(UIView *)view avoidNotch:(BOOL)avoidNotch withInset:(CGFloat)inset saveInset:(BOOL)saveInset
{
    self.saveInset = saveInset;
    [self autoPinViewToBottomOfViewControllerOrKeyboard:view avoidNotch:avoidNotch withInset:inset];
}

- (void)autoPinViewToBottomOfViewControllerOrKeyboard:(UIView *)view avoidNotch:(BOOL)avoidNotch withInset:(CGFloat)inset
{
    //OWSAssertDebug(view);
    //OWSAssertDebug(!self.bottomLayoutConstraint);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];

    self.bottomLayoutView = view;
    self.keyboardInset = inset;
    if (avoidNotch) {
        self.bottomLayoutConstraint = [view autoPinToBottomLayoutGuideOfViewController:self withInset:inset];
    } else {
        self.bottomLayoutConstraint = [view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    }
}

- (NSLayoutConstraint *)autoPinViewToBottomOfViewControllerOrKeyboard:(UIView *)view avoidNotch:(BOOL)avoidNotch
{
    //OWSAssertDebug(view);
    //OWSAssertDebug(!self.bottomLayoutConstraint);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];

    self.bottomLayoutView = view;
    self.keyboardInset = 0.0;
    if (avoidNotch) {
        self.bottomLayoutConstraint = [view autoPinToBottomLayoutGuideOfViewController:self withInset:0.f];
    } else {
        self.bottomLayoutConstraint = [view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    }
    return self.bottomLayoutConstraint;
}

- (void)observeActivation
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(owsViewControllerApplicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)owsViewControllerApplicationDidBecomeActive:(NSNotification *)notification
{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self handleKeyboardNotificationBase:notification];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self handleKeyboardNotificationBase:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self handleKeyboardNotificationBase:notification];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self handleKeyboardNotificationBase:notification];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    [self handleKeyboardNotificationBase:notification];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    [self handleKeyboardNotificationBase:notification];
}

// We use the name `handleKeyboardNotificationBase` instead of
// `handleKeyboardNotification` to avoid accidentally
// calling similarly methods with that name in subclasses,
// e.g. ConversationViewController.
- (void)handleKeyboardNotificationBase:(NSNotification *)notification
{
//    OWSAssertIsOnMainThread();

    if (self.shouldIgnoreKeyboardChanges) {
        return;
    }

    NSDictionary *userInfo = [notification userInfo];

    NSValue *_Nullable keyboardEndFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    if (!keyboardEndFrameValue) {
//        OWSFailDebug(@"Missing keyboard end frame");
        return;
    }

    CGRect keyboardEndFrame = [keyboardEndFrameValue CGRectValue];
    CGRect keyboardEndFrameConverted = [self.view convertRect:keyboardEndFrame fromView:nil];
    // Adjust the position of the bottom view to account for the keyboard's
    // intrusion into the view.
    //
    // On iPhoneX, when no keyboard is present, we include a buffer at the bottom of the screen so the bottom view
    // clears the floating "home button". But because the keyboard includes it's own buffer, we subtract the length
    // (height) of the bottomLayoutGuide, else we'd have an unnecessary buffer between the popped keyboard and the input
    // bar.
//<<<<<<< HEAD
//    CGFloat offset = -MAX(self.keyboardInset, (self.view.height - self.bottomLayoutGuide.length - keyboardEndFrameConverted.origin.y + (self.saveInset ? self.keyboardInset : 0) ));
//=======
    CGFloat newInset = MAX(0, (self.view.bounds.size.height - self.bottomLayoutGuide.length - keyboardEndFrameConverted.origin.y));

    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // Should we ignore keyboard changes if they're coming from somewhere out-of-process?
    // BOOL isOurKeyboard = [notification.userInfo[UIKeyboardIsLocalUserInfoKey] boolValue];
//>>>>>>> master

    dispatch_block_t updateLayout = ^{
        if (self.shouldBottomViewReserveSpaceForKeyboard && newInset <= 0) {
            // To avoid unnecessary animations / layout jitter,
            // some views never reclaim layout space when the keyboard is dismissed.
            //
            // They _do_ need to relayout if the user switches keyboards.
            return;
        }
        [self updateBottomLayoutConstraintFromInset:-self.bottomLayoutConstraint.constant toInset:newInset];
    };


    if (self.shouldAnimateBottomLayout && duration > 0) {
        [UIView beginAnimations:@"keyboardStateChange" context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDuration:duration];
        updateLayout();
        [UIView commitAnimations];
    } else {
        // UIKit by default (sometimes? never?) animates all changes in response to keyboard events.
        // We want to suppress those animations if the view isn't visible,
        // otherwise presentation animations don't work properly.
        [UIView performWithoutAnimation:updateLayout];
    }
}

- (void)updateBottomLayoutConstraintFromInset:(CGFloat)before toInset:(CGFloat)after
{
    self.bottomLayoutConstraint.constant = -after;
    [self.bottomLayoutView.superview layoutIfNeeded];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIDevice.currentDevice.defaultSupportedOrienations;
}

@end

NS_ASSUME_NONNULL_END
