//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "DebugUIScreenshots.h"
#import "DebugContactsUtils.h"
#import "DebugUIContacts.h"
#import "Stacle-Swift.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalCoreKit/Randomness.h>
#import <AppMessaging/Environment.h>
#import <AppMessaging/OWSTableViewController.h>
#import <AppServiceKit/MIMETypeUtil.h>
#import <AppServiceKit/OWSDisappearingMessagesConfiguration.h>
#import <AppServiceKit/OWSMessageUtils.h>
#import <AppServiceKit/AppServiceKit-Swift.h>
#import <AppServiceKit/TSIncomingMessage.h>
#import <AppServiceKit/TSOutgoingMessage.h>
#import <AppServiceKit/TSThread.h>

#ifdef DEBUG

NS_ASSUME_NONNULL_BEGIN

@implementation DebugUIScreenshots

#pragma mark - Factory Methods

- (NSString *)name
{
    return @"Screenshots";
}

- (nullable OWSTableSection *)sectionForThread:(nullable TSThread *)thread
{
    NSMutableArray<OWSTableItem *> *items = [NSMutableArray new];

    [items addObjectsFromArray:@[
        [OWSTableItem itemWithTitle:@"Delete all threads"
                        actionBlock:^{
                            [DebugUIScreenshots deleteAllThreads];
                        }],
        [OWSTableItem itemWithTitle:@"Make Threads for Screenshots"
                        actionBlock:^{
                            [DebugUIScreenshots makeThreadsForScreenshots];
                        }],
    ]];

    return [OWSTableSection sectionWithTitle:self.name items:items];
}

@end

NS_ASSUME_NONNULL_END

#endif
