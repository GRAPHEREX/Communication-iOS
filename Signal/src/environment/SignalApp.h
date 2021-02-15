//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "ConversationViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class OnboardingController_Grapherex;
@class SignalServiceAddress;
@class TSThread;
@class RootViewController;

@interface SignalApp : NSObject

@property (nonatomic, nullable, weak) RootViewController *rootViewController;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedApp;

- (void)setup;

@property (nonatomic, readonly) BOOL hasSelectedThread;
@property (nonatomic, readonly) BOOL didLastLaunchNotTerminate;

#pragma mark - Conversation Presentation

- (void)showNewConversationView;

- (void)presentConversationForAddress:(SignalServiceAddress *)address animated:(BOOL)isAnimated;

- (void)presentConversationForAddress:(SignalServiceAddress *)address
                               action:(ConversationViewAction)action
                             animated:(BOOL)isAnimated;

- (void)presentConversationForThreadId:(NSString *)threadId animated:(BOOL)isAnimated;

- (void)presentConversationForThread:(TSThread *)thread animated:(BOOL)isAnimated;

- (void)presentConversationForThread:(TSThread *)thread action:(ConversationViewAction)action animated:(BOOL)isAnimated;

- (void)presentConversationForThread:(TSThread *)thread
                              action:(ConversationViewAction)action
                      focusMessageId:(nullable NSString *)focusMessageId
                            animated:(BOOL)isAnimated;

- (void)presentConversationAndScrollToFirstUnreadMessageForThreadId:(NSString *)threadId animated:(BOOL)isAnimated;
- (void)openConversationsList;

#pragma mark - Methods

+ (void)resetAppData;

- (void)showOnboardingView:(OnboardingController_Grapherex *)onboardingController;
- (void)showConversationSplitView;
- (void)ensureRootViewController:(NSTimeInterval)launchStartedAt;
- (BOOL)receivedVerificationCode:(NSString *)verificationCode;
- (void)applicationWillTerminate;

- (nullable UIView *)snapshotSplitViewControllerAfterScreenUpdates:(BOOL)afterScreenUpdates;

@end

NS_ASSUME_NONNULL_END
