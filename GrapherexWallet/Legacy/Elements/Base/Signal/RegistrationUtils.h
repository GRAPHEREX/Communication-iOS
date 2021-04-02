//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

//NS_ASSUME_NONNULL_BEGIN
@import Foundation;
@import UIKit;

@interface RegistrationUtils : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (void)showReregistrationUIFromViewController:(UIViewController *)fromViewController;

@end

//NS_ASSUME_NONNULL_END
