//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "SignalBaseTest.h"
#import "Environment.h"
#import <AppMessaging/AppMessaging-Swift.h>
#import <AppServiceKit/SDSDatabaseStorage+Objc.h>
#import <AppServiceKit/AppServiceKit-Swift.h>
#import <AppServiceKit/TestAppContext.h>

NS_ASSUME_NONNULL_BEGIN

@implementation SignalBaseTest

- (void)setUp
{
    OWSLogInfo(@"");

    [super setUp];

    ClearCurrentAppContextForTests();
    [Environment clearSharedForTests];
    [SSKEnvironment clearSharedForTests];

    SetCurrentAppContext([TestAppContext new]);
    [MockSSKEnvironment activate];
    [MockEnvironment activate];

    ((MockSSKEnvironment *)SSKEnvironment.shared).groupsV2Ref = [GroupsV2Impl new];
}

- (void)tearDown
{
    OWSLogInfo(@"");

    [super tearDown];
}

-(void)readWithBlock:(void (^)(SDSAnyReadTransaction *))block
{
    [SDSDatabaseStorage.shared readWithBlock:block];
}

-(void)writeWithBlock:(void (^)(SDSAnyWriteTransaction *))block
{
    DatabaseStorageWrite(SDSDatabaseStorage.shared, block);
}

@end

NS_ASSUME_NONNULL_END
