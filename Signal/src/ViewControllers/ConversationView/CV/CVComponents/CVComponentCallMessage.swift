//
//  Copyright (c) 2021 SkyTech. All rights reserved.
//

import Foundation

@objc
public class CVComponentCallMessage: CVComponentBase, CVRootComponent {
    
    public let isDedicatedCell = false
    public var cellReuseIdentifier: CVCellReuseIdentifier {
        CVCellReuseIdentifier.callMessage
    }

    private let callMessage: CVComponentState.CallMessage
    private var call: TSCall { return callMessage.call }
    
    required init(itemModel: CVItemModel, callMessage: CVComponentState.CallMessage) {
        self.callMessage = callMessage
        super.init(itemModel: itemModel)
    }
    
    private var selectionViewSpacing: CGFloat { ConversationStyle.messageStackSpacing }

    public func configureCellRootComponent(cellView: UIView,
                                           cellMeasurement: CVCellMeasurement,
                                           componentDelegate: CVComponentDelegate,
                                           cellSelection: CVCellSelection,
                                           messageSwipeActionState: CVMessageSwipeActionState,
                                           componentView: CVComponentView) {

        guard let componentView = componentView as? CVComponentViewCallMessage else {
            owsFailDebug("Unexpected componentView.")
            return
        }
        
        configureForRendering(componentView: componentView,
                              cellMeasurement: cellMeasurement,
                              componentDelegate: componentDelegate)
        
        let rootView = componentView.rootView
        let isReusing = rootView.superview != nil
        if !isReusing {
            owsAssertDebug(cellView.layoutMargins == .zero)
            owsAssertDebug(cellView.subviews.isEmpty)
            
            cellView.addSubview(rootView)
            rootView.autoPinEdge(toSuperviewEdge: .top)
            rootView.autoPinEdge(toSuperviewEdge: .bottom)
            rootView.autoSetDimension(.width, toSize: cellWidth)
        }
        
        var leadingView: UIView?
        if isShowingSelectionUI {
            owsAssertDebug(!isReusing)

            let selectionView = componentView.selectionView
            selectionView.isSelected = componentDelegate.cvc_isMessageSelected(interaction)
            cellView.addSubview(selectionView)
            selectionView.autoPinEdge(toSuperviewEdge: .top)
            selectionView.autoPinEdge(toSuperviewEdge: .bottom)
            selectionView.autoPinEdge(.leading, to: .leading, of: cellView, withOffset: conversationStyle.gutterLeading)
            leadingView = selectionView
        }
        
        if isReusing {
        } else if isIncoming {
            if let leadingView = leadingView {
                rootView.autoPinEdge(.leading, to: .trailing, of: leadingView, withOffset: selectionViewSpacing)
            } else {
                rootView.autoPinEdge(toSuperviewMargin: .leading)
            }
        } else {
            rootView.autoPinEdge(toSuperviewMargin: .trailing)
        }
    }

    public func buildComponentView(componentDelegate: CVComponentDelegate) -> CVComponentView {
        CVComponentViewCallMessage()
    }

    public func configureForRendering(componentView: CVComponentView,
                                      cellMeasurement: CVCellMeasurement,
                                      componentDelegate: CVComponentDelegate) {
        guard let componentView = componentView as? CVComponentViewCallMessage else {
            owsFailDebug("Unexpected componentView.")
            return
        }

        let outerStackView = componentView.outerStackView
        let bubbleView = componentView.bubbleView
        let innerStackView = componentView.innerStackView
        let vStackView = componentView.vStackView
        let hStackView = componentView.hStackView

        outerStackView.apply(config: outerStackViewConfig)
        innerStackView.apply(config: innerStackViewConfig)
        innerStackView.alignment = .center
        
        bubbleView.setContentHuggingLow()
        bubbleView.setCompressionResistanceLow()
        outerStackView.addArrangedSubview(bubbleView)
        
        innerStackView.setContentHuggingLow()
        innerStackView.setCompressionResistanceLow()
        bubbleView.addSubview(innerStackView)
        innerStackView.autoPinEdgesToSuperviewEdges()
        
        let textColor = itemModel.conversationStyle.bubbleTextColor(isIncoming: isIncoming)
        
        let iconView = componentView.iconView
        iconView.image = phoneImage
        iconView.tintColor = textColor
        
        let titleLabel = componentView.titleLabel
        titleLabelConfig(text: call.shortPreviewText(), textColor: textColor).applyForRendering(label: titleLabel)
        
        let timestampLabel = componentView.timestampLabel
        timestampLabelConfig(text: DateUtil.formatMessageTimestamp(itemModel.interaction.timestamp, shouldUseLongFormat: false), textColor: textColor).applyForRendering(label: timestampLabel)
        
        let subtitleIconView = componentView.subtitleIconView
        subtitleIconView.image = subtitleIcon
        subtitleIconView.tintColor = subtitleIconColor
        
        hStackView.apply(config: hStackViewConfig)
        hStackView.addArrangedSubview(subtitleIconView)
        hStackView.addArrangedSubview(timestampLabel)
        
        vStackView.apply(config: vStackViewConfig)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(hStackView)
        
        innerStackView.addArrangedSubview(vStackView)
        innerStackView.addArrangedSubview(iconView)

        bubbleView.fillColor = itemModel.conversationStyle.bubbleColor(isIncoming: isIncoming)
    }
    
    public func measure(maxWidth: CGFloat, measurementBuilder: CVCellMeasurement.Builder) -> CGSize {
        owsAssertDebug(maxWidth > 0)
        
        let bubbleWidth = cellWidth - conversationStyle.gutterLeading - conversationStyle.gutterTrailing
        let maxTitleWidth = bubbleWidth - innerLayoutMargins.left - innerLayoutMargins.right - ConversationStyle.messageStackSpacing - phoneImage.size.width
        
        let titleLabelSize = titleLabelConfig(text: call.shortPreviewText(), textColor: .black).measure(maxWidth: maxTitleWidth)
        
        let timestampLabelSize = timestampLabelConfig(text: DateUtil.formatMessageTimestamp(itemModel.interaction.timestamp, shouldUseLongFormat: false), textColor: .black).measure(maxWidth: maxTitleWidth)
        
        let cellHeight = innerLayoutMargins.top + titleLabelSize.height + vStackViewConfig.spacing + max(timestampLabelSize.height, subtitleIcon.size.height) + innerLayoutMargins.bottom
        
        return CGSize(width: cellWidth, height: cellHeight).ceil
    }
    
    public override func handleTap(sender: UITapGestureRecognizer, componentDelegate: CVComponentDelegate, componentView: CVComponentView, renderItem: CVRenderItem) -> Bool {
        guard let componentView = componentView as? CVComponentViewCallMessage else {
            owsFailDebug("Unexpected componentView.")
            return false
        }

        if isShowingSelectionUI {
            let selectionView = componentView.selectionView
            let itemViewModel = CVItemViewModelImpl(renderItem: renderItem)
            if componentDelegate.cvc_isMessageSelected(interaction) {
                selectionView.isSelected = false
                componentDelegate.cvc_didDeselectViewItem(itemViewModel)
            } else {
                selectionView.isSelected = true
                componentDelegate.cvc_didSelectViewItem(itemViewModel)
            }
            // Suppress other tap handling during selection mode.
            return true
        }
        
        if let action = callMessage.action {
            let rootView = componentView.rootView
            if rootView.containsGestureLocation(sender) {
                action.action.perform(delegate: componentDelegate)
                return true
            }
        }

        return false
    }
    
    public override func findLongPressHandler(sender: UILongPressGestureRecognizer,
                                              componentDelegate: CVComponentDelegate,
                                              componentView: CVComponentView,
                                              renderItem: CVRenderItem) -> CVLongPressHandler? {
        return CVLongPressHandler(delegate: componentDelegate,
                                  renderItem: renderItem,
                                  gestureLocation: .systemMessage)
    }
}

// MARK: - Configs
private extension CVComponentCallMessage {
    
    var cellWidth: CGFloat {
        UIScreen.main.bounds.width/2 + 40
    }
    
    var outerStackViewConfig: CVStackViewConfig {
        CVStackViewConfig(axis: .horizontal,
                          alignment: .fill,
                          spacing: ConversationStyle.messageStackSpacing,
                          layoutMargins: outerLayoutMargins)
    }

    var outerLayoutMargins: UIEdgeInsets {
        UIEdgeInsets(top: 0,
                     leading: conversationStyle.gutterLeading,
                     bottom: 0,
                     trailing: conversationStyle.gutterTrailing)
    }

    var innerStackViewConfig: CVStackViewConfig {
        CVStackViewConfig(axis: .horizontal,
                          alignment: .fill,
                          spacing: ConversationStyle.messageStackSpacing,
                          layoutMargins: innerLayoutMargins)
    }
    
    var innerLayoutMargins: UIEdgeInsets {
        conversationStyle.textInsets
    }
    
    var hStackViewConfig: CVStackViewConfig {
        CVStackViewConfig(axis: .horizontal,
                          alignment: .center,
                          spacing: ConversationStyle.messageStackSpacing,
                          layoutMargins: .zero)
    }
    
    var vStackViewConfig: CVStackViewConfig {
        CVStackViewConfig(axis: .vertical,
                          alignment: .leading,
                          spacing: ConversationStyle.compactMessageSpacing,
                          layoutMargins: .zero)
    }
    
    func titleLabelConfig(text: String, textColor: UIColor) -> CVLabelConfig {
        CVLabelConfig(text: text,
                      font: UIFont.st_sfUiTextSemiboldFont(withSize: 16).ows_semibold,
                      textColor: textColor,
                      numberOfLines: 0)
    }
    
    func timestampLabelConfig(text: String, textColor: UIColor) -> CVLabelConfig {
        CVLabelConfig(text: text,
                      font: .ows_dynamicTypeCaption1,
                      textColor: textColor,
                      textAlignment: UIView.textAlignmentUnnatural())
    }
    
    var subtitleIcon: UIImage {
        (isIncoming ? UIImage(named: "icon.call.incoming")! : UIImage(named: "icon.call.outgoing")!).withRenderingMode(.alwaysTemplate)
    }
    
    var subtitleIconColor: UIColor {
        let iconColor: UIColor
        switch call.callType {
        case .incoming, .incomingIncomplete, .incomingAnsweredElsewhere:
            iconColor = .st_accentGreen
        case .outgoing, .outgoingIncomplete:
            iconColor = .white
        case .incomingMissed, .incomingMissedBecauseOfChangedIdentity, .incomingDeclined, .incomingBusyElsewhere, .incomingDeclinedElsewhere, .outgoingMissed:
            iconColor = .st_otherRed
        @unknown default:
            iconColor = .white
        }
        return iconColor
    }
    
    var phoneImage: UIImage {
        switch call.offerType {
        case .audio:
            return UIImage(named: "profileMenu.icon.call")!.withRenderingMode(.alwaysTemplate)
        case .video:
            return Theme.iconImage(.videoCall)
        }
    }
}

// MARK: - CVComponentViewCallMessage
extension CVComponentCallMessage {
    // Used for rendering some portion of an Conversation View item.
    // It could be the entire item or some part thereof.
    @objc
    public class CVComponentViewCallMessage: NSObject, CVComponentView {

        fileprivate let outerStackView = OWSStackView(name: "Call message")
        fileprivate let selectionView = MessageSelectionView()
        fileprivate let bubbleView = OWSBubbleView()
        fileprivate let innerStackView = OWSStackView(name: "innerStackView")
        fileprivate let vStackView = OWSStackView(name: "vStackView")
        fileprivate let hStackView = OWSStackView(name: "hStackView")

        fileprivate let iconView = UIImageView()
        fileprivate let titleLabel = UILabel()
        fileprivate let timestampLabel = UILabel()
        fileprivate let subtitleIconView = UIImageView()
        
        public var isDedicatedCellView = false

        public var rootView: UIView {
            outerStackView
        }
        
        // MARK: -
        
        public func setIsCellVisible(_ isCellVisible: Bool) {}

        public func reset() {
//            owsAssertDebug(isDedicatedCellView)

            if !isDedicatedCellView {
                outerStackView.reset()
                innerStackView.reset()
                vStackView.reset()
                hStackView.reset()
            }
            outerStackView.layoutBlock = nil
            innerStackView.layoutBlock = nil
            vStackView.layoutBlock = nil
            hStackView.layoutBlock = nil
            
            iconView.image = nil
            titleLabel.text = nil
            timestampLabel.text = nil
            subtitleIconView.image = nil
        }
    }
}
