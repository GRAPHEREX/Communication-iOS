//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import <PureLayout/PureLayout.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UIViewVisitorBlock)(UIView *view);

// A convenience method for doing responsive layout. Scales between two
// reference values (for iPhone 5 and iPhone 7 Plus) to the current device
// based on screen width, linearly interpolating.
CGFloat WLTWLTScaleFromIPhone5To7Plus(CGFloat iPhone5Value, CGFloat iPhone7PlusValue);

// A convenience method for doing responsive layout. Scales a reference
// value (for iPhone 5) to the current device based on screen width,
// linearly interpolating through the origin.
CGFloat WLTScaleFromIPhone5(CGFloat iPhone5Value);

// A set of helper methods for doing layout with PureLayout.
@interface UIView (OWS)

// Pins the width of this view to the width of its superview, with uniform margins.
- (NSArray<NSLayoutConstraint *> *)wltAutoPinWidthToSuperviewWithMargin:(CGFloat)margin;
- (NSArray<NSLayoutConstraint *> *)wltAutoPinWidthToSuperview;
- (NSArray<NSLayoutConstraint *> *)wltAutoPinWidthToSuperviewMargins;
// Pins the height of this view to the height of its superview, with uniform margins.
- (NSArray<NSLayoutConstraint *> *)wltAutoPinHeightToSuperviewWithMargin:(CGFloat)margin;
- (NSArray<NSLayoutConstraint *> *)wltAutoPinHeightToSuperview;
- (NSArray<NSLayoutConstraint *> *)wltAutoPinHeightToSuperviewMargins;

- (NSLayoutConstraint *)wltAutoHCenterInSuperview;
- (NSLayoutConstraint *)wltAutoVCenterInSuperview;

- (void)wltAutoPinEdgesToEdgesOfView:(UIView *)view;
- (void)wltAutoPinHorizontalEdgesToEdgesOfView:(UIView *)view;
- (void)wltAutoPinVerticalEdgesToEdgesOfView:(UIView *)view;

- (NSLayoutConstraint *)wltAutoPinToSquareAspectRatio;
- (NSLayoutConstraint *)wltAutoPinToAspectRatioWithSize:(CGSize)size;
- (NSLayoutConstraint *)wltAutoPinToAspectRatio:(CGFloat)ratio;
- (NSLayoutConstraint *)wltAutoPinToAspectRatio:(CGFloat)ratio relation:(NSLayoutRelation)relation;

#pragma mark - Content Hugging and Compression Resistance

- (void)wltSetContentHuggingLow;
- (void)wltSetContentHuggingHigh;
- (void)wltSetContentHuggingHorizontalLow;
- (void)wltSetContentHuggingHorizontalHigh;
- (void)wltSetContentHuggingVerticalLow;
- (void)wltSetContentHuggingVerticalHigh;

- (void)wltSetCompressionResistanceLow;
- (void)wltSetCompressionResistanceHigh;
- (void)wltSetCompressionResistanceHorizontalLow;
- (void)wltSetCompressionResistanceHorizontalHigh;
- (void)wltSetCompressionResistanceVerticalLow;
- (void)wltSetCompressionResistanceVerticalHigh;

#pragma mark - Manual Layout

@property (nonatomic, readonly) CGFloat wltLeft;
@property (nonatomic, readonly) CGFloat wltRight;
@property (nonatomic, readonly) CGFloat wltTop;
@property (nonatomic, readonly) CGFloat wltBottom;
@property (nonatomic, readonly) CGFloat wltWidth;
@property (nonatomic, readonly) CGFloat wltHeight;

- (void)wltCenterOnSuperview;

#pragma mark - RTL

// For correct right-to-left layout behavior, use "leading" and "trailing",
// not "left" and "right".
//
// These methods use layoutMarginsGuide anchors, which behave differently than
// the PureLayout alternatives you indicated. Honoring layoutMargins is
// particularly important in cell layouts, where it lets us align with the
// complicated built-in behavior of table and collection view cells' default
// contents.
//
// NOTE: the margin values are inverted in RTL layouts.

- (NSArray<NSLayoutConstraint *> *)wltAutoPinLeadingAndTrailingToSuperviewMargin;
- (NSLayoutConstraint *)wltAutoPinLeadingToSuperviewMargin;
- (NSLayoutConstraint *)wltAutoPinLeadingToSuperviewMarginWithInset:(CGFloat)margin;
- (NSLayoutConstraint *)wltAutoPinTrailingToSuperviewMargin;
- (NSLayoutConstraint *)wltAutoPinTrailingToSuperviewMarginWithInset:(CGFloat)margin;

- (NSLayoutConstraint *)wltAutoPinTopToSuperviewMargin;
- (NSLayoutConstraint *)wltAutoPinTopToSuperviewMarginWithInset:(CGFloat)margin;
- (NSLayoutConstraint *)wltAutoPinBottomToSuperviewMargin;
- (NSLayoutConstraint *)wltAutoPinBottomToSuperviewMarginWithInset:(CGFloat)margin;

- (NSLayoutConstraint *)wltAutoPinLeadingToTrailingEdgeOfView:(UIView *)view;
- (NSLayoutConstraint *)wltAutoPinLeadingToTrailingEdgeOfView:(UIView *)view offset:(CGFloat)margin;
- (NSLayoutConstraint *)wltAutoPinTrailingToLeadingEdgeOfView:(UIView *)view;
- (NSLayoutConstraint *)wltAutoPinTrailingToLeadingEdgeOfView:(UIView *)view offset:(CGFloat)margin;
- (NSLayoutConstraint *)wltAutoPinLeadingToEdgeOfView:(UIView *)view;
- (NSLayoutConstraint *)wltAutoPinLeadingToEdgeOfView:(UIView *)view offset:(CGFloat)margin;
- (NSLayoutConstraint *)wltAutoPinTrailingToEdgeOfView:(UIView *)view;
- (NSLayoutConstraint *)wltAutoPinTrailingToEdgeOfView:(UIView *)view offset:(CGFloat)margin;
// Return Right on LTR and Left on RTL.
+ (NSTextAlignment)wltTextAlignmentUnnatural;
- (NSTextAlignment)wltTextAlignmentUnnatural;
// Leading and trailing anchors honor layout margins.
// When using a UIView as a "div" to structure layout, we don't want it to have margins.
- (void)wltSetHLayoutMargins:(CGFloat)value;

- (NSArray<NSLayoutConstraint *> *)wltAutoPinToEdgesOfView:(UIView *)view;

- (void)wltTraverseViewHierarchyUpwardWithVisitor:(UIViewVisitorBlock)visitor;

- (void)wltTraverseViewHierarchyDownwardWithVisitor:(UIViewVisitorBlock)visitor;

#pragma mark - Containers

//+ (UIView *)containerView;

+ (UIView *)wltVerticalStackWithSubviews:(NSArray<UIView *> *)subviews spacing:(int)spacing;

#pragma mark - Debugging

- (void)wltAddBorderWithColor:(UIColor *)color;
- (void)wltAddRedBorder;

// Add red border to self, and all subviews recursively.
- (void)wltAddRedBorderRecursively;

#ifdef DEBUG
- (void)wltLogFrame;
- (void)wltLogFrameWithLabel:(NSString *)label;
- (void)wltLogFrameLater;
- (void)wltLogFrameLaterWithLabel:(NSString *)label;
- (void)wltLogHierarchyUpwardLaterWithLabel:(NSString *)label;
#endif

@end

#pragma mark -

@interface UIScrollView (OWS)

// Returns YES if contentInsetAdjustmentBehavior is disabled.
- (BOOL)wltApplyScrollViewInsetsFix;

@end

#pragma mark -

@interface UIStackView (OWS)

- (void)wltAddHairlineWithColor:(UIColor *)color;
- (void)wltInsertHairlineWithColor:(UIColor *)color atIndex:(NSInteger)index;

- (UIView *)wltAddBackgroundViewWithBackgroundColor:(UIColor *)backgroundColor;
- (UIView *)wltAddBackgroundViewWithBackgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius;

- (UIView *)wltAddBorderViewWithColor:(UIColor *)color strokeWidth:(CGFloat)strokeWidth cornerRadius:(CGFloat)cornerRadius;

@end

#pragma mark - Macros

CGFloat WLTCGHairlineWidth(void);

/// Primarily useful to adjust border widths to
/// compensate for antialiasing around light
/// color curves on dark backgrounds.
CGFloat WLTCGHairlineWidthFraction(CGFloat);

NS_ASSUME_NONNULL_END
