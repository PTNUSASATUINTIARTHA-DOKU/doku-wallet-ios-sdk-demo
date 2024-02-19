//
//  KeychainKey.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 09/11/23.
//

import Foundation

enum KeychainKey: String, CaseIterable {
    case service = "walletService"
    
    case b2bAccessToken = "b2bAccessToken"
    case b2b2cAccessToken = "b2b2cAccessToken"
}

enum KeychainErrorType {
    case badData
    case servicesError
    case itemNotFound
    case unableToConvertToString
}

