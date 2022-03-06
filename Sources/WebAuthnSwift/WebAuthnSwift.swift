import UIKit

@available(iOS 13.0, *)
public struct WebAuthnSwift {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public func startFlow() {
        let vc = WebViewController()
        vc.modalPresentationStyle = .overFullScreen
        guard let currenVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() else {
            return
        }
        
        currenVC.present(vc, animated: false)
    }
    
}
