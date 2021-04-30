//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AnyPromise;
@class TSAttachmentStream;

@protocol AFMultipartFormData;

void AppendMultipartFormV4Path(id<AFMultipartFormData> formData, NSString *name, NSString *dataString);

@interface OWSUploadFormV4 : NSObject

@property (nonatomic, readonly) NSString *policy;
@property (nonatomic, readonly) NSString *credential;
@property (nonatomic, readonly) NSString *attachmentId;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPolicy:(NSString *)policy
                    credential:(NSString *)credential
                  attachmentId:(NSString *)attachmentId;

+ (nullable OWSUploadFormV4 *)parseDictionary:(nullable NSDictionary *)formResponseObject;

- (void)appendToForm:(id<AFMultipartFormData>)formData;

@end

#pragma mark -

typedef void (^UploadProgressBlock)(NSProgress *progress);

// A strong reference should be maintained to this object
// until it completes.  If it is deallocated, the upload
// may be cancelled.
//
// This class can be safely accessed and used from any thread.
@interface OWSAvatarUploadV4 : NSObject

// This property is set on success for non-nil uploads.
@property (nonatomic, nullable) NSString *urlPath;
@property (nonatomic, nullable) NSString *credentials;
@property (nonatomic, nullable) NSString *bucket;

- (AnyPromise *)uploadAvatarToService:(NSData *_Nullable)avatarData;

@end

#pragma mark -

//// A strong reference should be maintained to this object
//// until it completes.  If it is deallocated, the upload
//// may be cancelled.
////
//// This class can be safely accessed and used from any thread.
//@interface OWSAttachmentUploadV4 : NSObject
//
//// These properties are set on success.
//@property (nonatomic, nullable) NSData *encryptionKey;
//@property (nonatomic, nullable) NSData *digest;
//@property (nonatomic) UInt64 serverId;
//@property (nonatomic) NSString *bucket;
//@property (nonatomic) NSString *credentionals;
//@property (nonatomic) UInt64 uploadTimestamp;
//
//- (AnyPromise *)uploadAttachmentToService:(TSAttachmentStream *)attachmentStream
//                            progressBlock:(UploadProgressBlock)progressBlock;
//
//@end

NS_ASSUME_NONNULL_END
