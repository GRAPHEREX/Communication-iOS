//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "WLTNavigationController.h"
#import <GrapherexWallet/GrapherexWallet-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (WLTNavigationController) <UINavigationBarDelegate>

@end

#pragma mark -

// Expose that UINavigationController already secretly implements UIGestureRecognizerDelegate
// so we can call [super navigationBar:shouldPopItem] in our own implementation to take advantage
// of the important side effects of that method.
@interface WLTNavigationController () <UIGestureRecognizerDelegate>

@end

#pragma mark -

@implementation WLTNavigationController

- (instancetype)init
{
    self = [super initWithNavigationBarClass:[WLTNavigationBar class] toolbarClass:nil];
    if (!self) {
        return self;
    }

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(themeDidChange:)
//                                                 name:ThemeDidChangeNotification
//                                               object:nil];

    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [self init];
    if (!self) {
        return self;
    }
    [self pushViewController:rootViewController animated:NO];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)themeDidChange:(NSNotification *)notification
{
//    OWSAssertIsOnMainThread();

    self.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
    self.navigationBar.tintColor = [UINavigationBar appearance].tintColor;
    self.navigationBar.titleTextAttributes = [UINavigationBar appearance].titleTextAttributes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    if (self.wlt_prefersStatusBarHidden) {
        return self.wlt_prefersStatusBarHidden.boolValue;
    }
    return [super prefersStatusBarHidden];
}

// All WLTNavigationController serve as the UINavigationBarDelegate for their navbar.
// We override shouldPopItem: in order to cancel some back button presses - for example,
// if a view has unsaved changes.
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    //OWSAssertDebug(self.interactivePopGestureRecognizer.delegate == self);
    UIViewController *topViewController = self.topViewController;

    // wasBackButtonClicked is YES if the back button was pressed but not
    // if a back gesture was performed or if the view is popped programmatically.
    BOOL wasBackButtonClicked = topViewController.navigationItem == item;
    BOOL result = YES;
    if (wasBackButtonClicked) {
        if ([topViewController conformsToProtocol:@protocol(WLTNavigationView)]) {
            id<WLTNavigationView> navigationView = (id<WLTNavigationView>)topViewController;
            result = ![navigationView shouldCancelNavigationBack];
        }
    }

    // If we're not going to cancel the pop/back, we need to call the super
    // implementation since it has important side effects.
    if (result) {
        // NOTE: result might end up NO if the super implementation cancels the
        //       the pop/back.
        [super navigationBar:navigationBar shouldPopItem:item];
        result =  YES;
    }
    return result;
}

#pragma mark - UIGestureRecognizerDelegate

// We serve as the UIGestureRecognizerDelegate of the interactivePopGestureRecognizer
// in order to cancel some "back" gestures - for example,
// if a view has unsaved changes.
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //OWSAssertDebug(gestureRecognizer == self.interactivePopGestureRecognizer);

    UIViewController *topViewController = self.topViewController;
    if ([topViewController conformsToProtocol:@protocol(WLTNavigationView)]) {
        id<WLTNavigationView> navigationView = (id<WLTNavigationView>)topViewController;
        return ![navigationView shouldCancelNavigationBack];
    } else {
        UIViewController *rootViewController = self.viewControllers.firstObject;
        if (topViewController == rootViewController) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
    // MARK: - SINGAL DEPENDENCY – reimplement
//    if (!CurrentAppContext().isMainApp) {
//        return super.preferredStatusBarStyle;
//    } else {
//        UIViewController *presentedViewController = self.presentedViewController;
//        if (presentedViewController != nil && !presentedViewController.isBeingDismissed) {
//            return presentedViewController.preferredStatusBarStyle;
//        } else {
//            return (Theme.isDarkThemeEnabled ? UIStatusBarStyleLightContent : super.preferredStatusBarStyle);
//        }
//    }
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.delegate navigationControllerSupportedInterfaceOrientations:self];
    } else if (self.visibleViewController) {
        return self.visibleViewController.supportedInterfaceOrientations;
    } else {
        return UIDevice.currentDevice.defaultSupportedOrienations;
    }
}

@end

NS_ASSUME_NONNULL_END
