import Foundation
import PromiseKit
import UIKit

// SkyTech
public class STPrimaryButton: UIButton {
    
    public enum Constant {
        public static let height: CGFloat = 56
    }
    
    public enum IconType {
        case main
        case ok
        case copy
        
        var icon: UIImage {
            switch self {
            case .main:
                return #imageLiteral(resourceName: "general.icon.enter")
            case .ok:
                return #imageLiteral(resourceName: "big.icon.checked.ok")
            case .copy:
                return #imageLiteral(resourceName: "icon.files")
            }
        }
    }
    
    public var icon: IconType = .main {
        didSet {
            image = icon.icon.withRenderingMode(.alwaysTemplate)
        }
    }
    
    private var image = #imageLiteral(resourceName: "general.icon.enter") {
        didSet {
            rightImageView?.image = image
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width,
                      height: Constant.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var rightImageView: UIImageView?
    
    var isHiddenRightImageView: Bool = false { didSet {
        rightImageView?.isHidden = isHiddenRightImageView
    }}
    
    public var buttonDisabledBackgroundColor: UIColor = Theme.backgroundColor
    
    private func setup() {
        layer.cornerRadius = Constant.height / 2
        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.autoPinTrailing(toEdgeOf: self, offset: -16)
        imageView.autoPinTopToSuperviewMargin()
        imageView.autoPinBottomToSuperviewMargin()
        rightImageView = imageView
        handleEnabled(true)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTheme),
                                               name: .ThemeDidChange, object: nil)
    }
    
    @objc public func handleEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        DispatchQueue.main.async {
            if (isEnabled) {
                self.addBorder(with: .clear)
                self.backgroundColor = Theme.inversedBackgroundColor
                self.setTitleColor(Theme.inversedPrimaryTextColor, for: .normal)
                self.tintColor = UIColor.st_accentGreen
            } else {
                self.addBorder(with: Theme.primaryTextColor)
                self.backgroundColor = self.buttonDisabledBackgroundColor
                self.setTitleColor(Theme.primaryTextColor, for: .normal)
                self.tintColor = Theme.primaryTextColor
            }
        }
    }
}
fileprivate extension STPrimaryButton {
    @objc func applyTheme() {
        if self.buttonDisabledBackgroundColor == UIColor.st_accentBlack
            || self.buttonDisabledBackgroundColor ==  UIColor.ows_white {
            self.buttonDisabledBackgroundColor = Theme.backgroundColor
        }
       
        handleEnabled(self.isEnabled)
    }
}
