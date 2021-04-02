//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class AttachmentToggleButton: UIButton {
    
    enum Constant {
        static let animationDuration: CGFloat = 1
    }
    
    private let visibleView = UIView()
    private let mainImageView = UIImageView(image: #imageLiteral(resourceName: "attachment.icon.plus").withRenderingMode(.alwaysTemplate))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override var isSelected: Bool {
        didSet {
            rotate()
        }
    }
    
    @objc
    func setSelected(_ isSelected: Bool, animated: Bool) {
        AssertIsOnMainThread()
        self.isSelected = isSelected
    }
    
    func setup() {
        visibleView.backgroundColor = .clear
        mainImageView.tintColor = .st_neutralGray
        self.addSubview(visibleView)
        visibleView.autoCenterInSuperview()
        visibleView.autoSetDimensions(to: .init(square: 28))
        visibleView.layer.cornerRadius = 4
        visibleView.addSubview(mainImageView)
        mainImageView.autoPinEdgesToSuperviewEdges()
    }
    
    func rotate() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            if self.isSelected {
                self.visibleView.backgroundColor = .st_accentGreen
                self.mainImageView.tintColor = Theme.backgroundColor
                self.mainImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.75 )
            } else {
                self.mainImageView.tintColor = .st_neutralGray
                self.visibleView.backgroundColor = .clear
                self.mainImageView.transform = .identity
            }
        })
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self
    }
}
