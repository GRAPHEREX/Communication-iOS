//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import MediaPlayer
import PromiseKit
import PureLayout

// A modal view that be used during blocking interactions (e.g. waiting on response from
// service or on the completion of a long-running local operation).
@objc(WLTModalActivityIndicatorViewController)
public class ModalActivityIndicatorViewController: WLTViewController {
    
    let canCancel: Bool
    
    private let _wasCancelled = AtomicBool(false)
    @objc
    public var wasCancelled: Bool {
        _wasCancelled.get()
    }
    public let wasCancelledPromise: Promise<Void>
    private let wasCancelledResolver: Resolver<Void>
    
    var activityIndicator: UIActivityIndicatorView?
    
    var presentTimer: Timer?
    
    var wasDimissed: Bool = false
    
    private static let kPresentationDelayDefault: TimeInterval = 0.05
    private let presentationDelay: TimeInterval
    
    // MARK: Initializers
    
    public required init(canCancel: Bool, presentationDelay: TimeInterval) {
        self.canCancel = canCancel
        self.presentationDelay = presentationDelay
        
        let (promise, resolver) = Promise<Void>.pending()
        self.wasCancelledPromise = promise
        self.wasCancelledResolver = resolver
        
        super.init()
    }
    
    @objc
    public class func present(fromViewController: UIViewController,
                              canCancel: Bool,
                              backgroundBlock : @escaping (ModalActivityIndicatorViewController) -> Void) {
        present(fromViewController: fromViewController,
                canCancel: canCancel,
                presentationDelay: kPresentationDelayDefault,
                backgroundBlock: backgroundBlock)
    }
    
    @objc
    public class func present(fromViewController: UIViewController,
                              canCancel: Bool,
                              presentationDelay: TimeInterval,
                              backgroundBlock : @escaping (ModalActivityIndicatorViewController) -> Void) {
//        AssertIsOnMainThread()
        
        let view = ModalActivityIndicatorViewController(canCancel: canCancel, presentationDelay: presentationDelay)
        // Present this modal _over_ the current view contents.
        view.modalPresentationStyle = .overFullScreen
        fromViewController.present(view,
                                   animated: false) {
            DispatchQueue.global().async {
                backgroundBlock(view)
            }
        }
    }
    
    @objc
    public func dismiss(completion completionParam: @escaping () -> Void) {
//        AssertIsOnMainThread()
        
        let completion = {
            completionParam()
            // MARK: - SINGAL DEPENDENCY – reimplement
//            self.wasCancelledResolver.reject(OWSGenericError("ModalActivityIndicatorViewController was not cancelled."))
        }
        
        if !wasDimissed {
            // Only dismiss once.
            self.dismiss(animated: false, completion: completion)
            wasDimissed = true
        } else {
            // If already dismissed, wait a beat then call completion.
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    public override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.25)
            
//            (Theme.isDarkThemeEnabled
//                                        ? UIColor(white: 0.35, alpha: 0.35)
//                                        : UIColor(white: 0, alpha: 0.25))
        self.view.isOpaque = false
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        self.activityIndicator = activityIndicator
        self.view.addSubview(activityIndicator)
        activityIndicator.autoCenterInSuperview()
        
        if canCancel {
            let cancelButton = UIButton(type: .custom)
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(UIColor.black, for: .normal)
//            cancelButton.backgroundColor = UIColor.wlt_gray80
//            let font = UIFont.wlt_dynamicTypeBody.wlt_semibold
//            cancelButton.titleLabel?.font = font
//            cancelButton.layer.cornerRadius = WLTWLTScaleFromIPhone5To7Plus(4, 5)
            cancelButton.clipsToBounds = true
            cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
            let buttonWidth: CGFloat = 140.0//WLTWLTScaleFromIPhone5To7Plus(140, 160)
            let buttonHeight: CGFloat = 60.0//OWSFlatButton.heightForFont(font)
            self.view.addSubview(cancelButton)
            cancelButton.wltAutoHCenterInSuperview()
            cancelButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 50)
            cancelButton.autoSetDimension(.width, toSize: buttonWidth)
            cancelButton.autoSetDimension(.height, toSize: buttonHeight)
        }
        
        guard presentationDelay > 0 else {
            return
        }
        
        // Hide the modal until the presentation animation completes.
        self.view.layer.opacity = 0.0
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.activityIndicator?.startAnimating()
        
        guard presentationDelay > 0 else {
            return
        }
        
        // Hide the the modal and wait for a second before revealing it,
        // to avoid "blipping" in the modal during short blocking operations.
        //
        // NOTE: It will still intercept user interactions while hidden, as it
        //       should.
        // MARK: - SINGAL DEPENDENCY – reimplement
        // weakScheduledTimer - > scheduledTimer
        self.presentTimer?.invalidate()
        self.presentTimer = Timer.scheduledTimer(timeInterval: presentationDelay, target: self, selector: #selector(presentTimerFired), userInfo: nil, repeats: false)
//        self.presentTimer = Timer.weakScheduledTimer(withTimeInterval: presentationDelay, target: self, selector: #selector(presentTimerFired), userInfo: nil, repeats: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearTimer()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.activityIndicator?.stopAnimating()
        
        clearTimer()
    }
    
    private func clearTimer() {
        self.presentTimer?.invalidate()
        self.presentTimer = nil
    }
    
    @objc func presentTimerFired() {
//        AssertIsOnMainThread()
        
        clearTimer()
        
        // Fade in the modal.
        UIView.animate(withDuration: 0.35) {
            self.view.layer.opacity = 1.0
        }
    }
    
    @objc func cancelPressed() {
//        AssertIsOnMainThread()
        
        _wasCancelled.set(true)
        
        self.wasCancelledResolver.fulfill(())
        
        dismiss {}
    }
}

