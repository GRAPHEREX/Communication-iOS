//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc
public extension WLTTableItem {

    static var primaryLabelFont: UIFont {
        return UIFont.wlt_dynamicTypeBodyClamped
    }

    static var accessoryLabelFont: UIFont {
        return UIFont.wlt_dynamicTypeBodyClamped
    }

    static var iconSpacing: CGFloat { 16 }
    static var iconSize: CGFloat { 24 }

    static func buildCell(name: String, iconView: UIView) -> UITableViewCell {
        return buildCell(name: name, iconView: iconView, textColor: UIColor.black, iconSpacing: self.iconSpacing)
    }
    
    static func buildCell(name: String, iconView: UIView, textColor: UIColor) -> UITableViewCell {
        return buildCell(name: name, iconView: iconView, textColor: UIColor.black, iconSpacing: self.iconSpacing)
    }

    static func buildCell(name: String, iconView: UIView, iconSpacing: CGFloat) -> UITableViewCell {
        return buildCell(name: name, iconView: iconView, textColor: UIColor.black, iconSpacing: self.iconSpacing)
    }
    
    static func buildCell(name: String, iconView: UIView, textColor: UIColor, iconSpacing: CGFloat) -> UITableViewCell {
        assert(name.count > 0)

        let cell = WLTTableItem.newCell()
        cell.preservesSuperviewLayoutMargins = true
        cell.contentView.preservesSuperviewLayoutMargins = true

        let rowLabel = UILabel()
        rowLabel.text = name
        rowLabel.textColor = textColor
        rowLabel.font = WLTTableItem.primaryLabelFont
        rowLabel.lineBreakMode = .byTruncatingTail

        let contentRow = UIStackView(arrangedSubviews: [ iconView, rowLabel ])
        contentRow.spacing = iconSpacing

        cell.contentView.addSubview(contentRow)
        contentRow.autoPinEdgesToSuperviewMargins()

        return cell
    }

//    static func imageView(forIcon icon: ThemeIcon,
//                          tintColor: UIColor? = nil,
//                          iconSize: CGFloat = iconSize) -> UIImageView {
//        let iconImage = Theme.iconImage(icon)
//        let iconView = UIImageView(image: iconImage)
//        iconView.tintColor = tintColor ?? Theme.primaryIconColor
//        iconView.contentMode = .scaleAspectFit
//        iconView.layer.minificationFilter = .trilinear
//        iconView.layer.magnificationFilter = .trilinear
//        iconView.autoSetDimensions(to: CGSize(square: iconSize))
//        return iconView
//    }
//
//    static func buildCell(name: String,
//                          icon: ThemeIcon,
//                          accessibilityIdentifier: String? = nil) -> UITableViewCell {
//        let iconView = imageView(forIcon: icon)
//        let cell = buildCell(name: name, iconView: iconView)
//        cell.accessibilityIdentifier = accessibilityIdentifier
//        return cell
//    }
//
//    static func buildDisclosureCell(name: String,
//                                    icon: ThemeIcon,
//                                    accessibilityIdentifier: String) -> UITableViewCell {
//        let cell = buildCell(name: name, icon: icon)
//        cell.accessoryType = .disclosureIndicator
//        cell.accessibilityIdentifier = accessibilityIdentifier
//        return cell
//    }
//
//    static func buildLabelCell(name: String,
//                               icon: ThemeIcon,
//                               accessibilityIdentifier: String) -> UITableViewCell {
//        let cell = buildCell(name: name, icon: icon)
//        cell.accessoryType = .none
//        cell.accessibilityIdentifier = accessibilityIdentifier
//        return cell
//    }
//
//    static func disclosureItem(icon: ThemeIcon,
//                               name: String,
//                               accessoryText: String? = nil,
//                               accessibilityIdentifier: String,
//                               actionBlock: (() -> Void)?) -> WLTTableItem {
//        item(icon: icon,
//             name: name,
//             accessoryText: accessoryText,
//             accessoryType: .disclosureIndicator,
//             accessibilityIdentifier: accessibilityIdentifier,
//             actionBlock: actionBlock)
//    }
//
//    @nonobjc
//    static func actionItem(icon: ThemeIcon? = nil,
//                           tintColor: UIColor? = nil,
//                           name: String,
//                           textColor: UIColor? = nil,
//                           accessoryText: String? = nil,
//                           accessoryImage: UIImage? = nil,
//                           accessibilityIdentifier: String,
//                           actionBlock: (() -> Void)?) -> WLTTableItem {
//        item(icon: icon,
//             tintColor: tintColor,
//             name: name,
//             textColor: textColor,
//             accessoryText: accessoryText,
//             accessoryImage: accessoryImage,
//             accessibilityIdentifier: accessibilityIdentifier,
//             actionBlock: actionBlock)
//    }
//
//    @nonobjc
//    static func item(icon: ThemeIcon? = nil,
//                     tintColor: UIColor? = nil,
//                     name: String,
//                     textColor: UIColor? = nil,
//                     accessoryText: String? = nil,
//                     accessoryType: UITableViewCell.AccessoryType = .none,
//                     accessoryImage: UIImage? = nil,
//                     accessibilityIdentifier: String,
//                     actionBlock: (() -> Void)? = nil) -> WLTTableItem {
//
//        WLTTableItem(customCellBlock: {
//            WLTTableItem.buildCellWithAccessoryLabel(icon: icon,
//                                                     tintColor: tintColor,
//                                                     itemName: name,
//                                                     textColor: textColor,
//                                                     accessoryText: accessoryText,
//                                                     accessoryType: accessoryType,
//                                                     accessoryImage: accessoryImage,
//                                                     accessibilityIdentifier: accessibilityIdentifier)
//            },
//                     actionBlock: actionBlock)
//    }

    @available(swift, obsoleted: 1.0)
    static func buildCellWithAccessoryLabel(itemName: String,
                                            textColor: UIColor?,
                                            accessoryText: String?,
                                            accessoryType: UITableViewCell.AccessoryType,
                                            accessoryImage: UIImage?,
                                            accessibilityIdentifier: String?) -> UITableViewCell {
        buildIconNameCell(itemName: itemName,
                          textColor: textColor,
                          accessoryText: accessoryText,
                          accessoryType: accessoryType,
                          accessoryImage: accessoryImage,
                          accessibilityIdentifier: accessibilityIdentifier)
    }

//    @nonobjc
//    static func buildCellWithAccessoryLabel(icon: ThemeIcon? = nil,
//                                            tintColor: UIColor? = nil,
//                                            itemName: String,
//                                            textColor: UIColor? = nil,
//                                            accessoryText: String? = nil,
//                                            accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator,
//                                            accessoryImage: UIImage? = nil,
//                                            accessibilityIdentifier: String? = nil) -> UITableViewCell {
//        buildIconNameCell(icon: icon,
//                          tintColor: tintColor,
//                          itemName: itemName,
//                          textColor: textColor,
//                          accessoryText: accessoryText,
//                          accessoryType: accessoryType,
//                          accessoryImage: accessoryImage,
//                          accessibilityIdentifier: accessibilityIdentifier)
//    }
//
    @nonobjc
    static func buildIconNameCell(tintColor: UIColor? = nil,
                                  itemName: String,
                                  textColor: UIColor? = nil,
                                  accessoryText: String? = nil,
                                  accessoryType: UITableViewCell.AccessoryType = .none,
                                  accessoryImage: UIImage? = nil,
                                  customColor: UIColor? = nil,
                                  accessibilityIdentifier: String? = nil) -> UITableViewCell {

        // We can't use the built-in UITableViewCell with CellStyle.value1,
        // because if the content of the primary label and the accessory label
        // overflow the cell layout, their contents will overlap.  We want
        // the labels to truncate in that scenario.
        let cell = WLTTableItem.newCell()
        cell.preservesSuperviewLayoutMargins = true
        cell.contentView.preservesSuperviewLayoutMargins = true

        var subviews = [UIView]()

        // MARK: - SINGAL DEPENDENCY – reimplement
//        if let icon = icon {
//            let iconView = self.imageView(forIcon: icon, tintColor: customColor ?? tintColor, iconSize: iconSize)
//            iconView.wltSetCompressionResistanceHorizontalHigh()
//            subviews.append(iconView)
//        }

        let nameLabel = UILabel()
        nameLabel.text = itemName
        if let textColor = textColor {
            nameLabel.textColor = textColor
        } else {
            nameLabel.textColor = UIColor.black
        }
        nameLabel.font = WLTTableItem.primaryLabelFont
        nameLabel.adjustsFontForContentSizeCategory = true

        // Having two side-by-side multi-line labels makes
        // autolayout *really* confused because it doesn't
        // seem to know which height to respect (if they are
        // of different intrinsic height). It leads to lots of
        // very strange indeterminant behavior. To work around,
        // we only allow the longer of the two labels to be
        // multi-line.
        if itemName.count >= (accessoryText ?? "").count {
            nameLabel.numberOfLines = 0
            nameLabel.lineBreakMode = .byWordWrapping
        } else {
            nameLabel.numberOfLines = 1
            nameLabel.lineBreakMode = .byTruncatingTail
        }

        nameLabel.wltSetContentHuggingLow()
        nameLabel.wltSetCompressionResistanceHigh()
        subviews.append(nameLabel)
        if let customColor = customColor {
            nameLabel.textColor = customColor
        }

        if let accessoryText = accessoryText {
            let accessoryLabel = UILabel()
            accessoryLabel.text = accessoryText
            accessoryLabel.textColor = UIColor.black //Theme.isDarkThemeEnabled ? .wlt_gray25 : .wlt_gray45
            accessoryLabel.font = WLTTableItem.accessoryLabelFont
            accessoryLabel.adjustsFontForContentSizeCategory = true

            if itemName.count >= accessoryText.count {
                accessoryLabel.numberOfLines = 1
                accessoryLabel.lineBreakMode = .byTruncatingTail
            } else {
                accessoryLabel.numberOfLines = 0
                accessoryLabel.lineBreakMode = .byWordWrapping
            }

            accessoryLabel.wltSetCompressionResistanceHigh()
            accessoryLabel.wltSetContentHuggingHorizontalHigh()
            accessoryLabel.wltSetContentHuggingVerticalLow()
            subviews.append(accessoryLabel)
        }

        let contentRow = UIStackView(arrangedSubviews: subviews)
        contentRow.alignment = .center
        contentRow.spacing = self.iconSpacing
        cell.contentView.addSubview(contentRow)

        contentRow.wltSetContentHuggingHigh()
        contentRow.autoPinEdgesToSuperviewMargins()
        contentRow.autoSetDimension(.height, toSize: iconSize, relation: .greaterThanOrEqual)

        cell.accessibilityIdentifier = accessibilityIdentifier

        if let accessoryImage = accessoryImage {
            let accessoryImageView = UIImageView()
            accessoryImageView.setTemplateImage(
                accessoryImage,
                // Match the OS accessory view colors
                tintColor: UIColor.black //Theme.isDarkThemeEnabled ? .wlt_whiteAlpha25 : .wlt_blackAlpha25
            )
            accessoryImageView.sizeToFit()
            cell.accessoryView = accessoryImageView
        } else {
            cell.accessoryType = accessoryType
        }

        return cell
    }

//    static func buildIconInCircleView(icon: ThemeIcon,
//                                      innerIconSize: CGFloat) -> UIView {
//        return buildIconInCircleView(icon: icon,
//                                     iconSize: nil,
//                                     innerIconSize: innerIconSize,
//                                     iconTintColor: nil)
//    }
//
//    static func buildIconInCircleView(icon: ThemeIcon,
//                                      innerIconSize: CGFloat,
//                                      iconTintColor: UIColor) -> UIView {
//        return buildIconInCircleView(icon: icon,
//                                     iconSize: nil,
//                                     innerIconSize: innerIconSize,
//                                     iconTintColor: iconTintColor)
//    }
}

// MARK: -

public extension WLTTableItem {
//    static func buildIconInCircleView(icon: ThemeIcon,
//                                      iconSize iconSizeParam: UInt? = nil,
//                                      innerIconSize innerIconSizeParam: CGFloat? = nil,
//                                      iconTintColor: UIColor? = nil) -> UIView {
//        let iconSize = CGFloat(iconSizeParam ?? kStandardAvatarSize)
//        let innerIconSize: CGFloat
//        if let innerIconSizeParam = innerIconSizeParam {
//            innerIconSize = innerIconSizeParam
//        } else {
//            innerIconSize = CGFloat(iconSize) * 0.6
//        }
//        let iconView = WLTTableItem.imageView(forIcon: icon, tintColor: iconTintColor ?? Theme.accentBlueColor, iconSize: innerIconSize)
//        let iconWrapper = UIView.container()
//        iconWrapper.addSubview(iconView)
//        iconView.autoCenterInSuperview()
//        iconWrapper.backgroundColor = UIColor.black //Theme.isDarkThemeEnabled ? .wlt_gray65 : .wlt_gray02
//        iconWrapper.layer.cornerRadius = iconSize * 0.5
//        iconWrapper.autoSetDimensions(to: CGSize(square: iconSize))
//        iconWrapper.wltSetCompressionResistanceHigh()
//        iconWrapper.wltSetContentHuggingHigh()
//        return iconWrapper
//    }
}

// MARK: - Declarative Initializers

public extension WLTTableContents {

    convenience init(title: String? = nil,
                     sections: [WLTTableSection] = []) {
        self.init()
        if let title = title {
            self.title = title
        }
        sections.forEach { section in
            self.addSection(section)
        }
    }

}

public extension WLTTableSection {

    convenience init(title: String? = nil,
                     header: UIView? = nil,
                     items: [WLTTableItem] = [],
                     footer: UIView? = nil) {

        self.init(title: title, items: items)
        self.customHeaderView = header
        self.customFooterView = footer
    }

    convenience init(title: String? = nil,
                     header: (() -> UIView?) = {nil},
                     items: [WLTTableItem] = [],
                     footer: (() -> UIView?) = {nil}) {
        self.init(title: title,
                  header: header(),
                  items: items,
                  footer: footer())
    }
}

public extension WLTTableItem {
    convenience init(
        customCell: UITableViewCell,
        rowHeight: CGFloat = UITableView.automaticDimension,
        actionBlock: OWSTableActionBlock? = nil) {

        self.init(customCell: customCell, customRowHeight: rowHeight, actionBlock: actionBlock)
    }
}
