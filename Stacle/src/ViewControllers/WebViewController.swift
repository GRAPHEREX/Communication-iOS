//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit
import WebKit

@objc
class WebViewController: OWSViewController {
    
    private var link: String = ""

    @objc func setLink(_ link: String) {
        self.link = link
    }
    
    var webView: WKWebView?
    
    override public func loadView() {
        view = UIView()
        view.backgroundColor = Theme.backgroundColor

        let wkWebConfig = WKWebViewConfiguration()
        let webView = WKWebView(frame: self.view.bounds, configuration: wkWebConfig)
        self.webView = webView
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.scrollView.contentInset = .zero
        webView.layoutMargins = .zero

        view.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: .OWSApplicationDidBecomeActive,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadContent()
        webView?.scrollView.contentOffset = .zero
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView?.scrollView.contentOffset = .zero
    }

    private func loadContent() {
        guard let webView = webView else {
            owsFailDebug("Missing webView.")
            return
        }
        guard let url = URL(string: link) else {
            owsFailDebug("Invalid URL.")
            return
        }
        webView.load(URLRequest(url: url))
        webView.scrollView.contentOffset = .zero
    }

    // MARK: - Notifications

    @objc func didBecomeActive() {
        AssertIsOnMainThread()
        loadContent()
    }
}


extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        Logger.verbose("navigationAction: \(String(describing: navigationAction.request.url))")
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        Logger.verbose("navigationResponse: \(String(describing: navigationResponse))")

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Logger.verbose("navigation: \(String(describing: navigation))")
    }

    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        Logger.verbose("navigation: \(String(describing: navigation))")
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.verbose("navigation: \(String(describing: navigation)), error: \(error)")
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.verbose("navigation: \(String(describing: navigation))")
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.verbose("navigation: \(String(describing: navigation))")
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.verbose("navigation: \(String(describing: navigation)), error: \(error)")
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Logger.verbose("")
    }
}
