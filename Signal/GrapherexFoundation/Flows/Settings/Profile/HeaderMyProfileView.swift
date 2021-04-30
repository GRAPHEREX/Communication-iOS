//
//  Copyright (c) 2020 SkyTech. All rights reserved.
// 

import Foundation

final class HeaderMyProfileView : HeaderContactProfileView, AvatarViewHelperDelegate {
    typealias VoidHandler = () -> Void
    public var avatarChanged: VoidHandler?
    private let avatarViewHelper = AvatarViewHelper()
    private var avatarData: Data? = nil
    private var hasClearAvatar: Bool = true
    private var isDeletingAvatar: Bool = false
    
    private var thread: TSThread!
    private var threadViewModel: ThreadViewModel?
    private var address: SignalServiceAddress = TSAccountManager.localAddress!

    public var isEditMode: Bool = false {
        didSet {
            updateMode()
        }
    }
    public var viewController: UIViewController!
    
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "profile_camera_large"))
        imageView.layer.cornerRadius = 24
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowOpacity = 0.25
        imageView.layer.shadowRadius = 4
        return imageView
    }()
    
    override func setup() {
        super.setup()
        nameLabel.text = nil
        avatarViewHelper.delegate = self
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarViewTapped)))
        
        addSubview(cameraImageView)
        cameraImageView.autoPinEdge(.top, to: .top, of: imageView, withOffset: 16)
        cameraImageView.autoPinEdge(.bottom, to: .bottom, of: imageView, withOffset: -16)
        cameraImageView.autoPinEdge(.leading, to: .leading, of: imageView, withOffset: 16)
        cameraImageView.autoPinEdge(.trailing, to: .trailing, of: imageView, withOffset: -16)
        
        let address = TSAccountManager.localAddress!
        thread = TSContactThread.getOrCreateThread(contactAddress: address)
        var options: [ProfileOptionView] = [ProfileOptionView(option: .message, action: { [weak self] in
            guard let self = self else { return }
            let threadViewModel: ThreadViewModel = self.databaseStorage.uiRead {
                return ThreadViewModel(thread: self.thread, forConversationList: false, transaction: $0)
            }
            let controller = ConversationViewController(threadViewModel: threadViewModel,
                                                        action: .none,
                                                        focusMessageId: nil)
            self.fromViewController().navigationController?.pushViewController(controller, animated: true)
        })]
        
        if address.uuid != nil {
            options.append(
                ProfileOptionView(option: .userId, action: { [weak self] in
                    self?.showUserIdInfo()
                    }
            ))
        }
        
        setup(
            fullName: OWSProfileManager.shared.localGivenName()!,
            subtitle: "",
            image: getAvatar(),
            options: options)
    }
    
    func getAvatar() -> UIImage? {
        if !isDeletingAvatar,
            let image = OWSProfileManager.shared.localProfileAvatarImage()  {
            hasClearAvatar = true
            return image
        }
        hasClearAvatar = false
        return OWSContactAvatarBuilder.init(forLocalUserWithDiameter: kOWSProfileManager_MaxAvatarDiameter, localUserAvatarMode: .asUser).buildDefaultImage()
    }
    
    func showUserIdInfo() {
        let controller = UserIDViewController()
        controller.address = TSAccountManager.localAddress!
        let modal = OWSNavigationController(rootViewController: controller)
        fromViewController().navigationController?.present(modal, animated: true, completion: nil)
    }
    
    @objc
    func avatarViewTapped() {
        avatarViewHelper.showChangeAvatarUI()
    }
    
    public func getAvatarData() -> Data? {
        return avatarData
    }
    
    public func updateDispayNameLabel(newName: String) {
        nameLabel.text = newName
    }
    
    func updateAvatarView() {
        if let avatarData = self.avatarData {
            imageView.image = UIImage(data: avatarData)
            self.imageView.contentMode = .scaleAspectFill
        } else {
            self.imageView.image = getAvatar()
        }
    }
    
    func updateMode() {
        Logger.info("")
        cameraImageView.isHidden = !isEditMode
        imageView.isUserInteractionEnabled = isEditMode
        if isEditMode {
            if let image = OWSProfileManager.shared.localProfileAvatarImage() {
               imageView.image = image
            } else {
                imageView.image = OWSContactAvatarBuilder
                    .init(forLocalUserWithDiameter: kOWSProfileManager_MaxAvatarDiameter, localUserAvatarMode: .asUser)
                .buildMainDefaultImage()
            }
        } else {
            updateAvatarView()
        }
        isDeletingAvatar = false
    }
    
    func avatarActionSheetTitle() -> String? {
        return  NSLocalizedString("PROFILE_VIEW_AVATAR_ACTIONSHEET_TITLE",
                                  comment: "Action Sheet title prompting the user for a profile avatar");
    }
    
    func avatarDidChange(_ image: UIImage) {
        avatarChanged?()
        setAvatarImage(image: image.resizedImage(to: .init(square: CGFloat(kOWSProfileManager_MaxAvatarDiameter))) )
    }
    
    func setAvatarImage(image: UIImage?) {
        imageView.image = image
        avatarData = image != nil ? OWSProfileManager.avatarData(forAvatarImage: image!) : nil
        hasClearAvatar = image != nil
    }
    
    func fromViewController() -> UIViewController {
        return viewController
    }
    func clearAvatarActionLabel() -> String {
        return NSLocalizedString("PROFILE_VIEW_CLEAR_AVATAR", comment: "")
    }
    
    func hasClearAvatarAction() -> Bool {
        return hasClearAvatar
    }
    
    func clearAvatar() {
        hasClearAvatar = false
        avatarData = nil
        isDeletingAvatar = true
        imageView.image = OWSContactAvatarBuilder
            .init(forLocalUserWithDiameter: kOWSProfileManager_MaxAvatarDiameter, localUserAvatarMode: .asUser)
            .buildMainDefaultImage()
        avatarChanged?()
    }

}
