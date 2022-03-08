//
//  File.swift
//  
//
//  Created by Shu on 2022/03/06.
//

import Foundation

/// Rest API methods (GET/PUT/POST/DELETE)
enum ApiMethod: String {
    case get = "GET", put = "PUT", post = "POST", delete = "DELETE"
}

/// Rest API protocol
protocol ApiRequest {
    var externalUrlStr: String? { get }
    var method: ApiMethod { get }
    var path: String { get }
    var parameters: [String : String] { get }
    var body: [String: Any] { get }
    var additionalHeaders: [String: String]? { get }
}

// deprecated. To be removed once idX refactoring is done
extension ApiRequest {
    func convert(with token: String? = nil, apiKey: String? = nil) -> URLRequest {
        let baseURL = URL(string: externalUrlStr ?? "") ?? URL(string: BASE_URL)!
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }
        
        components.queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }
        
        guard let url = components.url else {
            fatalError("Could not get url")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if method == .post || method == .put {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        var headers = [String:String]()
        headers["Content-Type"] = "application/json; charset=utf-8"
//        headers["Accept-Language"] = "en-US"
//        headers["User-Agent"] = ""
        
        if let h = additionalHeaders {
            for (key, value) in h {
                headers[key] = value
            }
        }
        
        if let t = token {
            headers["Authorization"] = "Bearer \(t)"
        } else if let a = apiKey {
            headers["X-API-KEY"] = a
        }
        
        request.allHTTPHeaderFields = headers
        
        return request
    }
}

/// Gets a new access token with a signature
struct GetAccessToken: ApiRequest {
    var externalUrlStr: String?
    var method: ApiMethod = .get
    var path = "v1/entity/access-token"
    var parameters: [String: String] = [:]
    var body: [String: Any] = [:]
    var additionalHeaders: [String : String]?
}

/// Gets a new access token with a signature
struct ClientAuthenticationRequest: ApiRequest {
    var externalUrlStr: String?
    var method: ApiMethod = .post
    
    var path = "v1/token"
    var parameters: [String: String] = [:]
    var body: [String: Any] = [:]
    var additionalHeaders: [String : String]?
}

struct GetAccessTokenResponse: Codable {
    let success: Bool
    let data: AccessTokenData
    
    struct AccessTokenData: Codable {
        let accessToken: String
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }

}

