//
//  WebViewController.swift
//  TeslaAuthV3
//
//  Created by Kim Hansen on 02/11/2020.
//

import OAuthSwift
import UIKit
import WebKit

class WebViewController: OAuthWebViewController {

    var targetURL: URL?
    let webView: WKWebView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.frame = self.view.bounds
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view":self.webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view":self.webView]))
        #if os(iOS)
        loadAddressURL()
        #endif
    }

    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        self.loadAddressURL()
    }
    
    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView.load(req)
        }
    }
}

// MARK: delegate

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print(navigationAction.request.url ?? "unknown")
        
        // here we handle internally the callback url and call method that call handleOpenURL (not app scheme used)
        if let url = navigationAction.request.url , url.absoluteString.starts(with: "https://auth.tesla.com/void/callback")  {
            AppDelegate.sharedInstance.applicationHandle(url: url)
            decisionHandler(.cancel)
            
            self.dismissWebViewController()
            return
        }
        
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("\(error)")
        self.dismissWebViewController()
        // maybe cancel request...
    }
    /* override func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
     
     if request.URL?.scheme == "oauth-swift" {
     self.dismissWebViewController()
     }
     
     } */
}
