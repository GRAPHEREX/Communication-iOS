//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "OWSGroupAvatarBuilder.h"
#import "OWSContactsManager.h"
#import "TSGroupThread.h"
#import <SignalCoreKit/NSData+OWS.h>
#import <SignalMessaging/SignalMessaging-Swift.h>
#import <SignalServiceKit/SSKEnvironment.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSGroupAvatarBuilder ()

@property (nonatomic, readonly) TSGroupThread *thread;
@property (nonatomic, readonly) NSUInteger diameter;

@end

@implementation OWSGroupAvatarBuilder

- (instancetype)initWithThread:(TSGroupThread *)thread diameter:(NSUInteger)diameter
{
    self = [super init];
    if (!self) {
        return self;
    }

    _thread = thread;
    _diameter = diameter;

    return self;
}

#pragma mark -

- (nullable UIImage *)buildSavedImage
{
    return self.thread.groupModel.groupAvatarImage;
}

- (nullable UIImage *)buildSavedImageWithTransaction:(SDSAnyReadTransaction *)transaction
{
    return self.thread.groupModel.groupAvatarImage;
}

- (nullable UIImage *)buildDefaultImage
{
    return [self.class defaultAvatarForGroupId:self.thread.groupModel.groupId
                                     groupName:self.thread.groupModel.groupNameOrDefault
                         conversationColorName:self.thread.conversationColorName
                                      diameter:self.diameter];
}

+ (nullable UIImage *)defaultAvatarForGroupId:(NSData *)groupId
                                    groupName:(NSString *)groupName
                        conversationColorName:(NSString *)conversationColorName
                                     diameter:(NSUInteger)diameter
{
    NSString *cacheKey = [NSString
        stringWithFormat:@"%@-%d-%lu", groupId.hexadecimalString, Theme.isDarkThemeEnabled, (unsigned long)diameter];

    UIImage *_Nullable cachedAvatar =
        [OWSGroupAvatarBuilder.contactsManagerImpl getImageFromAvatarCacheWithKey:cacheKey diameter:(CGFloat)diameter];
    if (cachedAvatar) {
        return cachedAvatar;
    }

#ifdef SHOW_COLOR_PICKER
    UIColor *backgroundColor =
        [OWSConversationColor conversationColorOrDefaultForColorName:conversationColorName].themeColor;
#else
    UIColor *backgroundColor = [OWSConversationColor ows_steelColor];
#endif
    UIImage *_Nullable image =
        [OWSGroupAvatarBuilder groupAvatarImageWithBackgroundColor:backgroundColor diameter:diameter colorName: conversationColorName groupName: groupName];
    if (!image) {
        OWSFailDebug(@"Could not create group avatar.");
        return nil;
    }

    [OWSGroupAvatarBuilder.contactsManagerImpl setImageForAvatarCache:image forKey:cacheKey diameter:diameter];
    return image;
}

+ (nullable UIImage *)selectionAvatarForGroupId:(NSData *)groupId
                                      groupName:(NSString *)groupName
                        conversationColorName:(NSString *)conversationColorName
                                     diameter:(NSUInteger)diameter
{
    NSString *cacheKey = [NSString
        stringWithFormat:@"%@-%d-%lu", groupId.hexadecimalString, Theme.isDarkThemeEnabled, (unsigned long)diameter];

    UIImage *_Nullable cachedAvatar =
        [OWSGroupAvatarBuilder.contactsManagerImpl getImageFromAvatarCacheWithKey:cacheKey diameter:(CGFloat)diameter];
    if (cachedAvatar) {
        return cachedAvatar;
    }

#ifdef SHOW_COLOR_PICKER
    UIColor *backgroundColor =
        [OWSConversationColor conversationColorOrDefaultForColorName:conversationColorName].themeColor;
#else
    UIColor *backgroundColor = [OWSConversationColor ows_steelColor];
#endif
    UIImage *_Nullable image =
        [OWSGroupAvatarBuilder selectionGroupAvatarImageWithBackgroundColor:backgroundColor diameter:diameter];
    if (!image) {
        OWSFailDebug(@"Could not create group avatar.");
        return nil;
    }

    [OWSGroupAvatarBuilder.contactsManagerImpl setImageForAvatarCache:image forKey:cacheKey diameter:diameter];
    return image;
}

+ (nullable UIImage *)groupAvatarImageWithBackgroundColor:(UIColor *)backgroundColor diameter:(NSUInteger)diameter colorName:(ConversationColorName)colorName groupName:(NSString *)groupName
{
    UIColor *color = [OWSConversationColor conversationColorOrDefaultForColorName:colorName].themeColor;
    NSString *initials = [OWSGroupAvatarBuilder initialsFrom:groupName];
    
    return [OWSAvatarBuilder avatarImageWithInitials:initials
                                      backgroundColor:color
                                             diameter:diameter];
}

+ (nullable UIImage *)selectionGroupAvatarImageWithBackgroundColor:(UIColor *)backgroundColor diameter:(NSUInteger)diameter
{
    UIImage *icon = [UIImage imageNamed:@"profile_camera_large"];
    // Adjust asset size to reflect the output diameter.
    CGFloat scaling = diameter * 0.015f;
    CGSize iconSize = CGSizeScale(icon.size, scaling);
    return [OWSAvatarBuilder avatarImageWithIcon:icon
                                        iconSize:iconSize
                                 backgroundColor:backgroundColor
                                        diameter:diameter];
}

+ (NSString *)initialsFrom:(NSString *)text {
    NSMutableString * firstCharacters = [NSMutableString string];
    NSArray * words = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * word in words) {
        if ([word length] > 0) {
            NSString * firstLetter = [word substringToIndex:1];
            [firstCharacters appendString:[firstLetter uppercaseString]];
        }
    }
    return firstCharacters.copy;
}

@end

NS_ASSUME_NONNULL_END
