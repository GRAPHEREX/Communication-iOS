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
