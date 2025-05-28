//
//  WWJWTAuthenticationToken.swift
//  WWJWTAuthenticationToken
//
//  Created by William.Weng on 2025/5/28.
//

import UIKit
import CryptoKit

// MARK: - JWT-Token產生工具
open class WWJWTAuthenticationToken {
    
    @MainActor
    public static let shared = WWJWTAuthenticationToken()
}

// MARK: - 公開工具
public extension WWJWTAuthenticationToken {
    
    /// [產生JWT Token](https://kucw.io/blog/jwt/)
    /// - Parameters:
    ///   - header: [JWT加密演算法等相關設定值](https://jwt.io/)
    ///   - payload: 其它要帶過去的值
    ///   - signature: 取得產生的私鎖
    /// - Returns: Result<String, Error>
    @MainActor
    func maker(header: [String: Any], payload: [String: Any], signature: @escaping (Base64String) -> Result<Data?, Error>) -> Result<String, Error> {
        
        do {
            let headerData = try JSONSerialization.data(withJSONObject: header)
            let payloadData = try JSONSerialization.data(withJSONObject: payload)
            let headerBase64String = base64URLEncode(headerData)
            let payloadBase64String = base64URLEncode(payloadData)
            
            let result = signature((headerBase64String, payloadBase64String))
                            
            switch result {
            case .failure(let error): return .failure(error)
            case .success(let data):
                guard let data else { return .failure(CustomError.isEmtpy) }
                return .success("\(headerBase64String).\(payloadBase64String).\(base64URLEncode(data))")
            }
        } catch {
            return .failure(error)
        }
    }
    
    /// [產生JWT Token](https://fullstackladder.dev/blog/2023/01/28/openid-validate-token-with-rs256-and-jwks/)
    /// - Parameters:
    ///   - algorithm: [加密演算法](https://blog.miniasp.com/post/2023/04/09/How-to-validate-LINE-Login-issued-ES256-ID-Token)
    ///   - header: [String: Any]
    ///   - payload: [String: Any]
    ///   - signature: (Base64String) -> Result<Data?, Error>
    /// - Returns: Result<String, Error>
    @MainActor
    func maker(algorithm: EncryptionAlgorithm, header: [String: Any], payload: [String: Any], signature: @escaping (Base64String) -> Result<Data?, Error>) -> Result<String, Error> {
        
        var newHeader = header
        newHeader["alg"] = algorithm.rawValue
        
        return maker(header: newHeader, payload: payload, signature: signature)
    }
    
    /// [產生Apple推播服務的認證Token](https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns)
    /// - Parameters:
    ///   - algorithm: [加密演算法 - ES256](https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns)
    ///   - keyId: [開發者Id](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-push-notifications-app-測試推播發送-bc402338862a)
    ///   - teamId: [團隊Id](https://developer.apple.com/help/account/keys/get-a-key-identifier)
    ///   - privateKey: [.p8檔的內容](https://medium.com/彼得潘的-swift-ios-app-開發教室/推播-p8憑證匯出-d195dd6b801b)
    /// - Returns: Result<String, Error>
    @MainActor
    func apnsMaker(algorithm: EncryptionAlgorithm = .ES256, keyId: String, teamId: String, privateKey: String) -> Result<String, Error> {
        
        let header = [
            "alg": algorithm.rawValue,
            "kid": keyId
        ]
        
        let payload: [String : Any] = [
            "iss": teamId,
            "iat": Int(Date().timeIntervalSince1970)
        ]
        
        let result = WWJWTAuthenticationToken.shared.maker(header: header, payload: payload) { base64String in
            
            let signBase64String = "\(base64String.header).\(base64String.payload)"
            
            guard let signData = signBase64String.data(using: .utf8) else { return .failure(CustomError.notEncoding) }
            
            do {
                let privateKey = try P256.Signing.PrivateKey(pemRepresentation: privateKey)
                let signature = try privateKey.signature(for: signData)
                return .success(signature.rawRepresentation)
            } catch {
                return .failure(error)
            }
        }
        
        return result
    }
}

// MARK: - 公開工具
private extension WWJWTAuthenticationToken {
    
    /// 更換符合JWT規定的文字編碼 (HTML特殊文字)
    /// - Parameter data: Data
    /// - Returns: String
    func base64URLEncode(_ data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
