//
//  WebViewController.swift
//  
//
//  Created by Shu on 2022/03/06.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
            
        userController.add(self, name: "loginCompleted")
        
        configuration.userContentController = userController

        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        webView.uiDelegate = self

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    //        url = presenter.location
        let url = URL(string: "https://web-authn-nextjs.vercel.app/")!
    //        url = URL(string: CredifyServiceX.vars.PASSPORT_URL)
        webView.load(URLRequest(url: url))

        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
//        navView.setupNavigationBar(title: webView.title ?? "", rightBarImage: UIImage.named("ic_close_white"))
        //        navView.leftBarButton.isHidden = false
        webView.navigationDelegate = self
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title"  {
//            navView.title = webView.title ?? ""
        }
        
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
    }
}

extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message.name)
        print(message.body)
        guard let dict = message.body as? [String : Any] else {
            return
        }
    }
    
}
