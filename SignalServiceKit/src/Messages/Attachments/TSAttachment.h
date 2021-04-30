//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class SDSAnyReadTransaction;
@class TSAttachmentPointer;
@class TSMessage;

typedef NS_ENUM(NSUInteger, TSAttachmentType) {
    TSAttachmentTypeDefault = 0,
    TSAttachmentTypeVoiceMessage = 1,
    TSAttachmentTypeBorderless = 2,
    TSAttachmentTypeGIF = 3,
};

@interface TSAttachment : BaseModel

// TSAttachment is a base class for TSAttachmentPointer (a yet-to-be-downloaded
// incoming attachment) and TSAttachmentStream (an outgoing or already-downloaded
// incoming attachment).
@property (atomic, readwrite) UInt64 serverId;
@property (atomic, readwrite) NSString *credentionals;
@property (atomic, readwrite) NSString *bucket;
@property (atomic) NSString *cdnKey;
@property (atomic) UInt32 cdnNumber;
@property (atomic, readwrite, nullable) NSData *encryptionKey;
@property (nonatomic, readonly) NSString *contentType;
@property (nonatomic) TSAttachmentType attachmentType;

// Though now required, may incorrectly be 0 on legacy attachments.
@property (nonatomic, readonly) UInt32 byteCount;

// Represents the "source" filename sent or received in the protos,
// not the filename on disk.
@property (nonatomic, readonly, nullable) NSString *sourceFilename;

@property (nonatomic, readonly, nullable) NSString *blurHash;

// This property will be non-zero if set.
@property (nonatomic) UInt64 uploadTimestamp;

#pragma mark - Media Album

@property (nonatomic, readonly, nullable) NSString *caption;
@property (nonatomic, readonly, nullable) NSString *albumMessageId;
@property (nonatomic, readonly) NSString *emoji;

- (nullable TSMessage *)fetchAlbumMessageWithTransaction:(SDSAnyReadTransaction *)transaction
    NS_SWIFT_NAME(fetchAlbumMessage(transaction:));

// `migrateAlbumMessageId` is only used in the migration to the new multi-attachment message scheme,
// and shouldn't be used as a general purpose setter. Instead, `albumMessageId` should be passed as
// an initializer param.
- (void)migrateAlbumMessageId:(NSString *)albumMesssageId;

#pragma mark -

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUniqueId:(NSString *)uniqueId NS_UNAVAILABLE;
- (instancetype)initWithGrdbId:(int64_t)grdbId uniqueId:(NSString *)uniqueId NS_UNAVAILABLE;

// This constructor is used for new instances of TSAttachmentPointer,
// i.e. undownloaded incoming attachments.
- (instancetype)initWithServerId:(UInt64)serverId
                   credentionals:(NSString *)credentionals
                          bucket:(NSString *)bucket
                          cdnKey:(NSString *)cdnKey
                       cdnNumber:(UInt32)cdnNumber
                   encryptionKey:(NSData *)encryptionKey
                       byteCount:(UInt32)byteCount
                     contentType:(NSString *)contentType
                  sourceFilename:(nullable NSString *)sourceFilename
                         caption:(nullable NSString *)caption
                  albumMessageId:(nullable NSString *)albumMessageId
                        blurHash:(nullable NSString *)blurHash
                 uploadTimestamp:(unsigned long long)uploadTimestamp NS_DESIGNATED_INITIALIZER;

// This constructor is used for new instances of TSAttachmentPointer,
// i.e. undownloaded restoring attachments.
- (instancetype)initForRestoreWithUniqueId:(NSString *)uniqueId
                               contentType:(NSString *)contentType
                            sourceFilename:(nullable NSString *)sourceFilename
                                   caption:(nullable NSString *)caption
                            albumMessageId:(nullable NSString *)albumMessageId NS_DESIGNATED_INITIALIZER;

// This constructor is used for new instances of TSAttachmentStream
// that represent new, un-uploaded outgoing attachments.
- (instancetype)initAttachmentWithContentType:(NSString *)contentType
                                    byteCount:(UInt32)byteCount
                               sourceFilename:(nullable NSString *)sourceFilename
                                      caption:(nullable NSString *)caption
                               albumMessageId:(nullable NSString *)albumMessageId NS_DESIGNATED_INITIALIZER;

// This constructor is used for new instances of TSAttachmentStream
// that represent downloaded incoming attachments.
- (instancetype)initWithPointer:(TSAttachmentPointer *)pointer
                    transaction:(SDSAnyReadTransaction *)transaction NS_DESIGNATED_INITIALIZER;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
                  albumMessageId:(nullable NSString *)albumMessageId
                  attachmentType:(TSAttachmentType)attachmentType
                        blurHash:(nullable NSString *)blurHash
                       byteCount:(unsigned int)byteCount
                         caption:(nullable NSString *)caption
                          cdnKey:(NSString *)cdnKey
                       cdnNumber:(unsigned int)cdnNumber
                     contentType:(NSString *)contentType
                   encryptionKey:(nullable NSData *)encryptionKey
                        serverId:(unsigned long long)serverId
                 credentionals:(NSString *)credentionals
                        bucket:(NSString *)bucket
                  sourceFilename:(nullable NSString *)sourceFilename
                 uploadTimestamp:(unsigned long long)uploadTimestamp
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:albumMessageId:attachmentType:blurHash:byteCount:caption:cdnKey:cdnNumber:contentType:encryptionKey:serverId:credentionals:bucket:sourceFilename:uploadTimestamp:));

// clang-format on

// --- CODE GENERATION MARKER

- (void)upgradeFromAttachmentSchemaVersion:(NSUInteger)attachmentSchemaVersion;

@property (nonatomic, readonly) BOOL isAnimated;
@property (nonatomic, readonly) BOOL isImage;
@property (nonatomic, readonly) BOOL isWebpImage;
@property (nonatomic, readonly) BOOL isVideo;
@property (nonatomic, readonly) BOOL isAudio;
@property (nonatomic, readonly) BOOL isVoiceMessage;
@property (nonatomic, readonly) BOOL isBorderless;
@property (nonatomic, readonly) BOOL isLoopingVideo;
@property (nonatomic, readonly) BOOL isVisualMedia;
@property (nonatomic, readonly) BOOL isOversizeText;

+ (NSString *)emojiForMimeType:(NSString *)contentType;

// This should only ever be used before the attachment is saved,
// after that point the content type will be already set.
- (void)setDefaultContentType:(NSString *)contentType;

// This method should only be called on instances which have
// not yet been inserted into the database.
- (void)replaceUnsavedContentType:(NSString *)contentType NS_SWIFT_NAME(replaceUnsavedContentType(_:));

#pragma mark - Update With...

- (void)updateWithBlurHash:(NSString *)blurHash transaction:(SDSAnyWriteTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
