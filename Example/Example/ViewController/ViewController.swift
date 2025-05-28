//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2025/5/28.
//

import UIKit
import CryptoKit
import WWJWTAuthenticationToken

// MARK: - ViewController
final class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
        
    @IBAction func displayJWTToken(_ sender: UIBarButtonItem) { jwtDemo() }
    @IBAction func displayAPNSToken(_ sender: UIBarButtonItem) { apnsDemo() }
}

// MARK: - 小工具
private extension ViewController {
    
    func jwtDemo() {
        
        let header = [
            "alg": "HS256",
            "typ": "JWT"
        ]
        
        let payload: [String : Any] = [
            "sub": "3939889",
            "name": "William.Weng",
            "iat": Int(Date().timeIntervalSince1970)
        ]
        
        let privateKey = """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
        OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
        1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
        -----END PRIVATE KEY-----
        """
        
        let result = WWJWTAuthenticationToken.shared.maker(header: header, payload: payload) { base64String in
            
            let signBase64String = "\(base64String.header).\(base64String.payload)"
            
            guard let signData = signBase64String.data(using: .utf8) else { return .success(nil) }
            
            do {
                let privateKey = try P256.Signing.PrivateKey(pemRepresentation: privateKey)
                let signature = try privateKey.signature(for: signData)
                return .success(signature.rawRepresentation)
            } catch {
                return .failure(error)
            }
        }
        
        switch result {
        case .failure(let error): resultLabel.text = error.localizedDescription
        case .success(let token): resultLabel.text = token
        }
    }
    
    func apnsDemo() {
        
        let keyId = "ABCDE12345"
        let teamId = "67890FGHIJ"
        
        let p8 = """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
        OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
        1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
        -----END PRIVATE KEY-----
        """
        
        let result = WWJWTAuthenticationToken.shared.apnsMaker(keyId: keyId, teamId: teamId, privateKey: p8)
        
        switch result {
        case .failure(let error): resultLabel.text = error.localizedDescription
        case .success(let token): resultLabel.text = token
        }
    }
}
