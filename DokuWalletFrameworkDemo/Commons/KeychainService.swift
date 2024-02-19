//
//  KeychainService.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 09/11/23.
//

import Foundation
import LocalAuthentication

struct KeychainWrapperError: Error {
    var message: String?
    var type: KeychainErrorType
    init(status: OSStatus, type: KeychainErrorType) {
        self.type = type
        if let errorMessage = SecCopyErrorMessageString(status, nil) {
            self.message = String(errorMessage)
        } else {
            self.message = "Status Code: \(status)"
        }
    }
    
    init(type: KeychainErrorType) {
        self.type = type
    }
    
    init(message: String, type: KeychainErrorType) {
        self.message = message
        self.type = type
    }
}

class KeychainService {
    
    static let shared = KeychainService()
    
    func saveDataFor(account: KeychainKey, service: KeychainKey = KeychainKey.service, savedData: String, useBiometric: Bool = false, biometricMessage: String = "") throws {
        if savedData.isEmpty {
            try deleteDataFor(account: account, service: service)
            return
        }
        guard let savedDataConvert = savedData.data(using: .utf8) else {
            print("Error converting value to data.")
            throw KeychainWrapperError(type: .badData)
        }
        var query: [String: Any] = [
                                    kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account.rawValue,
                                    kSecAttrService as String: service.rawValue,
                                    kSecValueData as String: savedDataConvert
                                    ]
        if (useBiometric) {
            let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .biometryAny, nil)
            let context = LAContext()
            context.localizedReason = biometricMessage
            context.touchIDAuthenticationAllowableReuseDuration = 0
            query.updateValue(access as Any, forKey: kSecAttrAccessControl as String)
            query.updateValue(context, forKey: kSecUseAuthenticationContext as String)
        }
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
            case errSecSuccess:
                print("Success save to keychain")
                break
            case errSecDuplicateItem:
            try updateDataFor(account: account, service: service, savedData: savedData, useBiometric: useBiometric, biometricMessage: biometricMessage)
            default:
                throw KeychainWrapperError(status: status, type: .servicesError)
        }
    }
    
    func getData(account: KeychainKey, service: KeychainKey = KeychainKey.service, useBiometric: Bool = false, biometricMessage: String = "") throws -> String {
        var query: [String: Any] = [
                                    kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account.rawValue,
                                    kSecAttrService as String: service.rawValue,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true
                                ]
        if(useBiometric) {
            query.updateValue(biometricMessage, forKey: kSecUseOperationPrompt as String)
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainWrapperError(type: .itemNotFound)
        }
        guard status == errSecSuccess else {
            throw KeychainWrapperError(status: status, type: .servicesError)
        }
        guard let existingItem = item as? [String: Any], let valueData = existingItem[kSecValueData as String] as? Data,
              let value = String(data: valueData, encoding: .utf8) else {
            throw KeychainWrapperError(type: .unableToConvertToString)
        }
        return value
    }
    
    func updateDataFor(account: KeychainKey, service: KeychainKey = KeychainKey.service, savedData: String, useBiometric: Bool = false, biometricMessage: String = "") throws {
        guard let savedDataConvert = savedData.data(using: .utf8) else {
            print("Error converting value to data.")
            throw KeychainWrapperError(type: .badData)
        }
        var query: [String: Any] = [
                                    kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account.rawValue,
                                    kSecAttrService as String: service.rawValue
                                ]
        if (useBiometric) {
            let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .biometryAny, nil)
            let context = LAContext()
            context.localizedReason = biometricMessage
            context.touchIDAuthenticationAllowableReuseDuration = 0
            
            query.updateValue(access as Any, forKey: kSecAttrAccessControl as String)
            query.updateValue(context, forKey: kSecUseAuthenticationContext as String)
        }
        let attributes: [String: Any] = [kSecValueData as String: savedDataConvert]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            throw KeychainWrapperError(message: "Matching Item Not Found", type: .itemNotFound)
        }
        guard status == errSecSuccess else {
            print("Success update to keychain")
            throw KeychainWrapperError(status: status, type: .servicesError)
        }
    }
    
    func deleteDataFor(account: KeychainKey, service: KeychainKey = KeychainKey.service) throws {
        let query: [String: Any] = [
                                    kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account.rawValue,
                                    kSecAttrService as String: service.rawValue
                                ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainWrapperError(status: status, type: .servicesError)
        }
    }
}
