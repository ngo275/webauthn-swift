import UIKit
import Combine

@available(iOS 13.0, *)
public class WebAuthnSwift {
    public private(set) var text = "Hello, World!"
    private var cancellables = Set<AnyCancellable>()
    static var profile: [String: String] = [:]
    static var apiKey: String = ""
    static var offer: OfferData? = nil
    static var pushClaimTokensTask: ((String) -> Future<Void, Error>)? = nil

    public init(apiKey: String = "") {
        WebAuthnSwift.apiKey = apiKey
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
    
    public func setProfile() {
        WebAuthnSwift.profile = [
            "firstName": "John",
            "lastName": "Cred",
            "phoneNumber": "381903274",
            "countryCode": "+84"
        ]
    }
    
    public func setClaimTokenTask(pushClaimTokensTask: @escaping ((String) -> Future<Void, Error>)) {
        WebAuthnSwift.pushClaimTokensTask = pushClaimTokensTask
    }
    
    public func getOffers() -> Future<[OfferData], CustomError> {
        return Future() { promise in
            OfferManager().getOffersFromProvider(phoneNumber: nil, countryCode: nil, localId: "123", credifyId: nil, productTypes: [])
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { res in
                    promise(.success(res.data.offers))
                }).store(in: &self.cancellables)
        }
    }
    
    public func showOffer(_ offer: OfferData) {
        WebAuthnSwift.offer = offer
        let vc = WebViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        guard let currenVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() else {
            return
        }
        
        currenVC.present(navigationController, animated: false)
    }
    
}
