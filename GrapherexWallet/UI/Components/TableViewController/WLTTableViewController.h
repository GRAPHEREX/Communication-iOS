//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "WLTViewController.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kOWSTable_DefaultCellHeight;

@class WLTTableItem;
@class WLTTableSection;

@interface WLTTableContents : NSObject

@property (nonatomic, nullable) NSString *title;
@property (nonatomic, readonly) NSArray<WLTTableSection *> *sections;
@property (nonatomic, nullable) NSInteger (^sectionForSectionIndexTitleBlock)(NSString *title, NSInteger index);
@property (nonatomic, nullable) NSArray<NSString *> * (^sectionIndexTitlesForTableViewBlock)(void);

- (void)addSection:(WLTTableSection *)section;

@end

#pragma mark -

@interface WLTTableSection : NSObject

@property (nonatomic, nullable) NSString *headerTitle;
@property (nonatomic, nullable) NSString *footerTitle;

@property (nonatomic, nullable) NSAttributedString *headerAttributedTitle;
@property (nonatomic, nullable) NSAttributedString *footerAttributedTitle;

@property (nonatomic, nullable) UIView *customHeaderView;
@property (nonatomic, nullable) UIView *customFooterView;
@property (nonatomic, nullable) NSNumber *customHeaderHeight;
@property (nonatomic, nullable) NSNumber *customFooterHeight;

@property (nonatomic) BOOL hasBackground;

@property (nonatomic) BOOL hasSeparators;
@property (nonatomic, nullable) NSNumber *separatorInsetLeading;
@property (nonatomic, nullable) NSNumber *separatorInsetTrailing;

@property (nonatomic, readonly) NSArray<WLTTableItem *> *items;

+ (WLTTableSection *)sectionWithTitle:(nullable NSString *)title items:(NSArray<WLTTableItem *> *)items;

- (void)addItem:(WLTTableItem *)item NS_SWIFT_NAME(add(_:));

- (void)addItems:(NSArray<WLTTableItem *> *)items NS_SWIFT_NAME(add(items:));

- (NSUInteger)itemCount;

@end

#pragma mark -

typedef void (^OWSTableActionBlock)(void);
typedef void (^OWSTableSubPageBlock)(UIViewController *viewController);
typedef UITableViewCell *_Nonnull (^OWSTableCustomCellBlock)(void);
typedef BOOL (^OWSTableSwitchBlock)(void);

@interface WLTTableItemEditAction : NSObject

@property (nonatomic) OWSTableActionBlock block;
@property (nonatomic) NSString *title;

+ (WLTTableItemEditAction *)actionWithTitle:(nullable NSString *)title block:(OWSTableActionBlock)block;

@end

#pragma mark -

@interface WLTTableItem : NSObject

@property (nonatomic, weak) UIViewController *tableViewController;
@property (nonatomic, nullable) WLTTableItemEditAction *deleteAction;
@property (nonatomic, nullable) NSNumber *customRowHeight;
@property (nonatomic, nullable, readonly) OWSTableActionBlock actionBlock;
@property (nonatomic, nullable, readonly) NSString *title;

+ (UITableViewCell *)newCell;
+ (void)configureCell:(UITableViewCell *)cell;

+ (WLTTableItem *)itemWithTitle:(NSString *)title
                    actionBlock:(nullable OWSTableActionBlock)actionBlock NS_SWIFT_NAME(init(title:actionBlock:));

+ (WLTTableItem *)itemWithCustomCell:(UITableViewCell *)customCell
                     customRowHeight:(CGFloat)customRowHeight
                         actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)itemWithCustomCellBlock:(OWSTableCustomCellBlock)customCellBlock
                              actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)itemWithCustomCellBlock:(OWSTableCustomCellBlock)customCellBlock
                          customRowHeight:(CGFloat)customRowHeight
                              actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)disclosureItemWithText:(NSString *)text actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)disclosureItemWithText:(NSString *)text
                 accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                             actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)disclosureItemWithText:(NSString *)text
                              detailText:(NSString *)detailText
                             actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)disclosureItemWithText:(NSString *)text
                              detailText:(NSString *)detailText
                 accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                             actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)disclosureItemWithText:(NSString *)text
                         customRowHeight:(CGFloat)customRowHeight
                             actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)disclosureItemWithText:(NSString *)text
                 accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                         customRowHeight:(CGFloat)customRowHeight
                             actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)checkmarkItemWithText:(NSString *)text actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)checkmarkItemWithText:(NSString *)text
                accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                            actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)itemWithText:(NSString *)text
                   actionBlock:(nullable OWSTableActionBlock)actionBlock
                 accessoryType:(UITableViewCellAccessoryType)accessoryType;

+ (WLTTableItem *)subPageItemWithText:(NSString *)text actionBlock:(nullable OWSTableSubPageBlock)actionBlock;

+ (WLTTableItem *)subPageItemWithText:(NSString *)text
                      customRowHeight:(CGFloat)customRowHeight
                          actionBlock:(nullable OWSTableSubPageBlock)actionBlock;

+ (WLTTableItem *)actionItemWithText:(NSString *)text actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)actionItemWithText:(NSString *)text
             accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                         actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)actionItemWithText:(NSString *)text
                           textColor:(nullable UIColor *)textColor
             accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                         actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)actionItemWithText:(NSString *)text
                      accessoryImage:(UIImage *)accessoryImage
             accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                         actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)softCenterLabelItemWithText:(NSString *)text;

+ (WLTTableItem *)softCenterLabelItemWithText:(NSString *)text customRowHeight:(CGFloat)customRowHeight;

+ (WLTTableItem *)labelItemWithText:(NSString *)text;

+ (WLTTableItem *)labelItemWithText:(NSString *)text accessoryText:(NSString *)accessoryText;

+ (WLTTableItem *)longDisclosureItemWithText:(NSString *)text actionBlock:(nullable OWSTableActionBlock)actionBlock;

+ (WLTTableItem *)switchItemWithText:(NSString *)text
                           isOnBlock:(OWSTableSwitchBlock)isOnBlock
                              target:(id)target
                            selector:(SEL)selector;

+ (WLTTableItem *)switchItemWithText:(NSString *)text
                           isOnBlock:(OWSTableSwitchBlock)isOnBlock
                      isEnabledBlock:(OWSTableSwitchBlock)isEnabledBlock
                              target:(id)target
                            selector:(SEL)selector;

+ (WLTTableItem *)switchItemWithText:(NSString *)text
             accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                           isOnBlock:(OWSTableSwitchBlock)isOnBlock
                      isEnabledBlock:(OWSTableSwitchBlock)isEnabledBlock
                              target:(id)target
                            selector:(SEL)selector;

- (nullable UITableViewCell *)getOrBuildCustomCell;

@end

#pragma mark -

@protocol WLTTableViewControllerDraggingDelegate <NSObject>

- (void)tableViewWillBeginDragging;

@end

@protocol WLTTableViewControllerScrollDelegate <NSObject>

- (void)tableViewDidScroll;

@end

@protocol WLTTableViewControllerEditActionDelegate <NSObject>

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol WLTTableViewControllerSwipeActionsConfigurationDelegate <NSObject>

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (nonnull UISwipeActionsConfiguration *)leadingSwipeActionsConfigurationForRowAt:(NSIndexPath *)indexPath;
- (nonnull UISwipeActionsConfiguration *)trailingSwipeActionsConfigurationForRowAt:(NSIndexPath *)indexPath;

@end

@protocol WLTTableViewControllerWillDisplayDelegate <NSObject>

- (void)willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end


#pragma mark -

@interface WLTTableViewController : WLTViewController

@property (nonatomic, weak) id<WLTTableViewControllerDraggingDelegate> draggingDelegate;
@property (nonatomic, weak) id<WLTTableViewControllerScrollDelegate> scrollDelegate;
@property (nonatomic, weak) id<WLTTableViewControllerEditActionDelegate> editActionDelegate;
@property (nonatomic, weak) id<WLTTableViewControllerSwipeActionsConfigurationDelegate> swipeActionsConfigurationDelegate;
@property (nonatomic, weak) id<WLTTableViewControllerWillDisplayDelegate> willDisplayDelegate;

@property (nonatomic) WLTTableContents *contents;
@property (nonatomic, readonly) UITableView *tableView;

@property (nonatomic) UITableViewStyle tableViewStyle;

@property (nonatomic) BOOL layoutMarginsRelativeTableContent;
@property (nonatomic) BOOL useThemeBackgroundColors;

@property (nonatomic, nullable) UIColor *customSectionHeaderFooterBackgroundColor;

@property (nonatomic) BOOL shouldAvoidKeyboard;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

#pragma mark - Presentation

- (void)presentFromViewController:(UIViewController *)fromViewController;

- (void)applyTheme;

@end

NS_ASSUME_NONNULL_END
