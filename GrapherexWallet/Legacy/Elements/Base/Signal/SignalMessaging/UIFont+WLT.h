//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (WLT)

+ (UIFont *)wlt_thinFontWithSize:(CGFloat)size;

+ (UIFont *)wlt_lightFontWithSize:(CGFloat)size;

+ (UIFont *)wlt_regularFontWithSize:(CGFloat)size;

+ (UIFont *)wlt_semiboldFontWithSize:(CGFloat)size;

+ (UIFont *)wlt_monospacedDigitFontWithSize:(CGFloat)size;

#pragma mark - SkyTech Fonts

+ (UIFont *)stwlt_sfUiTextRegularFontWithSize:(CGFloat)size;

+ (UIFont *)stwlt_sfUiTextSemiboldFontWithSize:(CGFloat)size;

+ (UIFont *)stwlt_robotoRegularFontWithSize:(CGFloat)size;

#pragma mark - Icon Fonts

+ (UIFont *)wlt_fontAwesomeFont:(CGFloat)size;
+ (UIFont *)wlt_dripIconsFont:(CGFloat)size;
+ (UIFont *)wlt_elegantIconsFont:(CGFloat)size;

#pragma mark - Dynamic Type

@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeTitle1Font;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeTitle2Font;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeTitle3Font;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeHeadlineFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeBodyFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeBody2Font;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeCalloutFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeSubheadlineFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeFootnoteFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeCaption1Font;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeCaption2Font;

#pragma mark - Dynamic Type Clamped

@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeLargeTitle1ClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeTitle1ClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeTitle2ClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeTitle3ClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeHeadlineClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeBodyClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeCalloutClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeSubheadlineClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeFootnoteClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeCaption1ClampedFont;
@property (class, readonly, nonatomic) UIFont *wlt_dynamicTypeCaption2ClampedFont;

#pragma mark - Styles

@property (readonly, nonatomic) UIFont *wlt_italic;
@property (readonly, nonatomic) UIFont *wlt_semibold;
@property (readonly, nonatomic) UIFont *wlt_medium;
@property (readonly, nonatomic) UIFont *wlt_monospaced;

@end

NS_ASSUME_NONNULL_END
