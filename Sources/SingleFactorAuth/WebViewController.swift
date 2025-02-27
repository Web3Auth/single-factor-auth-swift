#if os(iOS)
import UIKit
@preconcurrency import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler {
    var webView: WKWebView!
    var popupWebView: WKWebView?
    let activityIndicator = UIActivityIndicatorView(style: .large)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        activityIndicator.startAnimating()
        activityIndicator.stopAnimating()
    }

    func setupWebView() {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController.add(self, name: "JSBridge")
        configuration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let redirectUrl = redirectUrl, !redirectUrl.isEmpty else {
            decisionHandler(.allow)
            return
        }
        if let url = navigationAction.request.url, url.absoluteString.contains(redirectUrl) {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let b64ParamsItem = components.queryItems?.first(where: { $0.name == "b64Params" }),
                  let callbackFragment = b64ParamsItem.value,
                  let b64ParamData = Data.fromBase64URL(callbackFragment) else {
                decisionHandler(.allow)
                return
            }

            do {
                let signResponse = try JSONDecoder().decode(SignResponse.self, from: b64ParamData)
                onSignResponse(signResponse)
                dismiss(animated: true, completion: nil)
            } catch {
                print("Decoding SignResponse failed: \(error)")
            }
        }
        decisionHandler(.allow)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "JSBridge", let messageBody = message.body as? String {
            if messageBody == "closeWalletServices" {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView!.navigationDelegate = self
        popupWebView!.uiDelegate = self
        view.addSubview(popupWebView!)
        return popupWebView!
    }

    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebView = nil
        }
    }
}
#endif
