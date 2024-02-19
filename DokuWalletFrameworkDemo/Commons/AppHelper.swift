//
//  AppHelper.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 09/11/23.
//

import UIKit

class AppHelper {
    
    static let shared = AppHelper()
    
    func getCurrentTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 7 * 3600) // +07:00
        
        let currentTimestamp = dateFormatter.string(from: Date())
        
        return currentTimestamp
    }
    
    func saveDatatoUserDefault(key: UserDefaultKey, value: Any) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func getDatafromUserUserDefaultByKey(key: UserDefaultKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }
    
    func removeUserDataByKey(key: UserDefaultKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    func removeUserDataByKeys(keys: [UserDefaultKey]) {
        for key in keys {
            self.removeUserDataByKey(key: key)
        }
    }
    
    func isKeyPresentInUserDefaults(key: UserDefaultKey) -> Bool {
        return UserDefaults.standard.object(forKey: key.rawValue) != nil
    }
    
    func removeKeychainDataByKeys(keys: [KeychainKey]) {
        for key in keys {
            do {
                try KeychainService.shared.deleteDataFor(account: key)
            } catch {
            }
        }
    }
    
    func saveToKeychain(keychainKey: KeychainKey, data: String) {
        do {
            try KeychainService.shared.saveDataFor(account: keychainKey, savedData: data)
        } catch {}
    }
    
    func getDataFromKeychain(keychainKey: KeychainKey) -> String {
        var data = ""
        do {
            data = try KeychainService.shared.getData(account: keychainKey)
        } catch {}
        return data
    }
    
    func generateSystrace() -> String {
        let alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var uniqueID = ""
        
        for _ in 0..<31 {
            let randomIndex = alphabet.index(alphabet.startIndex, offsetBy: Int.random(in: 0..<alphabet.count))
            let randomCharacter = alphabet[randomIndex]
            uniqueID.append(randomCharacter)
        }
        
        return uniqueID
    }
    
    func generateRandomTransactionId() -> String {
        let minDigits = UInt64(100_000_000_000_000)
           let maxDigits = UInt64(999_999_999_999_999)
           
           let randomNumber = UInt64.random(in: minDigits...maxDigits)
        let transactionId = "TRX-ID-\(randomNumber)"
        return transactionId
    }
    
    func generateRandomAlphabet(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func generateRandomNumber(length: Int) -> String {
        let letters = "0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func getColor(color: SystemColor) -> UIColor {
        return UIColor(named: color.rawValue)!
    }
    
    func countDownTime(time: Int) -> String {
        let timeInMinutes = time / 60 % 60
        let timeInSeconds = time % 60

        return String(format: "%02d:%02d", timeInMinutes, timeInSeconds)
    }
    
    func getOriginalAmount(data: String) -> String {
        let regex = AppHelper.shared.amountRegex()
        return getOriginalAmount(pattern: regex, data: data)
    }
    
    func getOriginalAmount(pattern: NSRegularExpression, data: String) -> String {
        let amountWithPrefix = pattern.stringByReplacingMatches(in: data, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, data.count), withTemplate: "")
        return amountWithPrefix
    }
    
    func amountRegex() -> NSRegularExpression {
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive) 
        return regex
    }
}
