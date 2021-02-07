//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import <SignalMessaging/OWSViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class SDSKeyValueStore;

@interface ProfileRegistrationViewController : OWSViewController

+ (SDSKeyValueStore *)keyValueStore;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (BOOL)shouldDisplayProfileViewOnLaunch;
- (void)updateСompletionHandler:(void (^)(ProfileRegistrationViewController *))completionHandler;

@end

NS_ASSUME_NONNULL_END


