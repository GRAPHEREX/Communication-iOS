//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "SignalBaseTest.h"
#import <SignalCoreKit/NSData+OWS.h>
#import <SignalCoreKit/Randomness.h>
#import <AppServiceKit/ContactsManagerProtocol.h>
#import <AppServiceKit/OWSContactsOutputStream.h>
#import <AppServiceKit/OWSGroupsOutputStream.h>
#import <AppServiceKit/SignalAccount.h>
#import <AppServiceKit/AppServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@interface ProtoParsingTest : SignalBaseTest

@end

#pragma mark -

@implementation ProtoParsingTest

- (void)testProtoParsing_empty
{
    NSData *data = [NSData new];
    NSError *error;
    SSKProtoEnvelope *_Nullable envelope = [[SSKProtoEnvelope alloc] initWithSerializedData:data error:&error];
    XCTAssertNil(envelope);
    XCTAssertNotNil(error);
}

- (void)testProtoParsing_wrong1
{
    NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    SSKProtoEnvelope *_Nullable envelope = [[SSKProtoEnvelope alloc] initWithSerializedData:data error:&error];
    XCTAssertNil(envelope);
    XCTAssertNotNil(error);
}

@end

NS_ASSUME_NONNULL_END
