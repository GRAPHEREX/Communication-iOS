//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "OWSUpload.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <PromiseKit/AnyPromise.h>
#import <SignalCoreKit/Cryptography.h>
#import <SignalCoreKit/NSData+OWS.h>
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/MIMETypeUtil.h>
#import <SignalServiceKit/OWSError.h>
#import <SignalServiceKit/OWSRequestFactory.h>
#import <SignalServiceKit/OWSSignalService.h>
#import <SignalServiceKit/SSKEnvironment.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <SignalServiceKit/TSAttachmentStream.h>
#import <SignalServiceKit/TSNetworkManager.h>
#import <SignalServiceKit/TSSocketManager.h>

NS_ASSUME_NONNULL_BEGIN

void AppendMultipartFormV4Path(id<AFMultipartFormData> formData, NSString *name, NSString *dataString)
{
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    [formData appendPartWithFormData:data name:name];
}

#pragma mark -

// See: https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html
@implementation OWSUploadFormV4

- (instancetype)initWithPolicy:(NSString *)policy
                    credential:(NSString *)credential
                  attachmentId:(NSString *)attachmentId
{
    self = [super init];

    if (self) {
        _policy = policy;
        _credential = credential;
        _attachmentId = attachmentId;
    }
    return self;
}

+ (nullable OWSUploadFormV4 *)parseDictionary:(nullable NSDictionary *)formResponseObject
{
    if (![formResponseObject isKindOfClass:[NSDictionary class]]) {
        OWSFailDebug(@"Invalid upload form.");
        return nil;
    }
    NSDictionary *responseMap = formResponseObject;

    NSString *_Nullable formPolicy = responseMap[@"policy"];
    if (![formPolicy isKindOfClass:[NSString class]] || formPolicy.length < 1) {
        OWSFailDebug(@"Invalid upload form: acl.");
        return nil;
    }

    NSString *_Nullable formCredential = responseMap[@"credential"];
    if (![formCredential isKindOfClass:[NSString class]] || formCredential.length < 1) {
        OWSFailDebug(@"Invalid upload form: credential.");
        return nil;
    }
    
    NSString *_Nullable attachmentId = responseMap[@"attachmentId"];
    if (![attachmentId isKindOfClass:[NSString class]] || attachmentId.length < 1) {
        OWSFailDebug(@"Invalid upload form: credential.");
        return nil;
    }

    return [[OWSUploadFormV4 alloc] initWithPolicy:formPolicy
                                        credential:formCredential
                                      attachmentId:attachmentId];
}

- (void)appendToForm:(id<AFMultipartFormData>)formData
{
    AppendMultipartFormV4Path(formData, @"policy", self.policy);
}

@end

#pragma mark -

@interface OWSAvatarUploadV4 ()

@property (nonatomic, nullable) NSData *avatarData;

@end

#pragma mark -

@implementation OWSAvatarUploadV4

#pragma mark - Avatars

// If avatarData is nil, we are clearing the avatar.
- (AnyPromise *)uploadAvatarToService:(nullable NSData *)avatarData
{
    OWSAssertDebug(avatarData == nil || avatarData.length > 0);
    self.avatarData = avatarData;

    __weak OWSAvatarUploadV4 *weakSelf = self;
    AnyPromise *promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TSRequest *formRequest = [OWSRequestFactory profileAvatarUploadFormRequest];
            [self.networkManager makeRequest:formRequest
                success:^(NSURLSessionDataTask *task, id _Nullable formResponseObject) {
                    OWSAvatarUploadV4 *_Nullable strongSelf = weakSelf;
                    if (!strongSelf) {
                        return resolve(OWSErrorWithCodeDescription(OWSErrorCodeUploadFailed, @"Upload deallocated"));
                    }

                    if (avatarData == nil) {
                        OWSLogDebug(@"successfully cleared avatar");
                        return resolve(@(1));
                    }

                    [strongSelf parseFormAndUpload:formResponseObject]
                        .thenInBackground(^{ return resolve(@(1)); })
                        .catchInBackground(^(NSError *error) { resolve(error); });
                }
                failure:^(NSURLSessionDataTask *task, NSError *error) {
                    OWSLogError(@"Failed to get profile avatar upload form: %@", error);
                    resolve(error);
                }];
        });
    }];
    return promise;
}

- (AnyPromise *)parseFormAndUpload:(nullable id)formResponseObject
{
    OWSUploadFormV4 *_Nullable form = [OWSUploadFormV4 parseDictionary:formResponseObject];
    if (!form) {
        return [AnyPromise
            promiseWithValue:OWSErrorWithCodeDescription(OWSErrorCodeUploadFailed, @"Invalid upload form.")];
    }
    
    NSError *error;
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:form.policy options:0];
    NSDictionary *decodedDictionary = [NSJSONSerialization JSONObjectWithData:decodedData options:NSJSONReadingAllowFragments error:&error];
    self.bucket = decodedDictionary[@"bucket"];
    self.urlPath = decodedDictionary[@"policy"][@"attachmentId"];
    self.credentials = decodedDictionary[@"policy"][@"credential"];
    
    NSString *uploadUrlPath = @"/api/v1/osp/objects";
    return [OWSUpload uploadV4WithData:self.avatarData
                            uploadForm:form
                         uploadUrlPath:uploadUrlPath
                         progressBlock:nil];
}

@end

//#pragma mark - Attachments
//
//@interface OWSAttachmentUploadV4 ()
//
//@property (nonatomic) TSAttachmentStream *attachmentStream;
//
//@end
//
//#pragma mark -
//
//@implementation OWSAttachmentUploadV4
//
//#pragma mark - Dependencies
//
//- (AFHTTPSessionManager *)uploadHTTPManager
//{
//    return [[OWSSignalService shared] sessionManagerForCdnNumber:0];
//}
//
//- (TSNetworkManager *)networkManager
//{
//    return SSKEnvironment.shared.networkManager;
//}
//
//- (TSSocketManager *)socketManager
//{
//    return SSKEnvironment.shared.socketManager;
//}
//
//#pragma mark -
//
//- (nullable NSData *)attachmentData
//{
//    OWSAssertDebug(self.attachmentStream);
//
//    NSData *encryptionKey;
//    NSData *digest;
//    NSError *error;
//    NSData *attachmentData = [self.attachmentStream readDataFromFileWithError:&error];
//    if (error) {
//        OWSLogError(@"Failed to read attachment data with error: %@", error);
//        return nil;
//    }
//
//    NSData *_Nullable encryptedAttachmentData = [Cryptography encryptAttachmentData:attachmentData
//                                                                          shouldPad:YES
//                                                                             outKey:&encryptionKey
//                                                                          outDigest:&digest];
//    if (!encryptedAttachmentData) {
//        OWSFailDebug(@"could not encrypt attachment data.");
//        return nil;
//    }
//
//    self.encryptionKey = encryptionKey;
//    self.digest = digest;
//
//    return encryptedAttachmentData;
//}
//
//- (AnyPromise *)uploadAttachmentToService:(TSAttachmentStream *)attachmentStream
//                            progressBlock:(UploadProgressBlock)progressBlock
//{
//    OWSAssertDebug(attachmentStream);
//
//    self.attachmentStream = attachmentStream;
//
//    AnyPromise *promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self uploadAttachmentToService:resolve progressBlock:progressBlock skipWebsocket:NO];
//        });
//    }];
//    return promise;
//}
//
//- (void)uploadAttachmentToService:(PMKResolver)resolve
//                    progressBlock:(UploadProgressBlock)progressBlock
//                    skipWebsocket:(BOOL)skipWebsocket
//{
//    TSRequest *formRequest = [OWSRequestFactory allocAttachmentRequestV4];
//
//    __weak OWSAttachmentUploadV4 *weakSelf = self;
//    void (^formSuccess)(id _Nullable) = ^(id _Nullable formResponseObject) {
//            OWSAttachmentUploadV4 *_Nullable strongSelf = weakSelf;
//        if (!strongSelf) {
//            return resolve(OWSErrorWithCodeDescription(OWSErrorCodeUploadFailed, @"Upload deallocated"));
//        }
//
//        [strongSelf parseFormAndUpload:formResponseObject progressBlock:progressBlock]
//                .thenInBackground(^{ resolve(@(1)); })
//                .catchInBackground(^(NSError *error) { resolve(error); });
//    };
//    void (^formFailure)(NSError *) = ^(NSError *error) {
//        OWSLogError(@"Failed to get profile avatar upload form: %@", error);
//        resolve(error);
//    };
//
//
//    [self.networkManager makeRequest:formRequest
//        success:^(NSURLSessionDataTask *task, id _Nullable formResponseObject) {
//            formSuccess(formResponseObject);
//        }
//        failure:^(NSURLSessionDataTask *task, NSError *error) {
//            formFailure(error);
//        }
//     ];
//}
//
//#pragma mark -
//
//- (AnyPromise *)parseFormAndUpload:(nullable id)formResponseObject
//                     progressBlock:(UploadProgressBlock)progressBlock
//{
//    OWSUploadFormV4 *_Nullable form = [OWSUploadFormV4 parseDictionary:formResponseObject];
//    if (!form) {
//        return [AnyPromise
//            promiseWithValue:OWSErrorWithCodeDescription(OWSErrorCodeUploadFailed, @"Invalid upload form.")];
//    }
//
//    UInt64 serverId = [form.attachmentId longLongValue];
//    if (serverId < 1) {
//        return [AnyPromise
//            promiseWithValue:OWSErrorWithCodeDescription(OWSErrorCodeUploadFailed, @"Invalid upload form.")];
//    }
//
//    self.serverId = serverId;
//
//    NSError *error;
//    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:form.policy options:0];
//    NSDictionary *decodedDictionary = [NSJSONSerialization JSONObjectWithData:decodedData options:NSJSONReadingAllowFragments error:&error];
//    self.bucket = decodedDictionary[@"bucket"];
//    self.credentionals = decodedDictionary[@"policy"][@"credential"];
//
//    __weak OWSAttachmentUploadV4 *weakSelf = self;
//    NSString *uploadUrlPath = @"/api/v1/osp/objects";
//    return [OWSUpload uploadV4WithData:self.attachmentData
//                            uploadForm:form
//                         uploadUrlPath:uploadUrlPath
//                         progressBlock:progressBlock]
//        .then(^{
//            weakSelf.uploadTimestamp = NSDate.ows_millisecondTimeStamp;
//        });
//}
//
//@end

NS_ASSUME_NONNULL_END

