//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <SignalMessaging/OWSContactAvatarBuilder.h>

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kContactCellAvatarTextMargin;

@class SDSAnyReadTransaction;
@class SignalServiceAddress;
@class TSThread;
@class TSCall;

@interface ContactCellView : UIStackView

typedef void (^CallAction)(SignalServiceAddress*); //_Nonnull

@property (assign, nonatomic) BOOL forceDarkAppearance;

@property (nonatomic, nullable) NSString *accessoryMessage;

@property (nonatomic, nullable) NSAttributedString *customName;

@property (nonatomic, nullable) UIImage *customAvatar;

/// Default is "NO"
@property (nonatomic) BOOL useSmallAvatars;
/// Default is "NO"
@property (nonatomic) BOOL shouldShowStatus;
/// Default is "NO"
@property (nonatomic) BOOL asCallView;

@property (nonatomic) BOOL useLargeAvatars;

- (void)configureWithSneakyTransactionWithRecipientAddress:(SignalServiceAddress *)address
                                       localUserAvatarMode:(LocalUserAvatarMode)localUserAvatarMode
    NS_SWIFT_NAME(configureWithSneakyTransaction(recipientAddress:localUserAvatarMode:));

- (void)configureWithRecipientAddress:(SignalServiceAddress *)address
                  localUserAvatarMode:(LocalUserAvatarMode)localUserAvatarMode
                          transaction:(SDSAnyReadTransaction *)transaction;

- (void)configureWithThread:(TSThread *)thread
        localUserAvatarMode:(LocalUserAvatarMode)localUserAvatarMode
                transaction:(SDSAnyReadTransaction *)transaction;

- (void)configureWithCall:(TSCall *)call;

- (void)prepareForReuse;

- (void)configureCallAction:(nullable CallAction)handler;

- (NSAttributedString *)verifiedSubtitle;

- (void)setAttributedSubtitle:(nullable NSAttributedString *)attributedSubtitle;

- (void)setSubtitle:(nullable NSString *)subtitle;

- (BOOL)hasAccessoryText;

- (void)setAccessoryView:(UIView *)accessoryView;

@end

NS_ASSUME_NONNULL_END
