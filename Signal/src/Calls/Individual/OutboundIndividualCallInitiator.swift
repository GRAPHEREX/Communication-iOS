//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalServiceKit
import SignalMessaging

/**
 * Creates an outbound call via WebRTC.
 */
@objc public class OutboundIndividualCallInitiator: NSObject {

    @objc public override init() {
        super.init()

        SwiftSingletons.register(self)
    }

    /**
     * |address| is a SignalServiceAddress
     */
    @discardableResult
    @objc
    public func initiateCall(address: SignalServiceAddress) -> Bool {
        Logger.info("with address: \(address)")

        guard address.isValid else { return false }

        return initiateCall(address: address, isVideo: false)
    }

    /**
     * |address| is a SignalServiceAddress.
     */
    @discardableResult
    @objc
    public func initiateCall(address: SignalServiceAddress, isVideo: Bool) -> Bool {
        guard tsAccountManager.isOnboarded() else {
            Logger.warn("aborting due to user not being onboarded.")
            OWSActionSheets.showActionSheet(title: NSLocalizedString("YOU_MUST_COMPLETE_ONBOARDING_BEFORE_PROCEEDING",
                                                                     comment: "alert body shown when trying to use features in the app before completing registration-related setup."))
            return false
        }

        let firstMessageWasRead: Bool = SDSDatabaseStorage.shared.read(block: {
            if let thread = AnyContactThreadFinder().contactThread(for: address, transaction: $0),
               let message = InteractionFinder(threadUniqueId: thread.uniqueId).firstOutgoingMessage(transaction: $0) as? TSOutgoingMessage {
                let messageStatus = MessageRecipientStatusUtils.recipientStatus(outgoingMessage: message)
                return messageStatus == .read
            }
            return false
        })

        guard firstMessageWasRead else {
            Logger.warn("aborting due to user not having a thread with a receiver.")
            let title = NSLocalizedString("YOU_MUST_START_THREAD_BEFORE_PROCEEDING",
                                          comment: "alert body shown when trying to initiate a call in the app before thread was created.")
            OWSActionSheets.showActionSheet(title: title)
            return false
        }
        
        guard let callUIAdapter = Self.callService.individualCallService.callUIAdapter else {
            owsFailDebug("missing callUIAdapter")
            return false
        }
        guard let frontmostViewController = UIApplication.shared.frontmostViewController else {
            owsFailDebug("could not identify frontmostViewController")
            return false
        }

        let showedAlert = SafetyNumberConfirmationSheet.presentIfNecessary(
            address: address,
            confirmationText: CallStrings.confirmAndCallButtonTitle
        ) { didConfirmIdentity in
            guard didConfirmIdentity else { return }
            _ = self.initiateCall(address: address, isVideo: isVideo)
        }
        guard !showedAlert else {
            return false
        }

        frontmostViewController.ows_askForMicrophonePermissions { granted in
            guard granted == true else {
                Logger.warn("aborting due to missing microphone permissions.")
                frontmostViewController.ows_showNoMicrophonePermissionActionSheet()
                return
            }

            if isVideo {
                frontmostViewController.ows_askForCameraPermissions { granted in
                    guard granted else {
                        Logger.warn("aborting due to missing camera permissions.")
                        return
                    }

                    callUIAdapter.startAndShowOutgoingCall(address: address, hasLocalVideo: true)
                }
            } else {
                callUIAdapter.startAndShowOutgoingCall(address: address, hasLocalVideo: false)
            }
        }

        return true
    }
}
