//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "DebugUISyncMessages.h"
#import "DebugUIContacts.h"
#import "Stacle-Swift.h"
#import "ThreadUtil.h"
#import <PromiseKit/AnyPromise.h>
#import <SignalCoreKit/Randomness.h>
#import <AppMessaging/Environment.h>
#import <AppMessaging/OWSTableViewController.h>
#import <AppServiceKit/OWSBlockingManager.h>
#import <AppServiceKit/OWSDisappearingMessagesConfiguration.h>
#import <AppServiceKit/OWSIdentityManager.h>
#import <AppServiceKit/OWSReadReceiptManager.h>
#import <AppServiceKit/AppServiceKit-Swift.h>
#import <AppServiceKit/TSCall.h>
#import <AppServiceKit/TSIncomingMessage.h>
#import <AppServiceKit/TSThread.h>

#ifdef DEBUG

NS_ASSUME_NONNULL_BEGIN

@implementation DebugUISyncMessages

#pragma mark - Factory Methods

- (NSString *)name
{
    return @"Sync Messages";
}

- (nullable OWSTableSection *)sectionForThread:(nullable TSThread *)thread
{
    NSMutableArray<OWSTableItem *> *items = [@[
        [OWSTableItem itemWithTitle:@"Send Contacts Sync Message"
                        actionBlock:^{
                            [DebugUISyncMessages sendContactsSyncMessage];
                        }],
        [OWSTableItem itemWithTitle:@"Send Groups Sync Message"
                        actionBlock:^{
                            [DebugUISyncMessages sendGroupSyncMessage];
                        }],
        [OWSTableItem itemWithTitle:@"Send Blocklist Sync Message"
                        actionBlock:^{
                            [DebugUISyncMessages sendBlockListSyncMessage];
                        }],
        [OWSTableItem itemWithTitle:@"Send Configuration Sync Message"
                        actionBlock:^{
                            [DebugUISyncMessages sendConfigurationSyncMessage];
                        }],
        [OWSTableItem itemWithTitle:@"Send Verification Sync Message"
                        actionBlock:^{
                            [DebugUISyncMessages sendVerificationSyncMessage];
                        }],
    ] mutableCopy];

    if (thread != nil) {
        [items addObject:[OWSTableItem itemWithTitle:@"Send Conversation Settings Sync Message"
                                         actionBlock:^{
                                             [DebugUISyncMessages syncConversationSettingsWithThread:thread];
                                         }]];
    }

    return [OWSTableSection sectionWithTitle:self.name items:items];
}

+ (MessageSenderJobQueue *)messageSenderJobQueue
{
    return SSKEnvironment.shared.messageSenderJobQueue;
}

+ (OWSContactsManager *)contactsManager
{
    return Environment.shared.contactsManager;
}

+ (OWSIdentityManager *)identityManager
{
    return [OWSIdentityManager shared];
}

+ (OWSBlockingManager *)blockingManager
{
    return [OWSBlockingManager shared];
}

+ (OWSProfileManager *)profileManager
{
    return [OWSProfileManager shared];
}

+ (id<SyncManagerProtocol>)syncManager
{
    OWSAssertDebug(SSKEnvironment.shared.syncManager);

    return SSKEnvironment.shared.syncManager;
}

#pragma mark -

+ (void)sendContactsSyncMessage
{
    [self.syncManager syncAllContacts];
}

+ (void)sendGroupSyncMessage
{
    DatabaseStorageAsyncWrite(self.databaseStorage, ^(SDSAnyWriteTransaction *transaction) {
        [self.syncManager syncGroupsWithTransaction:transaction];
    });
}

+ (void)sendBlockListSyncMessage
{
    [self.blockingManager syncBlockList];
}

+ (void)sendConfigurationSyncMessage
{
    [SSKEnvironment.shared.syncManager sendConfigurationSyncMessage];
}

+ (void)sendVerificationSyncMessage
{
    [OWSIdentityManager.shared tryToSyncQueuedVerificationStates];
}

+ (void)syncConversationSettingsWithThread:(TSThread *)thread
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ConversationConfigurationSyncOperation *operation =
            [[ConversationConfigurationSyncOperation alloc] initWithThread:thread];
        OWSAssertDebug(operation.isReady);
        [operation start];
    });
}
@end

NS_ASSUME_NONNULL_END

#endif
