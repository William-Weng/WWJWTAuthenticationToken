# WWJWTAuthenticationToken

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![](https://img.shields.io/github/v/tag/William-Weng/WWJWTAuthenticationToken) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- [Generate JWT authentication token.](https://jwt.io/)
- [產生JWT認證Token。](https://kucw.io/blog/jwt/)

![WWJWTAuthenticationToken](./Example.webp)

## [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWJWTAuthenticationToken.git", .upToNextMajor(from: "1.0.1"))
]
```

## [可用函式](https://ezgif.com/video-to-webp)
|函式|說明|
|-|-|
|maker(header:payload:signature:)|產生JWT Token|
|maker(algorithm:header:payload:signature:)|產生JWT Token|
|apnsMaker(algorithm:keyId:teamId:privateKey:)|產生Apple推播服務的認證Token|

## Example
```swift
import UIKit
import CryptoKit
import WWJWTAuthenticationToken

final class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
        
    @IBAction func displayJWTToken(_ sender: UIBarButtonItem) { jwtDemo() }
    @IBAction func displayAPNSToken(_ sender: UIBarButtonItem) { apnsDemo() }
}

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
```


