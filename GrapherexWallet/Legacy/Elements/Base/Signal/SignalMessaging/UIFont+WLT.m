//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "UIFont+WLT.h"
#import <GrapherexWallet/GrapherexWallet-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation UIFont (WLT)

+ (UIFont *)wlt_thinFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size weight:UIFontWeightThin];
}

+ (UIFont *)wlt_lightFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size weight:UIFontWeightLight];
}

+ (UIFont *)wlt_regularFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size weight:UIFontWeightRegular];
}

+ (UIFont *)wlt_semiboldFontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size weight:UIFontWeightSemibold];
}

+ (UIFont *)wlt_monospacedDigitFontWithSize:(CGFloat)size
{
    return [self monospacedDigitSystemFontOfSize:size weight:UIFontWeightRegular];
}

#pragma mark - SkyTech Fonts

+ (UIFont *)wlt_sfUiTextRegularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"SFUIText-Regular" size:size];
}

+ (UIFont *)wlt_sfUiTextSemiboldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"SFUIText-Semibold" size:size];
}

+ (UIFont *)wlt_robotoRegularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Roboto-Regular" size:size];
}

#pragma mark - Icon Fonts

+ (UIFont *)wlt_fontAwesomeFont:(CGFloat)size
{
    return [UIFont fontWithName:@"FontAwesome" size:size];
}

+ (UIFont *)wlt_dripIconsFont:(CGFloat)size
{
    return [UIFont fontWithName:@"dripicons-v2" size:size];
}

+ (UIFont *)wlt_elegantIconsFont:(CGFloat)size
{
    return [UIFont fontWithName:@"ElegantIcons" size:size];
}

#pragma mark - Dynamic Type

+ (UIFont *)wlt_dynamicTypeTitle1Font
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
}

+ (UIFont *)wlt_dynamicTypeTitle2Font
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
}

+ (UIFont *)wlt_dynamicTypeTitle3Font
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
}

+ (UIFont *)wlt_dynamicTypeHeadlineFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

+ (UIFont *)wlt_dynamicTypeBodyFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

+ (UIFont *)wlt_dynamicTypeBody2Font
{
    return self.wlt_dynamicTypeSubheadlineFont;
}

+ (UIFont *)wlt_dynamicTypeCalloutFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
}

+ (UIFont *)wlt_dynamicTypeSubheadlineFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIFont *)wlt_dynamicTypeFootnoteFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

+ (UIFont *)wlt_dynamicTypeCaption1Font
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

+ (UIFont *)wlt_dynamicTypeCaption2Font
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

#pragma mark - Dynamic Type Clamped

+ (UIFont *)preferredFontForTextStyleClamped:(UIFontTextStyle)fontTextStyle
{
    // We clamp the dynamic type sizes at the max size available
    // without "larger accessibility sizes" enabled.
    static NSDictionary<UIFontTextStyle, NSNumber *> *maxPointSizeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        maxPointSizeMap = @{
            UIFontTextStyleTitle1 : @(34.0),
            UIFontTextStyleTitle2 : @(28.0),
            UIFontTextStyleTitle3 : @(26.0),
            UIFontTextStyleHeadline : @(23.0),
            UIFontTextStyleBody : @(23.0),
            UIFontTextStyleCallout : @(22.0),
            UIFontTextStyleSubheadline : @(21.0),
            UIFontTextStyleFootnote : @(19.0),
            UIFontTextStyleCaption1 : @(18.0),
            UIFontTextStyleCaption2 : @(17.0),
            UIFontTextStyleLargeTitle: @(40.0)
        };
    });

    // From the documentation of -[id<UIContentSizeCategoryAdjusting> adjustsFontForContentSizeCategory:]
    // Dynamic sizing is only supported with fonts that are:
    // a. Vended using +preferredFontForTextStyle... with a valid UIFontTextStyle
    // b. Vended from -[UIFontMetrics scaledFontForFont:] or one of its variants
    //
    // If we clamps fonts by checking the resulting point size and then creating a new, smaller UIFont with
    // a fallback max size, we'll lose dynamic sizing. Max sizes can be specified using UIFontMetrics though.
    //
    // UIFontMetrics will only operate on unscaled fonts. So we do this dance to cap the system default styles
    // 1. Grab the standard, unscaled font by using the default trait collection
    // 2. Use UIFontMetrics to scale it up, capped at the desired max size
    UITraitCollection *defaultTraitCollection =
        [UITraitCollection traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryLarge];
    UIFont *unscaledFont = [UIFont preferredFontForTextStyle:fontTextStyle
                               compatibleWithTraitCollection:defaultTraitCollection];

    UIFontMetrics *desiredStyleMetrics = [[UIFontMetrics alloc] initForTextStyle:fontTextStyle];
    NSNumber *_Nullable maxPointSize = maxPointSizeMap[fontTextStyle];
    if (maxPointSize) {
        return [desiredStyleMetrics scaledFontForFont:unscaledFont maximumPointSize:maxPointSize.floatValue];
    } else {
        //OWSSwiftUtils.owsFail(@"Missing max point size for style: %@", fontTextStyle);
        return [desiredStyleMetrics scaledFontForFont:unscaledFont];
    }
}

+ (UIFont *)wlt_dynamicTypeLargeTitle1ClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleLargeTitle];
}

+ (UIFont *)wlt_dynamicTypeTitle1ClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleTitle1];
}

+ (UIFont *)wlt_dynamicTypeTitle2ClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleTitle2];
}

+ (UIFont *)wlt_dynamicTypeTitle3ClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleTitle3];
}

+ (UIFont *)wlt_dynamicTypeHeadlineClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleHeadline];
}

+ (UIFont *)wlt_dynamicTypeBodyClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleBody];
}

+ (UIFont *)wlt_dynamicTypeCalloutClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleCallout];
}

+ (UIFont *)wlt_dynamicTypeSubheadlineClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleSubheadline];
}

+ (UIFont *)wlt_dynamicTypeFootnoteClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleFootnote];
}

+ (UIFont *)wlt_dynamicTypeCaption1ClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleCaption1];
}

+ (UIFont *)wlt_dynamicTypeCaption2ClampedFont
{
    return [UIFont preferredFontForTextStyleClamped:UIFontTextStyleCaption2];
}

#pragma mark - Styles

- (UIFont *)wlt_italic
{
    return [self styleWithSymbolicTraits:UIFontDescriptorTraitItalic];
}

- (UIFont *)styleWithSymbolicTraits:(UIFontDescriptorSymbolicTraits)symbolicTraits
{
    UIFontDescriptor *fontDescriptor = [self.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:0];
//    OWSAssertDebug(font);
    return font ?: self;
}

- (UIFont *)wlt_medium
{
    // The recommended approach of deriving "medium" weight fonts for dynamic
    // type fonts is:
    //
    // [UIFontDescriptor fontDescriptorByAddingAttributes:...]
    //
    // But this doesn't seem to work in practice on iOS 11 using UIFontWeightMedium.

    UIFont *derivedFont = [UIFont systemFontOfSize:self.pointSize weight:UIFontWeightMedium];
    return derivedFont;
}

- (UIFont *)wlt_semibold
{
    // The recommended approach of deriving "semibold" weight fonts for dynamic
    // type fonts is:
    //
    // [UIFontDescriptor fontDescriptorByAddingAttributes:...]
    //
    // But this doesn't seem to work in practice on iOS 11 using UIFontWeightSemibold.

    UIFont *derivedFont = [UIFont systemFontOfSize:self.pointSize weight:UIFontWeightSemibold];
    return derivedFont;
}

- (UIFont *)wlt_monospaced
{
    return [self.class wlt_monospacedDigitFontWithSize:self.pointSize];
}


@end

NS_ASSUME_NONNULL_END
