//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import PromiseKit

public enum OWSUploadError: Error {
    case missingRangeHeader
}

@objc
public class OWSUpload: NSObject {

    public typealias ProgressBlock = (Progress) -> Void

    @objc
    @available(swift, obsoleted: 1.0)
    public class func uploadV4(data: Data,
                               uploadForm: OWSUploadFormV4,
                               uploadUrlPath: String,
                               progressBlock: ((Progress) -> Void)?) -> AnyPromise {
        AnyPromise(uploadV4(data: data,
                            uploadForm: uploadForm,
                            uploadUrlPath: uploadUrlPath,
                            progressBlock: progressBlock))
    }

    @objc
    public static let serialQueue: DispatchQueue = {
        return DispatchQueue(label: "org.whispersystems.signal.upload",
                             qos: .utility,
                             autoreleaseFrequency: .workItem)
    }()
}

// MARK: -

fileprivate extension OWSUpload {

    static var cdn0SessionManager: AFHTTPSessionManager {
        signalService.sessionManagerForCdn(cdnNumber: 0)
    }
}

// MARK: -

public extension OWSUpload {

    class func uploadV4(data: Data,
                        uploadForm: OWSUploadFormV4,
                        uploadUrlPath: String,
                        progressBlock: ProgressBlock? = nil) -> Promise<String> {

        guard !AppExpiry.shared.isExpired else {
            return Promise(error: OWSAssertionError("App is expired."))
        }

        let (promise, resolver) = Promise<String>.pending()
        Self.serialQueue.async {
            // TODO: Use OWSUrlSession instead.
            self.cdn0SessionManager.requestSerializer.setValue(OWSURLSession.signalIosUserAgent,
                                                               forHTTPHeaderField: OWSURLSession.kUserAgentHeader)
            self.cdn0SessionManager.post(uploadUrlPath,
                                         parameters: nil,
                                         constructingBodyWith: { (formData: AFMultipartFormData) -> Void in

                                            formData.appendPart(withFileData: data, name: "file", fileName: "file", mimeType: "")
                                            
                                            // We have to build up the form manually vs. simply passing in a parameters dict
                                            // because AWS is sensitive to the order of the form params (at least the "key"
                                            // field must occur early on).
                                            //
                                            // For consistency, all fields are ordered here in a known working order.
                                            uploadForm.append(toForm: formData)
            },
                                         progress: { progress in
                                            Logger.verbose("progress: \(progress.fractionCompleted)")

                                            if let progressBlock = progressBlock {
                                                progressBlock(progress)
                                            }
            },
                                         success: { (_, _) in
                                            Logger.verbose("Success.")
                                            let uploadedUrlPath = uploadForm.attachmentId
                                            resolver.fulfill(uploadedUrlPath)
            }, failure: { (task, error) in
                if let task = task {
                    #if TESTABLE_BUILD
                    TSNetworkManager.logCurl(for: task)
                    #endif
                } else {
                    owsFailDebug("Missing task.")
                }

                if let statusCode = HTTPStatusCodeForError(error),
                statusCode.intValue == AppExpiry.appExpiredStatusCode {
                    AppExpiry.shared.setHasAppExpiredAtCurrentVersion()
                }

                owsFailDebugUnlessNetworkFailure(error)
                resolver.reject(error)
            })
        }
        return promise
    }
}

// MARK: -

public extension OWSUploadFormV4 {
    class func parse(proto attributesProto: GroupsProtoAvatarUploadAttributes) throws -> OWSUploadFormV4 {

        guard let policy = attributesProto.policy else {
            throw OWSAssertionError("Missing policy.")
        }
        guard let credential = attributesProto.credential else {
            throw OWSAssertionError("Missing credential.")
        }

        return OWSUploadFormV4(policy: policy, credential: credential, attachmentId: "")
    }
}


// MARK: -

// A strong reference should be maintained to this object
// until it completes.  If it is deallocated, the upload
// may be cancelled.
//
// This class can be safely accessed and used from any thread.
@objc
public class OWSAttachmentUploadV4: NSObject {

    public typealias ProgressBlock = (Progress) -> Void

    // These properties are only set for v2 uploads.
    // For other uploads we use these defaults.
    //
    // These properties are set on success;
    // They should not be accessed before.
    @objc
    public var encryptionKey: Data?
    @objc
    public var digest: Data?
    @objc
    public var serverId: UInt64 = 0
    @objc
    public var bucket: String?
    @objc
    public var credentionals: String?
    @objc
    public var uploadTimestamp: UInt64 = 0

    private let attachmentStream: TSAttachmentStream

    @objc
    public static var serialQueue: DispatchQueue {
        OWSUpload.serialQueue
    }

    @objc
    public required init(attachmentStream: TSAttachmentStream) {
        self.attachmentStream = attachmentStream
    }

    private func attachmentMetadata() -> Promise<(url: URL, length: Int)> {
        return firstly(on: Self.serialQueue) {
            let temporaryFile = OWSFileSystem.temporaryFileUrl(isAvailableWhileDeviceLocked: true)
            let metadata = try Cryptography.encryptAttachment(at: self.attachmentStream.originalMediaURL!, output: temporaryFile)

            self.encryptionKey = metadata.key
            self.digest = metadata.digest

            guard let length = metadata.length, let plaintextLength = metadata.plaintextLength else {
                throw OWSAssertionError("Missing length.")
            }

            guard plaintextLength <= OWSMediaUtils.kMaxFileSizeGeneric,
                  length <= OWSMediaUtils.kMaxAttachmentUploadSizeBytes else {
                throw OWSAssertionError("Data is too large: \(length).").asUnretryableError
            }

            return (temporaryFile, length)
        }
    }

    private func attachmentData() -> Promise<Data> {
        // TODO: Eliminate the need for ever loading the attachment data into memory.
        // Right now, this is only used when updating group avatars.
        return attachmentMetadata().map { try Data(contentsOf: $0.url) }
    }

    @objc
    @available(swift, obsoleted: 1.0)
    public func upload(progressBlock: ProgressBlock? = nil) -> AnyPromise {
        return AnyPromise(upload(progressBlock: progressBlock))
    }

    public func upload(progressBlock: ProgressBlock? = nil) -> Promise<Void> {
        return uploadV4(progressBlock: progressBlock)
    }

    // Performs a request, trying to use the websocket
    // and failing over to REST.
    private func performRequest(skipWebsocket: Bool = false,
                                requestBlock: @escaping () -> TSRequest) -> Promise<Any?> {
        return firstly(on: Self.serialQueue) { () -> Promise<Any?> in
            let formRequest = requestBlock()
            let shouldUseWebsocket = OWSUpload.socketManager.canMakeRequests() && !skipWebsocket
            if shouldUseWebsocket {
                return firstly(on: Self.serialQueue) { () -> Promise<Any?> in
                    OWSUpload.socketManager.makeRequestPromise(request: formRequest)
                }.recover(on: Self.serialQueue) { (_) -> Promise<Any?> in
                    // Failover to REST request.
                    self.performRequest(skipWebsocket: true, requestBlock: requestBlock)
                }
            } else {
                return firstly(on: Self.serialQueue) {
                    return OWSUpload.networkManager.makePromise(request: formRequest)
                }.map(on: Self.serialQueue) { (_: URLSessionDataTask, responseObject: Any?) -> Any? in
                    return responseObject
                }
            }
        }
    }

    // MARK: - V4

    public func uploadV4(progressBlock: ProgressBlock? = nil) -> Promise<Void> {
        return firstly(on: Self.serialQueue) {
            // Fetch attachment upload form.
            return self.performRequest {
                return OWSRequestFactory.allocAttachmentRequestV2()
            }
        }.then(on: Self.serialQueue) { [weak self] (formResponseObject: Any?) -> Promise<OWSUploadFormV4> in
            guard let self = self else {
                throw OWSAssertionError("Upload deallocated")
            }
            return self.parseUploadFormV4(formResponseObject: formResponseObject)
        }.then(on: Self.serialQueue) { (form: OWSUploadFormV4) -> Promise<(form: OWSUploadFormV4, attachmentData: Data)> in
            return firstly {
                return self.attachmentData()
            }.map(on: Self.serialQueue) { (attachmentData: Data) in
                return (form, attachmentData)
            }
        }.then(on: Self.serialQueue) { (form: OWSUploadFormV4, attachmentData: Data) -> Promise<String> in
            let uploadUrlPath = "/api/v1/osp/objects"
            return OWSUpload.uploadV4(data: attachmentData,
                                      uploadForm: form,
                                      uploadUrlPath: uploadUrlPath,
                                      progressBlock: progressBlock)
        }.map(on: Self.serialQueue) { [weak self] (_) throws -> Void in
            self?.uploadTimestamp = NSDate.ows_millisecondTimeStamp()
        }
    }

    private func parseUploadFormV4(formResponseObject: Any?) -> Promise<OWSUploadFormV4> {

        return firstly(on: Self.serialQueue) { () -> OWSUploadFormV4 in
            guard let formDictionary = formResponseObject as? [AnyHashable: Any] else {
                Logger.warn("formResponseObject: \(String(describing: formResponseObject))")
                throw OWSAssertionError("Invalid form.")
            }
            guard let form = OWSUploadFormV4.parseDictionary(formDictionary) else {
                Logger.warn("formDictionary: \(formDictionary)")
                throw OWSAssertionError("Invalid form dictionary.")
            }
            let serverId: UInt64 = UInt64(form.attachmentId) ?? 0
            guard serverId > 0 else {
                Logger.warn("serverId: \(serverId)")
                throw OWSAssertionError("Invalid serverId.")
            }

            self.serverId = serverId

            if let policyDict = Data(base64Encoded: form.policy).flatMap({ try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) }) as? NSDictionary {
                self.bucket = policyDict["bucket"] as? String
                self.credentionals = (policyDict["policy"] as? NSDictionary)?["credential"] as? String
            }

            return form
        }
    }
}
