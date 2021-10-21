//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "TSThread.h"
#import "AppReadiness.h"
#import "OWSDisappearingMessagesConfiguration.h"
#import "OWSReadTracking.h"
#import "SSKEnvironment.h"
#import "TSAccountManager.h"
#import "TSIncomingMessage.h"
#import "TSInfoMessage.h"
#import "TSInteraction.h"
#import "TSInvalidIdentityKeyReceivingErrorMessage.h"
#import "TSOutgoingMessage.h"
#import <SignalCoreKit/Cryptography.h>
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalCoreKit/NSString+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

@import Intents;

NS_ASSUME_NONNULL_BEGIN

@interface TSThread ()

@property (nonatomic, nullable) NSDate *creationDate;
@property (nonatomic) BOOL isArchivedObsolete;
@property (nonatomic) BOOL isMarkedUnreadObsolete;

@property (nonatomic, copy, nullable) NSString *messageDraft;
@property (nonatomic, nullable) MessageBodyRanges *messageDraftBodyRanges;

@property (atomic) uint64_t mutedUntilTimestampObsolete;
@property (nonatomic) int64_t lastInteractionRowId;

@property (nonatomic, nullable) NSDate *mutedUntilDateObsolete;
@property (nonatomic) uint64_t lastVisibleSortIdObsolete;
@property (nonatomic) double lastVisibleSortIdOnScreenPercentageObsolete;

@property (nonatomic) TSThreadMentionNotificationMode mentionNotificationMode;

@end

#pragma mark -

@implementation TSThread

+ (NSString *)collection {
    return @"TSThread";
}

+ (BOOL)shouldBeIndexedForFTS
{
    return YES;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        _conversationColorNameObsolete = @"Obsolete";
    }

    return self;
}

- (instancetype)initWithUniqueId:(NSString *)uniqueId
{
    self = [super initWithUniqueId:uniqueId];

    if (self) {
        _creationDate    = [NSDate date];
        _messageDraft    = nil;
        _conversationColorNameObsolete = @"Obsolete";
    }

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
   conversationColorNameObsolete:(NSString *)conversationColorNameObsolete
                    creationDate:(nullable NSDate *)creationDate
              isArchivedObsolete:(BOOL)isArchivedObsolete
          isMarkedUnreadObsolete:(BOOL)isMarkedUnreadObsolete
            lastInteractionRowId:(int64_t)lastInteractionRowId
       lastVisibleSortIdObsolete:(uint64_t)lastVisibleSortIdObsolete
lastVisibleSortIdOnScreenPercentageObsolete:(double)lastVisibleSortIdOnScreenPercentageObsolete
         mentionNotificationMode:(TSThreadMentionNotificationMode)mentionNotificationMode
                    messageDraft:(nullable NSString *)messageDraft
          messageDraftBodyRanges:(nullable MessageBodyRanges *)messageDraftBodyRanges
          mutedUntilDateObsolete:(nullable NSDate *)mutedUntilDateObsolete
     mutedUntilTimestampObsolete:(uint64_t)mutedUntilTimestampObsolete
           shouldThreadBeVisible:(BOOL)shouldThreadBeVisible
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId];

    if (!self) {
        return self;
    }

    _conversationColorNameObsolete = conversationColorNameObsolete;
    _creationDate = creationDate;
    _isArchivedObsolete = isArchivedObsolete;
    _isMarkedUnreadObsolete = isMarkedUnreadObsolete;
    _lastInteractionRowId = lastInteractionRowId;
    _lastVisibleSortIdObsolete = lastVisibleSortIdObsolete;
    _lastVisibleSortIdOnScreenPercentageObsolete = lastVisibleSortIdOnScreenPercentageObsolete;
    _mentionNotificationMode = mentionNotificationMode;
    _messageDraft = messageDraft;
    _messageDraftBodyRanges = messageDraftBodyRanges;
    _mutedUntilDateObsolete = mutedUntilDateObsolete;
    _mutedUntilTimestampObsolete = mutedUntilTimestampObsolete;
    _shouldThreadBeVisible = shouldThreadBeVisible;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return self;
    }

    // renamed `hasEverHadMessage` -> `shouldThreadBeVisible`
    if (!_shouldThreadBeVisible) {
        NSNumber *_Nullable legacy_hasEverHadMessage = [coder decodeObjectForKey:@"hasEverHadMessage"];

        if (legacy_hasEverHadMessage != nil) {
            _shouldThreadBeVisible = legacy_hasEverHadMessage.boolValue;
        }
    }

    if (_conversationColorNameObsolete.length == 0) {
        _conversationColorNameObsolete = @"Obsolete";
    }

    NSDate *_Nullable lastMessageDate = [coder decodeObjectOfClass:NSDate.class forKey:@"lastMessageDate"];
    NSDate *_Nullable archivalDate = [coder decodeObjectOfClass:NSDate.class forKey:@"archivalDate"];
    _isArchivedByLegacyTimestampForSorting =
        [self.class legacyIsArchivedWithLastMessageDate:lastMessageDate archivalDate:archivalDate];

    if ([coder decodeObjectForKey:@"archivedAsOfMessageSortId"] != nil) {
        OWSAssertDebug(!_isArchivedObsolete);
        _isArchivedObsolete = YES;
    }

    return self;
}

- (void)anyDidInsertWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidInsertWithTransaction:transaction];

    [ThreadAssociatedData createIfMissingForThreadUniqueId:self.uniqueId transaction:transaction];

#if TESTABLE_BUILD
    OWSAssertDebug(nil != [ThreadAssociatedData fetchForThreadUniqueId:self.uniqueId transaction:transaction]);
#endif

    if (self.shouldThreadBeVisible && ![SSKPreferences hasSavedThreadWithTransaction:transaction]) {
        [SSKPreferences setHasSavedThread:YES transaction:transaction];
    }

    [self.modelReadCaches.threadReadCache didInsertOrUpdateThread:self transaction:transaction];
}

- (void)anyDidUpdateWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidUpdateWithTransaction:transaction];

#if TESTABLE_BUILD
    OWSAssertDebug(nil != [ThreadAssociatedData fetchForThreadUniqueId:self.uniqueId transaction:transaction]);
#endif

    if (self.shouldThreadBeVisible && ![SSKPreferences hasSavedThreadWithTransaction:transaction]) {
        [SSKPreferences setHasSavedThread:YES transaction:transaction];
    }

    [self.modelReadCaches.threadReadCache didInsertOrUpdateThread:self transaction:transaction];

    [PinnedThreadManager handleUpdatedThread:self transaction:transaction];
}

- (void)anyDidRemoveWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyDidRemoveWithTransaction:transaction];

    [self.modelReadCaches.threadReadCache didRemoveThread:self transaction:transaction];
}

- (void)anyWillRemoveWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [SDSDatabaseStorage.shared updateIdMappingWithThread:self transaction:transaction];

    [super anyWillRemoveWithTransaction:transaction];

    [self removeAllThreadInteractionsWithTransaction:transaction];

    // Remove any associated data
    [ThreadAssociatedData removeForThreadUniqueId:self.uniqueId transaction:transaction];

    // TODO: If we ever use transaction finalizations for more than
    // de-bouncing thread touches, we should promote this to TSYapDatabaseObject
    // (or at least include it in the "will remove" hook for any relevant models.
    [transaction addRemovedFinalizationKey:self.transactionFinalizationKey];
}

- (void)removeAllThreadInteractionsWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    // We can't safely delete interactions while enumerating them, so
    // we collect and delete separately.
    //
    // We don't want to instantiate the interactions when collecting them
    // or when deleting them.
    NSMutableArray<NSString *> *interactionIds = [NSMutableArray new];
    NSError *error;
    InteractionFinder *interactionFinder = [[InteractionFinder alloc] initWithThreadUniqueId:self.uniqueId];
    [interactionFinder enumerateInteractionIdsWithTransaction:transaction
                                                        error:&error
                                                        block:^(NSString *key, BOOL *stop) {
                                                            [interactionIds addObject:key];
                                                        }];
    if (error != nil) {
        OWSFailDebug(@"Error during enumeration: %@", error);
    }

    [transaction ignoreInteractionUpdatesForThreadUniqueId:self.uniqueId];
    
    for (NSString *interactionId in interactionIds) {
        // We need to fetch each interaction, since [TSInteraction removeWithTransaction:] does important work.
        TSInteraction *_Nullable interaction =
            [TSInteraction anyFetchWithUniqueId:interactionId transaction:transaction];
        if (!interaction) {
            OWSFailDebug(@"couldn't load thread's interaction for deletion.");
            continue;
        }
        [interaction anyRemoveWithTransaction:transaction];
    }

    // As an optimization, we called `ignoreInteractionUpdatesForThreadUniqueId` so as not
    // to re-save the thread after *each* interaction deletion. However, we still need to resave
    // the thread just once, after all the interactions are deleted.
    [self anyUpdateWithTransaction:transaction
                             block:^(TSThread *thread) {
                                 thread.lastInteractionRowId = 0;
                             }];
}

- (BOOL)isNoteToSelf
{
    return NO;
}

- (NSString *)colorSeed
{
    return self.uniqueId;
}

#pragma mark - To be subclassed.

- (NSArray<SignalServiceAddress *> *)recipientAddresses
{
    OWSAbstractMethod();

    return @[];
}

- (BOOL)hasSafetyNumbers
{
    return NO;
}

#pragma mark - Interactions

/**
 * Iterate over this thread's interactions
 */
- (void)enumerateRecentInteractionsWithTransaction:(SDSAnyReadTransaction *)transaction
                                        usingBlock:(void (^)(TSInteraction *interaction))block
{
    NSError *error;
    InteractionFinder *interactionFinder = [[InteractionFinder alloc] initWithThreadUniqueId:self.uniqueId];
    [interactionFinder enumerateRecentInteractionsWithTransaction:transaction
                                                            error:&error
                                                            block:^(TSInteraction *interaction, BOOL *stop) {
                                                                block(interaction);
                                                            }];
    if (error != nil) {
        OWSFailDebug(@"Error during enumeration: %@", error);
    }
}

/**
 * Enumerates all the threads interactions. Note this will explode if you try to create a transaction in the block.
 * If you need a transaction, use the sister method: `enumerateInteractionsWithTransaction:usingBlock`
 */
- (void)enumerateRecentInteractionsUsingBlock:(void (^)(TSInteraction *interaction))block
{
    [self.databaseStorage readWithBlock:^(SDSAnyReadTransaction *transaction) {
        [self enumerateRecentInteractionsWithTransaction:transaction
                                              usingBlock:^(TSInteraction *interaction) {
                                                  block(interaction);
                                              }];
    }];
}

/**
 * Useful for tests and debugging. In production use an enumeration method.
 */
- (NSArray<TSInteraction *> *)allInteractions
{
    NSMutableArray<TSInteraction *> *interactions = [NSMutableArray new];
    [self enumerateRecentInteractionsUsingBlock:^(TSInteraction *interaction) {
        [interactions addObject:interaction];
    }];

    return [interactions copy];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSArray<TSInvalidIdentityKeyReceivingErrorMessage *> *)receivedMessagesForInvalidKey:(NSData *)key
{
    NSMutableArray *errorMessages = [NSMutableArray new];
    [self enumerateRecentInteractionsUsingBlock:^(TSInteraction *interaction) {
        if ([interaction isKindOfClass:[TSInvalidIdentityKeyReceivingErrorMessage class]]) {
            TSInvalidIdentityKeyReceivingErrorMessage *error = (TSInvalidIdentityKeyReceivingErrorMessage *)interaction;
            @try {
                if ([[error throws_newIdentityKey] isEqualToData:key]) {
                    [errorMessages addObject:(TSInvalidIdentityKeyReceivingErrorMessage *)interaction];
                }
            } @catch (NSException *exception) {
                OWSFailDebug(@"exception: %@", exception);
            }
        }
    }];

    return [errorMessages copy];
}
#pragma clang diagnostic pop

- (NSUInteger)numberOfInteractionsWithTransaction:(SDSAnyReadTransaction *)transaction
{
    OWSAssertDebug(transaction);
    return [[[InteractionFinder alloc] initWithThreadUniqueId:self.uniqueId] countExcludingPlaceholders:NO
                                                                                            transaction:transaction];
}

- (nullable TSInteraction *)lastInteractionForInboxWithTransaction:(SDSAnyReadTransaction *)transaction
{
    OWSAssertDebug(transaction);
    return [[[InteractionFinder alloc] initWithThreadUniqueId:self.uniqueId]
        mostRecentInteractionForInboxWithTransaction:transaction];
}

- (nullable TSInteraction *)firstInteractionAtOrAroundSortId:(uint64_t)sortId
                                                 transaction:(SDSAnyReadTransaction *)transaction
{
    OWSAssertDebug(transaction);
    return
        [[[InteractionFinder alloc] initWithThreadUniqueId:self.uniqueId] firstInteractionAtOrAroundSortId:sortId
                                                                                               transaction:transaction];
}

- (void)updateWithInsertedMessage:(TSInteraction *)message transaction:(SDSAnyWriteTransaction *)transaction
{
    [self updateWithMessage:message wasMessageInserted:YES transaction:transaction];
}

- (void)updateWithUpdatedMessage:(TSInteraction *)message transaction:(SDSAnyWriteTransaction *)transaction
{
    [self updateWithMessage:message wasMessageInserted:NO transaction:transaction];
}

- (int64_t)messageSortIdForMessage:(TSInteraction *)message transaction:(SDSAnyWriteTransaction *)transaction
{
    if (message.grdbId == nil) {
        OWSFailDebug(@"Missing messageSortId.");
    } else if (message.grdbId.unsignedLongLongValue == 0) {
        OWSFailDebug(@"Invalid messageSortId.");
    } else {
        return message.grdbId.longLongValue;
    }
    return 0;
}

- (void)updateWithMessage:(TSInteraction *)message
       wasMessageInserted:(BOOL)wasMessageInserted
              transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(message != nil);
    OWSAssertDebug(transaction != nil);

    BOOL hasLastVisibleInteraction = [self hasLastVisibleInteractionWithTransaction:transaction];
    BOOL needsToClearLastVisibleSortId = hasLastVisibleInteraction && wasMessageInserted;

    if (![message shouldAppearInInboxWithTransaction:transaction]) {
        // We want to clear the last visible sort ID on any new message,
        // even if the message doesn't appear in the inbox view.
        if (needsToClearLastVisibleSortId) {
            [self clearLastVisibleInteractionWithTransaction:transaction];
        }
        [self scheduleTouchFinalizationWithTransaction:transaction];
        return;
    }

    int64_t messageSortId = [self messageSortIdForMessage:message transaction:transaction];
    BOOL needsToMarkAsVisible = !self.shouldThreadBeVisible;

    ThreadAssociatedData *associatedData = [ThreadAssociatedData fetchOrDefaultForThread:self transaction:transaction];

    BOOL needsToClearArchived = associatedData.isArchived && wasMessageInserted;

    // Don't clear archived during migrations.
    if (!CurrentAppContext().isRunningTests && !AppReadiness.isAppReady) {
        needsToClearArchived = NO;
    }

    // Don't clear archived during thread import
    if ([message isKindOfClass:TSInfoMessage.class]
        && ((TSInfoMessage *)message).messageType == TSInfoMessageSyncedThread) {
        needsToClearArchived = NO;
    }

    // Don't clear archive if muted and the user has
    // requested we don't for muted conversations.
    if (associatedData.isMuted && [SSKPreferences shouldKeepMutedChatsArchivedWithTransaction:transaction]) {
        needsToClearArchived = NO;
    }

    BOOL needsToUpdateLastInteractionRowId = messageSortId > self.lastInteractionRowId;

    BOOL needsToClearIsMarkedUnread = associatedData.isMarkedUnread && wasMessageInserted;

    if (needsToMarkAsVisible || needsToClearArchived || needsToUpdateLastInteractionRowId
        || needsToClearLastVisibleSortId || needsToClearIsMarkedUnread) {
        [self anyUpdateWithTransaction:transaction
                                 block:^(TSThread *thread) {
                                     thread.shouldThreadBeVisible = YES;
                                     thread.lastInteractionRowId = MAX(thread.lastInteractionRowId, messageSortId);
                                 }];
        [associatedData clearIsArchived:needsToClearArchived
                    clearIsMarkedUnread:needsToClearIsMarkedUnread
                   updateStorageService:YES
                            transaction:transaction];
        if (needsToClearLastVisibleSortId) {
            [self clearLastVisibleInteractionWithTransaction:transaction];
        }
    } else {
        [self scheduleTouchFinalizationWithTransaction:transaction];
    }
}

- (void)updateWithRemovedMessage:(TSInteraction *)message transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(message != nil);
    OWSAssertDebug(transaction != nil);

    int64_t messageSortId = [self messageSortIdForMessage:message transaction:transaction];
    BOOL needsToUpdateLastInteractionRowId = messageSortId == self.lastInteractionRowId;

    NSNumber *_Nullable lastVisibleSortId = [self lastVisibleSortIdWithTransaction:transaction];
    BOOL needsToUpdateLastVisibleSortId
        = (lastVisibleSortId != nil && lastVisibleSortId.unsignedLongLongValue == messageSortId);

    if (needsToUpdateLastInteractionRowId || needsToUpdateLastVisibleSortId) {
        [self anyUpdateWithTransaction:transaction
                                 block:^(TSThread *thread) {
                                     if (needsToUpdateLastInteractionRowId) {
                                         TSInteraction *_Nullable latestInteraction =
                                             [thread lastInteractionForInboxWithTransaction:transaction];
                                         thread.lastInteractionRowId = latestInteraction ? latestInteraction.sortId : 0;
                                     }
                                 }];

        if (needsToUpdateLastVisibleSortId) {
            TSInteraction *_Nullable messageBeforeDeletedMessage =
                [self firstInteractionAtOrAroundSortId:lastVisibleSortId.unsignedLongLongValue transaction:transaction];
            if (messageBeforeDeletedMessage != nil) {
                [self setLastVisibleInteractionWithSortId:messageBeforeDeletedMessage.sortId
                                       onScreenPercentage:1
                                              transaction:transaction];
            } else {
                [self clearLastVisibleInteractionWithTransaction:transaction];
            }
        }
    } else {
        [self scheduleTouchFinalizationWithTransaction:transaction];
    }
}

- (void)scheduleTouchFinalizationWithTransaction:(SDSAnyWriteTransaction *)transactionForMethod
{
    OWSAssertDebug(transactionForMethod != nil);

    // If we insert, update or remove N interactions in a given
    // transactions, we don't need to touch the same thread more
    // than once.
    [transactionForMethod addTransactionFinalizationBlockForKey:self.transactionFinalizationKey
                                                          block:^(SDSAnyWriteTransaction *transactionForBlock) {
                                                              [self.databaseStorage touchThread:self
                                                                                  shouldReindex:NO
                                                                                    transaction:transactionForBlock];
                                                          }];
}

- (void)softDeleteThreadWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [self removeAllThreadInteractionsWithTransaction:transaction];
    [self anyUpdateWithTransaction:transaction
                             block:^(TSThread *thread) {
                                 thread.messageDraft = nil;
                                 thread.shouldThreadBeVisible = NO;
                             }];

    // Delete any intents we previously donated for this thread.
    [INInteraction deleteInteractionsWithGroupIdentifier:self.uniqueId completion:^(NSError *error) {}];
}

- (BOOL)hasPendingMessageRequestWithTransaction:(GRDBReadTransaction *)transaction
{
    return [GRDBThreadFinder hasPendingMessageRequestWithThread:self transaction:transaction];
}

#pragma mark - Disappearing Messages

- (OWSDisappearingMessagesConfiguration *)disappearingMessagesConfigurationWithTransaction:
    (SDSAnyReadTransaction *)transaction
{
    return [OWSDisappearingMessagesConfiguration fetchOrBuildDefaultWithThread:self transaction:transaction];
}

- (uint32_t)disappearingMessagesDurationWithTransaction:(SDSAnyReadTransaction *)transaction
{

    OWSDisappearingMessagesConfiguration *config = [self disappearingMessagesConfigurationWithTransaction:transaction];

    if (!config.isEnabled) {
        return 0;
    } else {
        return config.durationSeconds;
    }
}

#pragma mark - Archival

+ (BOOL)legacyIsArchivedWithLastMessageDate:(nullable NSDate *)lastMessageDate
                               archivalDate:(nullable NSDate *)archivalDate
{
    if (!archivalDate) {
        return NO;
    }

    if (!lastMessageDate) {
        return YES;
    }

    return [archivalDate compare:lastMessageDate] != NSOrderedAscending;
}

- (void)updateWithDraft:(nullable MessageBody *)draftMessageBody transaction:(SDSAnyWriteTransaction *)transaction
{
    [self anyUpdateWithTransaction:transaction
                             block:^(TSThread *thread) {
                                 thread.messageDraft = draftMessageBody.text;
                                 thread.messageDraftBodyRanges = draftMessageBody.ranges;
                             }];
}

- (void)updateWithMentionNotificationMode:(TSThreadMentionNotificationMode)mentionNotificationMode
                              transaction:(SDSAnyWriteTransaction *)transaction
{
    [self anyUpdateWithTransaction:transaction
                             block:^(TSThread *thread) {
                                 thread.mentionNotificationMode = mentionNotificationMode;
                             }];
}

- (void)updateWithShouldThreadBeVisible:(BOOL)shouldThreadBeVisible transaction:(SDSAnyWriteTransaction *)transaction
{
    [self anyUpdateWithTransaction:transaction
                             block:^(TSThread *thread) { thread.shouldThreadBeVisible = shouldThreadBeVisible; }];
}

@end

NS_ASSUME_NONNULL_END
