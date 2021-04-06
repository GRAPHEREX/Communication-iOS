import Foundation
import PromiseKit
import UIKit

// SkyTech
public class STPrimaryButton: UIButton {
    
    public enum Constant {
        public static let height: CGFloat = 56
        static let radius: CGFloat = 12
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
    // MARK: - SINGAL DEPENDENCY – reimplement
    public var buttonDisabledBackgroundColor: UIColor = UIColor.gray
//        Theme.backgroundColor
    
    private func setup() {
        layer.cornerRadius = Constant.radius
        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
//        imageView.autoPinTrailing(toEdgeOf: self, offset: -16)
//        imageView.wltAutoPinTopToSuperviewMargin()
//        imageView.wltAutoPinBottomToSuperviewMargin()
        rightImageView = imageView
        handleEnabled(true)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(applyTheme),
//                                               name: .ThemeDidChange, object: nil)
    }
    
    @objc public func handleEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        DispatchQueue.main.async {
            if (isEnabled) {
                // MARK: - SINGAL DEPENDENCY – reimplement
//                self.addBorder(with: .clear)
//                self.backgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.inversedBackgroundColor
//                self.setTitleColor(Theme.inversedPrimaryTextColor, for: .normal)
//                self.tintColor = UIColor.st_accentGreen
            } else {
//                self.addBorder(with: UIColor.black /*MARK: - SINGAL DEPENDENCY - THEME*/)
                self.backgroundColor = self.buttonDisabledBackgroundColor
//                self.setTitleColor(Theme.primaryTextColor, for: .normal)
//                self.tintColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.primaryTextColor
            }
        }
    }
}
fileprivate extension STPrimaryButton {
    @objc func applyTheme() {
        // MARK: - SINGAL DEPENDENCY – reimplement
//        if self.buttonDisabledBackgroundColor == UIColor.st_accentBlack
//            || self.buttonDisabledBackgroundColor ==  UIColor.ows_white {
//            self.buttonDisabledBackgroundColor = UIColor.white // MARK: - SINGAL DEPENDENCY - THEME  = Theme.backgroundColor
//        }
        
        handleEnabled(self.isEnabled)
    }
}
