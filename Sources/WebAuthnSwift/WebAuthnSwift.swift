import UIKit

@available(iOS 13.0, *)
public struct WebAuthnSwift {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public func startFlow() {
        let vc = WebViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        guard let currenVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() else {
            return
        }
        
        currenVC.present(navigationController, animated: false)
    }
    
    public func startAuthFlow() {
        let url = URL(string: "https://web-authn-nextjs.vercel.app/")!
        let vc = SafariViewController(url: url)
        vc.modalPresentationStyle = .overFullScreen
        guard let currenVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() else {
            return
        }
        
        currenVC.present(vc, animated: false)
    }
    
}
