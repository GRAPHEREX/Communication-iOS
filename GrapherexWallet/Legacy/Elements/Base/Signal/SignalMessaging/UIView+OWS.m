//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "UIView+OWS.h"
#import "OWSMath.h"
//#import <SignalCoreKit/iOSVersions.h>
//#import <SignalMessaging/SignalMessaging-Swift.h>
//#import <SignalServiceKit/AppContext.h>
#import <Availability.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(major, minor) \
([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = major, .minorVersion = minor, .patchVersion = 0}])

NS_ASSUME_NONNULL_BEGIN

static inline CGFloat ApplicationShortDimension()
{
    return MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
}

static const CGFloat kIPhone5ScreenWidth = 320.f;
static const CGFloat kIPhone7PlusScreenWidth = 414.f;

CGFloat WLTWLTScaleFromIPhone5To7Plus(CGFloat iPhone5Value, CGFloat iPhone7PlusValue)
{
    CGFloat applicationShortDimension = ApplicationShortDimension();
    return (CGFloat)round(WLTCGFloatLerp(iPhone5Value,
        iPhone7PlusValue,
        WLTCGFloatClamp01(WLTCGFloatInverseLerp(applicationShortDimension, kIPhone5ScreenWidth, kIPhone7PlusScreenWidth))));
}

CGFloat WLTScaleFromIPhone5(CGFloat iPhone5Value)
{
    CGFloat applicationShortDimension = ApplicationShortDimension();
    return (CGFloat)round(iPhone5Value * applicationShortDimension / kIPhone5ScreenWidth);
}

#pragma mark -

@implementation UIView (OWS)

- (NSArray<NSLayoutConstraint *> *)wltAutoPinWidthToSuperviewWithMargin:(CGFloat)margin
{
    NSArray<NSLayoutConstraint *> *result = @[
        [self autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:margin],
        [self autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:margin],
    ];
    return result;
}

- (NSArray<NSLayoutConstraint *> *)wltAutoPinWidthToSuperviewMargins
{
    NSArray<NSLayoutConstraint *> *result = @[
        [self autoPinEdgeToSuperviewMargin:ALEdgeLeading],
        [self autoPinEdgeToSuperviewMargin:ALEdgeTrailing],
    ];
    return result;
}

- (NSArray<NSLayoutConstraint *> *)wltAutoPinWidthToSuperview
{
    NSArray<NSLayoutConstraint *> *result = @[
        [self autoPinEdgeToSuperviewEdge:ALEdgeLeft],
        [self autoPinEdgeToSuperviewEdge:ALEdgeRight],
    ];
    return result;
}

- (NSArray<NSLayoutConstraint *> *)wltAutoPinLeadingAndTrailingToSuperviewMargin
{
    NSArray<NSLayoutConstraint *> *result = @[
        [self wltAutoPinLeadingToSuperviewMargin],
        [self wltAutoPinTrailingToSuperviewMargin],
    ];
    return result;
}

- (NSArray<NSLayoutConstraint *> *)wltAutoPinHeightToSuperviewWithMargin:(CGFloat)margin
{
    NSArray<NSLayoutConstraint *> *result = @[
        [self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:margin],
        [self autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:margin],
    ];
    return result;
}

- (NSArray<NSLayoutConstraint *> *)wltAutoPinHeightToSuperview
{
    NSArray<NSLayoutConstraint *> *result = @[
        [self autoPinEdgeToSuperviewEdge:ALEdgeTop],
        [self autoPinEdgeToSuperviewEdge:ALEdgeBottom],
    ];
    return result;
}

- (NSArray<NSLayoutConstraint *> *)wltAutoPinHeightToSuperviewMargins
{
    NSArray<NSLayoutConstraint *> *result = @[
        [self autoPinEdgeToSuperviewMargin:ALEdgeTop],
        [self autoPinEdgeToSuperviewMargin:ALEdgeBottom],
    ];
    return result;
}

- (NSLayoutConstraint *)wltAutoHCenterInSuperview
{
    return [self autoAlignAxis:ALAxisVertical toSameAxisOfView:self.superview];
}

- (NSLayoutConstraint *)wltAutoVCenterInSuperview
{
    return [self autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.superview];
}

- (void)wltAutoPinEdgesToEdgesOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    [self autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:view];
    [self autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:view];
    [self autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:view];
    [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:view];
}

- (void)wltAutoPinHorizontalEdgesToEdgesOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    [self autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:view];
    [self autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:view];
}

- (void)wltAutoPinVerticalEdgesToEdgesOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    [self autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:view];
    [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:view];
}

- (NSLayoutConstraint *)wltAutoPinToSquareAspectRatio
{
    return [self wltAutoPinToAspectRatio:1.0];
}

- (NSLayoutConstraint *)wltAutoPinToAspectRatioWithSize:(CGSize)size {
    return [self wltAutoPinToAspectRatio:size.width / size.height];
}

- (NSLayoutConstraint *)wltAutoPinToAspectRatio:(CGFloat)ratio
{
    return [self wltAutoPinToAspectRatio:ratio relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)wltAutoPinToAspectRatio:(CGFloat)ratio relation:(NSLayoutRelation)relation
{
    // Clamp to ensure view has reasonable aspect ratio.
    CGFloat clampedRatio = WLTCGFloatClamp(ratio, 0.05f, 95.0f);
    if (clampedRatio != ratio) {
//        fatalError();
        //(@"Invalid aspect ratio: %f for view: %@", ratio, self);
    }

    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:relation
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:clampedRatio
                                                                   constant:0.f];
    [constraint autoInstall];
    return constraint;
}

#pragma mark - Content Hugging and Compression Resistance

- (void)wltSetContentHuggingLow
{
    [self wltSetContentHuggingHorizontalLow];
    [self wltSetContentHuggingVerticalLow];
}

- (void)wltSetContentHuggingHigh
{
    [self wltSetContentHuggingHorizontalHigh];
    [self wltSetContentHuggingVerticalHigh];
}

- (void)wltSetContentHuggingHorizontalLow
{
    [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)wltSetContentHuggingHorizontalHigh
{
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)wltSetContentHuggingVerticalLow
{
    [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
}

- (void)wltSetContentHuggingVerticalHigh
{
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)wltSetCompressionResistanceLow
{
    [self wltSetCompressionResistanceHorizontalLow];
    [self wltSetCompressionResistanceVerticalLow];
}

- (void)wltSetCompressionResistanceHigh
{
    [self wltSetCompressionResistanceHorizontalHigh];
    [self wltSetCompressionResistanceVerticalHigh];
}

- (void)wltSetCompressionResistanceHorizontalLow
{
    [self setContentCompressionResistancePriority:0 forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)wltSetCompressionResistanceHorizontalHigh
{
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)wltSetCompressionResistanceVerticalLow
{
    [self setContentCompressionResistancePriority:0 forAxis:UILayoutConstraintAxisVertical];
}

- (void)wltSetCompressionResistanceVerticalHigh
{
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

#pragma mark - Manual Layout

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)wltCenterOnSuperview
{
    //OWSAssertDebug(self.superview);

    CGFloat x = (CGFloat)round((self.superview.width - self.width) * 0.5f);
    CGFloat y = (CGFloat)round((self.superview.height - self.height) * 0.5f);
    self.frame = CGRectMake(x, y, self.width, self.height);
}

#pragma mark - RTL

- (NSLayoutConstraint *)wltAutoPinLeadingToSuperviewMargin
{
    return [self wltAutoPinLeadingToSuperviewMarginWithInset:0];
}

- (NSLayoutConstraint *)wltAutoPinLeadingToSuperviewMarginWithInset:(CGFloat)inset
{
    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint =
        [self.leadingAnchor constraintEqualToAnchor:self.superview.layoutMarginsGuide.leadingAnchor constant:inset];
    constraint.active = YES;
    return constraint;
}

- (NSLayoutConstraint *)wltAutoPinTrailingToSuperviewMargin
{
    return [self wltAutoPinTrailingToSuperviewMarginWithInset:0];
}

- (NSLayoutConstraint *)wltAutoPinTrailingToSuperviewMarginWithInset:(CGFloat)inset
{
    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint =
        [self.trailingAnchor constraintEqualToAnchor:self.superview.layoutMarginsGuide.trailingAnchor constant:-inset];
    constraint.active = YES;
    return constraint;
}

- (NSLayoutConstraint *)wltAutoPinBottomToSuperviewMargin
{
    return [self wltAutoPinBottomToSuperviewMarginWithInset:0.f];
}

- (NSLayoutConstraint *)wltAutoPinBottomToSuperviewMarginWithInset:(CGFloat)inset
{
    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint =
        [self.bottomAnchor constraintEqualToAnchor:self.superview.layoutMarginsGuide.bottomAnchor constant:-inset];
    constraint.active = YES;
    return constraint;
}

- (NSLayoutConstraint *)wltAutoPinTopToSuperviewMargin
{
    return [self wltAutoPinTopToSuperviewMarginWithInset:0.f];
}

- (NSLayoutConstraint *)wltAutoPinTopToSuperviewMarginWithInset:(CGFloat)inset
{
    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint =
        [self.topAnchor constraintEqualToAnchor:self.superview.layoutMarginsGuide.topAnchor constant:inset];
    constraint.active = YES;
    return constraint;
}

- (NSLayoutConstraint *)wltAutoPinLeadingToTrailingEdgeOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    return [self wltAutoPinLeadingToTrailingEdgeOfView:view offset:0];
}

- (NSLayoutConstraint *)wltAutoPinLeadingToTrailingEdgeOfView:(UIView *)view offset:(CGFloat)offset
{
    //OWSAssertDebug(view);

    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint = [self.leadingAnchor constraintEqualToAnchor:view.trailingAnchor constant:offset];
    constraint.active = YES;
    return constraint;
}

- (NSLayoutConstraint *)wltAutoPinTrailingToLeadingEdgeOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    return [self wltAutoPinTrailingToLeadingEdgeOfView:view offset:0];
}

- (NSLayoutConstraint *)wltAutoPinTrailingToLeadingEdgeOfView:(UIView *)view offset:(CGFloat)offset
{
    //OWSAssertDebug(view);

    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint = [self.trailingAnchor constraintEqualToAnchor:view.leadingAnchor constant:-offset];
    constraint.active = YES;
    return constraint;
}

- (NSLayoutConstraint *)wltAutoPinLeadingToEdgeOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    return [self wltAutoPinLeadingToEdgeOfView:view offset:0];
}

- (NSLayoutConstraint *)wltAutoPinLeadingToEdgeOfView:(UIView *)view offset:(CGFloat)offset
{
    //OWSAssertDebug(view);

    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint = [self.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:offset];
    constraint.active = YES;
    return constraint;
}

- (NSLayoutConstraint *)wltAutoPinTrailingToEdgeOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    return [self wltAutoPinTrailingToEdgeOfView:view offset:0];
}

- (NSLayoutConstraint *)wltAutoPinTrailingToEdgeOfView:(UIView *)view offset:(CGFloat)margin
{
    //OWSAssertDebug(view);

    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *constraint = [self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:margin];
    constraint.active = YES;
    return constraint;
}

+ (NSTextAlignment)wltTextAlignmentUnnatural
{
    // MARK: - SINGAL DEPENDENCY – reimplement
    return NSTextAlignmentLeft;//(CurrentAppContext().isRTL ? NSTextAlignmentLeft : NSTextAlignmentRight);
}

- (NSTextAlignment)wltTextAlignmentUnnatural
{
    return UIView.wltTextAlignmentUnnatural;
}

- (void)wltSetHLayoutMargins:(CGFloat)value
{
    UIEdgeInsets layoutMargins = self.layoutMargins;
    layoutMargins.left = value;
    layoutMargins.right = value;
    self.layoutMargins = layoutMargins;
}

- (NSArray<NSLayoutConstraint *> *)wltAutoPinToEdgesOfView:(UIView *)view
{
    //OWSAssertDebug(view);

    return @[
        [self autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:view],
        [self autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:view],
        [self autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:view],
        [self autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:view],
    ];
}

#pragma mark - Containers

+ (UIView *)containerView
{
    UIView *view = [UIView new];
    // Leading and trailing anchors honor layout margins.
    // When using a UIView as a "div" to structure layout, we don't want it to have margins.
    view.layoutMargins = UIEdgeInsetsZero;
    return view;
}

+ (UIView *)wltVerticalStackWithSubviews:(NSArray<UIView *> *)subviews spacing:(int)spacing
{
    UIView *container = [UIView containerView];
    UIView *_Nullable lastSubview = nil;
    for (UIView *subview in subviews) {
        [container addSubview:subview];
        [subview wltAutoPinWidthToSuperview];
        if (lastSubview) {
            [subview autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastSubview withOffset:spacing];
        } else {
            [subview autoPinEdgeToSuperviewEdge:ALEdgeTop];
        }
        lastSubview = subview;
    }
    [lastSubview autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    return container;
}

#pragma mark - Debugging

- (void)wltAddBorderWithColor:(UIColor *)color
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
}

- (void)wltAddRedBorder
{
    [self wltAddBorderWithColor:[UIColor redColor]];
}

- (void)wltAddRedBorderRecursively
{
    [self wltAddRedBorder];
    for (UIView *subview in self.subviews) {
        [subview wltAddRedBorderRecursively];
    }
}

- (void)wltLogFrame
{
    [self wltLogFrameWithLabel:@""];
}

- (void)wltLogFrameWithLabel:(NSString *)label
{
//  OWSLogVerbose(@"%@ frame: %@, hidden: %d, opacity: %f, layoutMargins: %@",
//        label,
//        NSStringFromCGRect(self.frame),
//        self.hidden,
//        self.layer.opacity,
//        NSStringFromUIEdgeInsets(self.layoutMargins));
}

- (void)wltLogFrameLater
{
    [self wltLogFrameLaterWithLabel:@""];
}

- (void)wltLogFrameLaterWithLabel:(NSString *)label
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self wltLogFrameWithLabel:label];
    });
}

- (void)wltLogHierarchyUpwardLaterWithLabel:(NSString *)label
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        OWSLogVerbose(@"%@ ----", label);
    });

    [self wltTraverseViewHierarchyUpwardWithVisitor:^(UIView *subview) { [subview wltLogFrameLaterWithLabel:@"\t"]; }];
}

- (void)wltTraverseViewHierarchyUpwardWithVisitor:(UIViewVisitorBlock)visitor
{
//    OWSAssertIsOnMainThread();
    //OWSAssertDebug(visitor);

    visitor(self);

    UIResponder *_Nullable responder = self;
    while (responder) {
        if ([responder isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)responder;
            visitor(view);
        }
        responder = responder.nextResponder;
    }
}

- (void)wltTraverseViewHierarchyDownwardWithVisitor:(UIViewVisitorBlock)visitor
{
//    OWSAssertIsOnMainThread();
    //OWSAssertDebug(visitor);

    visitor(self);

    for (UIView *subview in self.subviews) {
        [subview wltTraverseViewHierarchyDownwardWithVisitor:visitor];
    }
}

@end

#pragma mark -

@implementation UIScrollView (OWS)

- (BOOL)wltApplyScrollViewInsetsFix
{
    // Fix a bug that only affects iOS 11.0.x and 11.1.x.
    // The symptom is a fix weird animation that happens when using the interactive pop gesture.
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11, 0) && !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(11, 2)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#pragma clang diagnostic pop
        return YES;
    }
    return NO;
}

@end

#pragma mark -

@implementation UIStackView (OWS)

- (void)wltAddHairlineWithColor:(UIColor *)color
{
    [self wltInsertHairlineWithColor:color atIndex:self.arrangedSubviews.count];
}

- (void)wltInsertHairlineWithColor:(UIColor *)color atIndex:(NSInteger)index
{
    UIView *hairlineView = [[UIView alloc] init];
    hairlineView.backgroundColor = color;
    [hairlineView autoSetDimension:ALDimensionHeight toSize:1];

    [self insertArrangedSubview:hairlineView atIndex:index];
}

- (UIView *)wltAddBackgroundViewWithBackgroundColor:(UIColor *)backgroundColor
{
    return [self wltAddBackgroundViewWithBackgroundColor:backgroundColor cornerRadius:0.f];
}

- (UIView *)wltAddBackgroundViewWithBackgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius
{
    UIView *subview = [UIView new];
    subview.backgroundColor = backgroundColor;
    subview.layer.cornerRadius = cornerRadius;
    [self addSubview:subview];
    [subview autoPinEdgesToSuperviewEdges];
    [subview wltSetCompressionResistanceLow];
    [subview wltSetContentHuggingLow];
    [self sendSubviewToBack:subview];
    return subview;
}

- (UIView *)wltAddBorderViewWithColor:(UIColor *)color strokeWidth:(CGFloat)strokeWidth cornerRadius:(CGFloat)cornerRadius
{

    UIView *borderView = [UIView new];
    borderView.userInteractionEnabled = NO;
    borderView.backgroundColor = UIColor.clearColor;
    borderView.opaque = NO;
    borderView.layer.borderColor = color.CGColor;
    borderView.layer.borderWidth = strokeWidth;
    borderView.layer.cornerRadius = cornerRadius;
    [self addSubview:borderView];
    [borderView autoPinEdgesToSuperviewEdges];
    [borderView wltSetCompressionResistanceLow];
    [borderView wltSetContentHuggingLow];
    return borderView;
}

@end

#pragma mark -

CGFloat WLTCGHairlineWidth()
{
    return 1.f / UIScreen.mainScreen.scale;
}

CGFloat WLTCGHairlineWidthFraction(CGFloat fraction)
{
    return WLTCGHairlineWidth() * fraction;
}

NS_ASSUME_NONNULL_END
