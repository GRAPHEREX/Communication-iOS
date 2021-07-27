//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <SignalMessaging/OWSViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class SignalServiceAddress;

@interface CustomLayoutView : UIView

typedef void (^CustomLayoutBlock)(void);

@property (nonatomic) CustomLayoutBlock layoutBlock;

@end

@interface FingerprintViewController : OWSViewController

+ (void)presentFromViewController:(UIViewController *)viewController address:(SignalServiceAddress *)address;

@end

NS_ASSUME_NONNULL_END
