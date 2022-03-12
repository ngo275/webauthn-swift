//
//  WebViewController.swift
//  
//
//  Created by Shu on 2022/03/06.
//

import UIKit
import WebKit
import Combine
import SafariServices

enum MessageHandler: String {
    case initialLoadCompleted
    case createUserCompleted
    case startRedemption
}

@available(iOS 13.0, *)
class WebViewController: UIViewController {
    private var webView: WKWebView!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [ .foregroundColor: UIColor.white ]
        UINavigationBar.appearance().isTranslucent = false

        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
            
        userController.add(self, name: MessageHandler.initialLoadCompleted.rawValue)
        userController.add(self, name: MessageHandler.createUserCompleted.rawValue)
        userController.add(self, name: MessageHandler.startRedemption.rawValue)
        
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

    
//        let url = URL(string: "https://dev-passport.credify.ninja/bnpl/ekyc-custom")!
        let url = URL(string: "https://dev-passport.credify.ninja/initial")!
//        let url = URL(string: "http://localhost:4200/initial")!
    
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
            
//            if webView.estimatedProgress == 1.0 {
//                presentNextWebView(webView)
//            }
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
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
//            webView.load(URLRequest(url: url))
            
            let vc = SFSafariViewController(url: url)
//            let nvc = UINavigationController(rootViewController: vc)
//            nvc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
            return nil
        }
        return nil
    }
}

@available(iOS 13.0, *)
extension WebViewController: WKNavigationDelegate {
    
    func presentNextWebView(_ webView: WKWebView) {
//        let webViewToRemove = webView
        let webViewToAdd = webView
        webViewToAdd.frame = CGRect(origin: CGPoint(x: webView.frame.width, y: webView.frame.minY), size: webView.frame.size)
//        webViewToAdd.center = CGPoint(x: 2 * webView.bounds.width, y: 0)
//        currentWebView = webViewToAdd
//        self.view.addSubview(webViewToAdd)
        view.addSubview(webViewToAdd)
        UIView.animate(withDuration: 0.4, animations: {
            
            let moveLeft = CGAffineTransform(translationX: -(webView.bounds.width), y: 0.0)
            webViewToAdd.transform = moveLeft
            
//            webViewToRemove.center = CGPointMake(-2.0*self.view.bounds.width, CGRectGetMidY(self.view.bounds))
//            webViewToAdd.center = self.CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
            }, completion: { finished in
//                webViewToRemove.removeFromSuperview()
        })
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // Prevents zoom in when clicking textareas
        let javascriptFunction = "var style = document.createElement('style'); style.innerHTML = 'input,select:focus, textarea {font-size: 16px !important;}'; document.head.appendChild(style);"
        webView.evaluateJavaScript(javascriptFunction)
    }
}

@available(iOS 13.0, *)
extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message.name)
        print(message.body)
        guard let type = MessageHandler(rawValue: message.name) else {
            return
        }
        guard let dict = message.body as? [String : Any] else {
            return
        }
    
        
        switch type {
        case .initialLoadCompleted:
            let json = try! JSONSerialization.jsonObject(with: try! WebAuthnSwift.offer.jsonData(), options: [])
            guard let dictionary = json as? [String : Any] else {
                return
            }
            let data: [String: Any] = [
                "type": "CREDIFY-WEB-SDK",
                "action": "startRedemption",
                "payload": [
                    "offer": dictionary.keysToCamelCase(),
                    "profile": WebAuthnSwift.profile
                ]
            ]

            let js = "(function() { window.postMessage('\(data.json)','*'); })();"
            
            webView.evaluateJavaScript(js)
        case .startRedemption:
            break
        case .createUserCompleted:
            guard let payload = dict["payload"] as? [String: Any], let credifyId = payload["credifyId"] as? String else {
                return
            }
            WebAuthnSwift.pushClaimTokensTask?(credifyId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        let data: [String: Any] = [
                            "type": "CREDIFY-WEB-SDK",
                            "action": "pushClaimCompleted",
                            "payload": [
                                "isSuccess": true
                            ]
                        ]
                        let js = "(function() { window.postMessage('\(data.json)','*'); })();"
                        self.webView.evaluateJavaScript(js)
                    case .failure(let error):
                        print(error)
                    }
                }, receiveValue: { _ in }).store(in: &self.cancellables)
//        default:
//            break
        }
    }
    
}
