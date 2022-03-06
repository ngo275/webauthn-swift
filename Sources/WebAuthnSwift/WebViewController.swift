//
//  WebViewController.swift
//  
//
//  Created by Shu on 2022/03/06.
//

import UIKit
import WebKit

@available(iOS 13.0, *)
class WebViewController: UIViewController {
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [ .foregroundColor: UIColor.white ]
        UINavigationBar.appearance().isTranslucent = false

        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
            
        userController.add(self, name: "initialLoadCompleted")
        
        configuration.userContentController = userController
        configuration.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        webView.uiDelegate = self

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

    
        let url = URL(string: "https://dev-passport.credify.ninja/bnpl/ekyc-custom")!
    
        webView.load(URLRequest(url: url))

        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.navigationDelegate = self
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title"  {
            title = webView.title ?? ""
        }
        
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
        }
    }

}

@available(iOS 13.0, *)
extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message:
                 String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () ->
                 Void) {
        let alertController = UIAlertController(title: message,message: nil,preferredStyle:
                                                        .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) {_ in
            completionHandler()})
        
        self.present(alertController, animated: true, completion: nil)
    }
}

@available(iOS 13.0, *)
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // Prevents zoom in when clicking textareas
        let javascriptFunction = "var style = document.createElement('style'); style.innerHTML = 'input,select:focus, textarea {font-size: 16px !important;}'; document.head.appendChild(style);"
        webView.evaluateJavaScript(javascriptFunction)
        
        let data: [String:String] = [
            "phone_number": "381231234",
            "country_code": "+84",
            "full_name": "test test",
            "action": "ACTION_LOGIN",
        ]
        guard let json = try? JSONEncoder().encode(data),
              let jsonStr = String(data: json, encoding: .utf8) else { return }
        let js = "(function() { window.postMessage('\(jsonStr)','*'); })();"
        webView.evaluateJavaScript(js)
    }
}

@available(iOS 13.0, *)
extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message.name)
        print(message.body)
        guard let dict = message.body as? [String : Any] else {
            return
        }
    }
    
}
