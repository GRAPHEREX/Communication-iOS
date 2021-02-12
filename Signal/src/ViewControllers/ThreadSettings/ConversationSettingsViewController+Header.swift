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
                ProfileOptionView(option: .search,
                                  action: { [weak self] in
                                    self?.tappedConversationSearch()
                }),
                ProfileOptionView(option: .leaveGroup,
                                  action: { [weak self] in
                                    self?.didTapLeaveGroup()
                }),
                ProfileOptionView(option: .gallery,
                                  action: { [weak self] in
                                    guard let self = self else { return }
                                    self.showMediaGallery()
                })
        ])
        
        return header
    }

    private func buildHeaderForContact(contactThread: TSContactThread) -> UIView {
        let header = HeaderContactProfileView()
        let threadName = contactsManager.displayNameWithSneakyTransaction(thread: contactThread)
        
        let avatar = OWSAvatarBuilder.buildImage(thread: contactThread,
                                                 diameter: 80)
        var options: [ProfileOptionView] = [ProfileOptionView(option: .search,
                                                              action: { [weak self] in
                                                                self?.tappedConversationSearch() })]
        
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
        }
        
        options.append(ProfileOptionView(option: .gallery, action: { [weak self] in
            guard let self = self else { return }
            self.showMediaGallery()
        }))
        
        header.setup(
            fullName: threadName,
            subtitle: "", //contactThread.isNoteToSelf ? "" : "lastSeen",  // TODO: fix lastSeen
            image: avatar,
            options: options
        )
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
