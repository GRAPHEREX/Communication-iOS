//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

// TODO: We should describe which state updates & when it is committed.
extension ConversationSettingsViewController {

    private var threadName: String {
        var threadName = contactsManager.displayNameWithSneakyTransaction(thread: thread)

        if let contactThread = thread as? TSContactThread {
            if let phoneNumber = contactThread.contactAddress.phoneNumber,
                phoneNumber == threadName {
                threadName = PhoneNumber.bestEffortFormatPartialUserSpecifiedText(toLookLikeAPhoneNumber: phoneNumber)
            }
        }

        return threadName
    }

    private func buildHeaderForGroup(groupThread: TSGroupThread) -> UIView {
        let header = HeaderContactProfileView()
        let avatar = OWSAvatarBuilder.buildImage(thread: groupThread, diameter: 80)
        
        let memberCount = groupThread.groupModel.groupMembership.fullMembers.count
        let groupMembersText = GroupViewUtils.formatGroupMembersLabel(memberCount: memberCount)
        
        header.setup(
            fullName: groupThread.groupNameOrDefault,
            subtitle: groupMembersText,
            image: avatar,
            options: [
                ProfileOptionView(option: .leaveGroup,
                                  action: { [weak self] in
                                    self?.didTapLeaveGroup()
                }),
                ProfileOptionView(option: .gallery,
                                  action: { [weak self] in
                                    guard let self = self else { return }
                                    self.showMediaGallery(types: [.media, .files, .voice, .gifs])
                })
        ])
        
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(conversationNameTouched)))
        header.isUserInteractionEnabled = true
        avatarView = header.imageView
        
        return header
    }

    private func buildHeaderForContact(contactThread: TSContactThread) -> UIView {
        let header = HeaderContactProfileView()
        let threadName = contactsManager.displayNameWithSneakyTransaction(thread: contactThread)
        
        let avatar = OWSAvatarBuilder.buildImage(thread: contactThread,
                                                 diameter: 80)
        var options = [ProfileOptionView]()
        
        if !contactThread.isNoteToSelf {
            options.append(contentsOf: [
                ProfileOptionView(option: .call, action: { [weak self] in
                    guard let self = self else { return }
                    self.didCallTap(address: contactThread.contactAddress)
                }),
                ProfileOptionView(option: .video, action: { [weak self] in
                    guard let self = self else { return }
                    self.didCallTap(address: contactThread.contactAddress, isVideo: true)
                })
            ])
            
            options.append(ProfileOptionView(option: .gallery, action: { [weak self] in
                guard let self = self else { return }
                let types: [GalleryType] = contactThread.isNoteToSelf
                    ? [.media, .files, .voice, .gifs]
                    : [.media, .files, .voice, .groups, .gifs]
                self.showMediaGallery(types: types)
            }))
            
            options.append(ProfileOptionView(option: .send,
                                             action: { [weak self] in
                                                guard let self = self else { return }
                                                self.showSendFromChat(recipientAddress: self.thread.recipientAddresses[0])
                                             }))
        }
        
        header.setup(
            fullName: threadName,
            subtitle: "", //contactThread.isNoteToSelf ? "" : "lastSeen",  // TODO: fix lastSeen
            image: avatar,
            options: options
        )
        
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(conversationNameTouched)))
        header.isUserInteractionEnabled = true
        avatarView = header.imageView
        
        return header
    }
    
    func didCallTap(address: SignalServiceAddress, isVideo: Bool = false) {
        outboundIndividualCallInitiator.initiateCall(address: address, isVideo: isVideo)
    }
    
    func buildMainHeader() -> UIView {
        if let groupThread = thread as? TSGroupThread {
            return buildHeaderForGroup(groupThread: groupThread)
        } else if let contactThread = thread as? TSContactThread {
            return buildHeaderForContact(contactThread: contactThread)
        } else {
            owsFailDebug("Invalid thread.")
            return UIView()
        }
    }
}
