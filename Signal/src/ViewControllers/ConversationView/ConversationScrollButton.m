//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "ConversationScrollButton.h"
#import "UIFont+OWS.h"
#import "UIView+OWS.h"
#import <SignalMessaging/SignalMessaging-Swift.h>
#import <SignalMessaging/Theme.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConversationScrollButton ()

@property (nonatomic) NSString *iconText;
@property (nonatomic) UILabel *iconLabel;
@property (nonatomic) UIView *circleView;
@property (nonatomic) UIView *shadowView;

@property (nonatomic) UIView *unreadBadge;
@property (nonatomic) UILabel *unreadLabel;

@end

#pragma mark -

@implementation ConversationScrollButton

- (nullable instancetype)initWithIconName:(NSString *)iconName
{
    self = [super initWithFrame:CGRectZero];
    if (!self) {
        return self;
    }

    self.iconText = iconName;

    [self createContents];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(themeDidChange:)
                                               name:ThemeDidChangeNotification
                                             object:nil];

    return self;
}

+ (CGFloat)circleSize
{
    return ScaleFromIPhone5To7Plus(35.f, 40.f);
}

+ (CGFloat)buttonSize
{
    return self.circleSize + 2 * 15.f;
}

- (void)themeDidChange:(NSNotification *)notification
{
    [self updateColors];
}

- (void)createContents
{
    UILabel *iconLabel = [UILabel new];
    self.iconLabel = iconLabel;
    iconLabel.userInteractionEnabled = NO;

    const CGFloat circleSize = self.class.circleSize;
    CGRect shadowRect = CGRectMake(0, 0, circleSize, circleSize);

    UIView *shadowView = [[OWSCircleView alloc] initWithDiameter:circleSize];
    self.shadowView = shadowView;
    shadowView.userInteractionEnabled = NO;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowRadius = 4;
    shadowView.layer.shadowOpacity = 0.05f;
    shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
    shadowView.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:shadowRect].CGPath;

    UIView *circleView = [[OWSCircleView alloc] initWithDiameter:circleSize];
    self.circleView = circleView;
    circleView.userInteractionEnabled = NO;
    circleView.layer.shadowOffset = CGSizeMake(0, 4.f);
    circleView.layer.shadowRadius = 12.f;
    circleView.layer.shadowOpacity = 0.3f;
    circleView.layer.shadowColor = UIColor.blackColor.CGColor;
    circleView.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:shadowRect].CGPath;

    UIView *unreadBadge = [UIView new];
    self.unreadBadge = unreadBadge;
    unreadBadge.userInteractionEnabled = NO;
    unreadBadge.layer.cornerRadius = 8;
    unreadBadge.clipsToBounds = YES;

    UILabel *unreadCountLabel = [UILabel new];
    self.unreadLabel = unreadCountLabel;
    unreadCountLabel.font = [UIFont systemFontOfSize:12];
    unreadCountLabel.textColor = UIColor.ows_whiteColor;
    unreadCountLabel.textAlignment = NSTextAlignmentCenter;

    [unreadBadge addSubview:unreadCountLabel];
    [unreadCountLabel autoPinHeightToSuperview];
    [unreadCountLabel autoPinWidthToSuperviewWithMargin:3];

    [self addSubview:shadowView];

    [self addSubview:circleView];
    [circleView autoHCenterInSuperview];
    [circleView autoPinEdgeToSuperviewEdge:ALEdgeBottom];

    [shadowView autoPinEdgesToEdgesOfView:circleView];

    [circleView addSubview:iconLabel];
    [iconLabel autoCenterInSuperview];

    [self addSubview:unreadBadge];

    [unreadBadge autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:circleView withOffset:8];
    [unreadBadge autoHCenterInSuperview];
    [unreadBadge autoSetDimension:ALDimensionHeight toSize:16];
    [unreadBadge autoSetDimension:ALDimensionWidth toSize:16 relation:NSLayoutRelationGreaterThanOrEqual];
    [unreadBadge autoMatchDimension:ALDimensionWidth
                        toDimension:ALDimensionWidth
                             ofView:self
                         withOffset:0
                           relation:NSLayoutRelationLessThanOrEqual];
    [unreadBadge autoPinEdgeToSuperviewEdge:ALEdgeTop];

    [self updateColors];
}

- (void)setUnreadCount:(NSUInteger)unreadCount
{
    _unreadCount = unreadCount;

    self.unreadLabel.text = [NSString stringWithFormat:@"%lu", unreadCount];
    self.unreadBadge.hidden = unreadCount < 1;
}

- (void)updateColors
{
    self.unreadBadge.backgroundColor = UIColor.ows_accentBlueColor;
    
    UIColor *foregroundColor;
    UIColor *backgroundColor;
    if (_unreadCount > 0) {
        foregroundColor = UIColor.st_accentGreen;
        backgroundColor = UIColor.st_neutralGray;
    } else {
        foregroundColor = UIColor.st_accentGreen;
        backgroundColor = Theme.scrollButtonBackgroundColor;
    }
    
    const CGFloat circleSize = self.class.circleSize;
    self.circleView.backgroundColor = backgroundColor;
    self.iconLabel.attributedText = [[NSAttributedString alloc]
                                     initWithString: self.iconText
                                     attributes:@{
                                         NSFontAttributeName : [UIFont ows_fontAwesomeFont:circleSize * 0.8f],
                                         NSForegroundColorAttributeName : foregroundColor,
                                         NSBaselineOffsetAttributeName : @(-0.5f),
                                     }];
}

@end

NS_ASSUME_NONNULL_END
