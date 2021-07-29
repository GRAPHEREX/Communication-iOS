//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "VersionMigrations.h"
#import "Environment.h"
#import <AppMessaging/AppMessaging-Swift.h>
#import <AppServiceKit/AppContext.h>
#import <AppServiceKit/AppVersion.h>
#import <AppServiceKit/NSUserDefaults+OWS.h>
#import <AppServiceKit/OWSRequestFactory.h>
#import <AppServiceKit/AppServiceKit-Swift.h>
#import <AppServiceKit/TSAccountManager.h>
#import <AppServiceKit/TSNetworkManager.h>

NS_ASSUME_NONNULL_BEGIN

#define NEEDS_TO_REGISTER_PUSH_KEY @"Register For Push"
#define NEEDS_TO_REGISTER_ATTRIBUTES @"Register Attributes"

@implementation VersionMigrations

#pragma mark - Utility methods

+ (void)performUpdateCheckWithCompletion:(VersionMigrationCompletion)completion
{
    OWSLogInfo(@"");

    // performUpdateCheck must be invoked after Environment has been initialized because
    // upgrade process may depend on Environment.
    OWSAssertDebug(Environment.shared);
    OWSAssertDebug(completion);

    NSString *_Nullable lastCompletedLaunchAppVersion = AppVersion.shared.lastCompletedLaunchAppVersion;
    NSString *currentVersion = AppVersion.shared.currentAppVersion;

    OWSLogInfo(@"Checking migrations. currentVersion: %@, lastCompletedLaunchAppVersion: %@",
        currentVersion,
        lastCompletedLaunchAppVersion);

    if (!lastCompletedLaunchAppVersion) {
        OWSLogInfo(@"No previous version found. Probably first launch since install - nothing to migrate.");
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{ [self.databaseStorage runGrdbSchemaMigrationsWithCompletion:completion]; });
}

+ (BOOL)isVersion:(NSString *)thisVersionString
          atLeast:(NSString *)openLowerBoundVersionString
      andLessThan:(NSString *)closedUpperBoundVersionString
{
    return [self isVersion:thisVersionString atLeast:openLowerBoundVersionString] &&
        [self isVersion:thisVersionString lessThan:closedUpperBoundVersionString];
}

+ (BOOL)isVersion:(NSString *)thisVersionString atLeast:(NSString *)thatVersionString
{
    return [thisVersionString compare:thatVersionString options:NSNumericSearch] != NSOrderedAscending;
}

+ (BOOL)isVersion:(NSString *)thisVersionString lessThan:(NSString *)thatVersionString
{
    return [thisVersionString compare:thatVersionString options:NSNumericSearch] == NSOrderedAscending;
}

@end

NS_ASSUME_NONNULL_END
