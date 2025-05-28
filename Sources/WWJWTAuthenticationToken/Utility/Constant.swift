//
//  Constant.swift
//  WWJWTAuthenticationToken
//
//  Created by William.Weng on 2025/5/28.
//

import Foundation

// MARK: - typealias
public extension WWJWTAuthenticationToken {
    typealias Base64String = (header: String, payload: String)  // Base64文字合集
}

// MARK: - 錯誤
public extension WWJWTAuthenticationToken {
    
    /// 自定義錯誤
    enum CustomError: Error, CustomStringConvertible {
        
        public var description: String { message() }
        
        case notEncoding
        case isEmtpy
        
        /// 錯誤訊息
        /// - Returns: String
        func message() -> String {
            switch self {
            case .notEncoding: return "文字編碼錯誤"
            case .isEmtpy: return "該資料為空"
            }
        }
    }
    
    /// [加密演算法](https://ithelp.ithome.com.tw/articles/10231212)
    enum EncryptionAlgorithm: String {
        
        case HS256
        case HS384
        case HS512
        case RS256
        case RS384
        case RS512
        case ES256
        case ES384
        case ES512
        case PS256
        case PS384
        case PS512
    }
}
