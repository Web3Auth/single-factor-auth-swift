#if os(iOS)
import UIKit
public typealias PlatformViewController = UIViewController
#elseif os(macOS)
import AppKit
public typealias PlatformViewController = NSViewController
#endif
@preconcurrency import WebKit

public class WebViewController: PlatformViewController, WKScriptMessageHandler {
    var webView: WKWebView!
    var popupWebView: WKWebView?
    
    #if os(iOS)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    #endif
    
    var redirectUrl: String?
    var onSignResponse: (SignResponse) -> Void

    init(redirectUrl: String? = nil, onSignResponse: @escaping (SignResponse) -> Void) {
        self.redirectUrl = redirectUrl
        self.onSignResponse = onSignResponse
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        onSignResponse = { _ in }
        super.init(coder: aDecoder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        
        #if os(iOS)
        activityIndicator.startAnimating()
        activityIndicator.stopAnimating()
        #endif
    }

    func setupWebView() {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController.add(self, name: "JSBridge")
        configuration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        webView?.removeFromSuperview()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        
        #if os(iOS)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #elseif os(macOS)
        webView.translatesAutoresizingMaskIntoConstraints = false
        #endif
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        #if os(macOS)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        #endif
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let redirectUrl = redirectUrl, !redirectUrl.isEmpty else {
            decisionHandler(.allow)
            return
        }
        if let url = navigationAction.request.url, url.absoluteString.contains(redirectUrl) {
            let host = url.host ?? ""
            let fragment = url.fragment ?? ""
            let component = URLComponents(string: host + "?" + fragment)
            let queryItems = component?.queryItems
            let b64ParamsItem = queryItems?.first(where: { $0.name == "b64Params" })
            let callbackFragment = (b64ParamsItem?.value)!
            let b64ParamString = Data.fromBase64URL(callbackFragment)
            let signResponse = try? JSONDecoder().decode(SignResponse.self, from: b64ParamString!)
            onSignResponse(signResponse!)
            #if os(iOS)
            dismiss(animated: true, completion: nil)
            #elseif os(macOS)
            self.view.window?.close()
            #endif
        }
        decisionHandler(.allow)
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "JSBridge", let messageBody = message.body as? String {
            if messageBody == "closeWalletServices" {
                #if os(iOS)
                dismiss(animated: true, completion: nil)
                #elseif os(macOS)
                self.view.window?.close()
                #endif
            }
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        #if os(iOS)
        activityIndicator.startAnimating()
        #endif
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        #if os(iOS)
        activityIndicator.stopAnimating()
        #endif
    }
}

extension WebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        
        #if os(iOS)
        popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
        
        popupWebView!.navigationDelegate = self
        popupWebView!.uiDelegate = self
        view.addSubview(popupWebView!)
        return popupWebView!
    }

    public func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebView = nil
        }
    }
}
