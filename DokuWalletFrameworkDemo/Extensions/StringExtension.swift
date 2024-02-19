//
//  StringExtension.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 09/11/23.
//

import UIKit
import CommonCrypto
import Security
import CryptoKit

extension String {
    
    func decryptAuthCode(secret: String) -> String {
        let keyBytes = Array(secret.utf8)
        let keyData = Data(keyBytes)
        
        if let encryptedData = Data(base64Encoded: self) {
            
            var decryptedBytes = [UInt8](repeating: 0, count: encryptedData.count + kCCBlockSizeAES128)
            var decryptedDataLength: Int = 0
            
            let keyLength = keyData.count
            let status = keyData.withUnsafeBytes { keyBytes in
                return encryptedData.withUnsafeBytes { encryptedBytes in
                    return decryptedBytes.withUnsafeMutableBytes { decryptedBytes in
                        return CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionECBMode | kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            keyLength,
                            nil,
                            encryptedBytes.baseAddress,
                            encryptedData.count,
                            decryptedBytes.baseAddress,
                            decryptedBytes.count,
                            &decryptedDataLength
                        )
                    }
                }
            }
            
            if status == kCCSuccess {
                decryptedBytes.removeSubrange(decryptedDataLength..<decryptedBytes.count)
                if let decryptedString = String(bytes: decryptedBytes, encoding: .utf8) {
                    return decryptedString
                }
            }
        }
        return ""
    }

    
    func sha256WithRSA(privateKeyString: String) -> String {
        guard let privateKeyData = Data(base64Encoded: privateKeyString) else {
            return ""
        }

        var error: Unmanaged<CFError>?
        let privateKey = SecKeyCreateWithData(privateKeyData as CFData, [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits: 2048
        ] as CFDictionary, &error)

        guard error == nil, let signatureLib = SecKeyCreateSignature(privateKey!, .rsaSignatureMessagePKCS1v15SHA256, self.data(using: .utf8) as! CFData, &error) else {
            return ""
        }

        return (signatureLib as Data).base64EncodedString().trimmingCharacters(in: .whitespacesAndNewlines)
    }
  
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
//    func sha256() -> String {
//        let data = Data(self.utf8)
//        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
//        data.withUnsafeBytes {
//            _ = CC_SHA256($0, CC_LONG(data.count), &digest)
//        }
//        let hexBytes = digest.map { String(format: "%02hhx", $0) }
//        return hexBytes.joined()
//    }
    
    func sha256() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02x", $0) }
        return hexBytes.joined()
    }
    
    func hmacSha1(secret: String = "") -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), secret, secret.count, self, self.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func hmacSha256(secret: String = "") -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), secret, secret.count, self, self.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
//    func hmacSha512(secret: String = "") -> String {
//        guard let secretData = secret.data(using: .utf8),
//              let messageData = self.data(using: .utf8) else {
//            return ""
//        }
//
//        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
//        secretData.withUnsafeBytes { secretBytes in
//            messageData.withUnsafeBytes { messageBytes in
//                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512),
//                       secretBytes.baseAddress, secretData.count,
//                       messageBytes.baseAddress, messageData.count, &digest)
//            }
//        }
//
//        let data = Data(digest)
//        return data.map { String(format: "%02hhx", $0) }.joined()
//    }
    
//    func hmacSha512(secret: String = "") -> String {
//        let strData = self.data(using: .utf8)!
//        let keyData = secret.data(using: .utf8)!
//        var result = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
//
//        strData.withUnsafeBytes { strBytes in
//            keyData.withUnsafeBytes { keyBytes in
//                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512), keyBytes.baseAddress, keyData.count, strBytes.baseAddress, strData.count, &result)
//            }
//        }
//
//        let hmacData = Data(bytes: result, count: Int(CC_SHA512_DIGEST_LENGTH))
//        return hmacData.map { String(format: "%02hhx", $0) }.joined()
//    }
    
    func hmacSha512(secret: String) -> String {
        guard let stringToSignData = self.data(using: .utf8),
              let clientSecretData = secret.data(using: .utf8) else {
            return ""
        }

        let signatureBytes = calculateHmacSHA512(data: stringToSignData, key: clientSecretData)

        return signatureBytes.base64EncodedString(options: [])
    }

    private func calculateHmacSHA512(data: Data, key: Data) -> Data {
        var hmacSHA512 = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes { dataBytes in
            key.withUnsafeBytes { keyBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512),
                       keyBytes.baseAddress, key.count,
                       dataBytes.baseAddress, data.count, &hmacSHA512)
            }
        }
        return Data(hmacSHA512)
    }
    
    func digestHmacSha256() -> String {
        return String(bytes: ([UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))), encoding: .utf8) ?? ""
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        var hex = self
            var data = Data()
            while(hex.count > 0) {
                let subIndex = hex.index(hex.startIndex, offsetBy: 2)
                let c = String(hex[..<subIndex])
                hex = String(hex[subIndex...])
                var ch: UInt32 = 0
                Scanner(string: c).scanHexInt32(&ch)
                var char = UInt8(ch)
                data.append(&char, count: 1)
            }
        return Data(data).base64EncodedString()
    }
    
    func convertToAttributedFromHTML() -> NSAttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
        }
        return attributedText
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    var isValidEmail: Bool {
        let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
        return testEmail.evaluate(with: self)
    }
    
    var isNumeric : Bool {
        return NumberFormatter().number(from: self) != nil
    }
    
    mutating func replace(start: String.Index, end: String.Index, lenght: Int, replaceCharacter: String) {
        let start = self.index(self.startIndex, offsetBy: 3);
        let end = self.index(self.startIndex, offsetBy: (self.count - 2))
        let length = self.count - 5
        var replacement = ""
        for _ in 0..<length {
            replacement += replaceCharacter
        }
        self.replaceSubrange(start..<end, with: replacement)
    }
    
    func indexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
    
    func containsOnlyLettersAndWhitespace() -> Bool {
        let allowed = CharacterSet.letters.union(.whitespaces)
        return unicodeScalars.allSatisfy(allowed.contains)
    }
    
    func convertToStringDictionary() -> [String: String]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func toQRCode() -> UIImage? {
        
        let data = self.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"), let colorFilter = CIFilter(name: "CIFalseColor") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            colorFilter.setValue(filter.outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0), forKey: "inputColor1")
            colorFilter.setValue(CIColor.init(red: 0.12, green: 0.13, blue: 0.15), forKey: "inputColor0")
            
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = colorFilter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    func minify() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func hexEncode() -> String {
        let inputData = Data(self.utf8)
        let hexString = inputData.map { String(format: "%02hhx", $0) }.joined()
        return hexString
    }
    
    func convertJsonStringToParameters() -> [String:Any]? {
        guard let jsonData = self.data(using: .utf8) else {
            print("Error: Invalid JSON string")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("Error converting JSON string to dictionary: \(error)")
            return nil
        }
    }
    
    func decimalValueFromFormattedIDR() -> String {
        if let doubleValue = Double(self) {
            return String(format: "%.2f", doubleValue)
        } else {
            return "0.00"
        }
    }
    
    func formatPhoneNumber() -> String {
        let cleanPhoneNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var formattedNumber = ""
        
        var index = cleanPhoneNumber.startIndex
        while index < cleanPhoneNumber.endIndex {
            let endIndex = cleanPhoneNumber.index(index, offsetBy: index == cleanPhoneNumber.startIndex ? 4 : 3, limitedBy: cleanPhoneNumber.endIndex) ?? cleanPhoneNumber.endIndex
            let chunk = cleanPhoneNumber[index..<endIndex]
            formattedNumber += "\(chunk) "
            index = endIndex
        }
        
        formattedNumber = String(formattedNumber.dropLast())
        
        return formattedNumber
    }
    
    func currencyFormatterForCurrencyIntegerString(currencySymbol: String = "") -> String {
        if(self.isEmpty) {
            return ""
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = ""
        numberFormatter.currencySymbol = currencySymbol
        numberFormatter.numberStyle = .currency
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = Locale.init(identifier: "id_ID")
        
        var amountWithPrefix = self

        let regex = AppHelper.shared.amountRegex()
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")

        let amount = (amountWithPrefix as NSString).doubleValue
        let formattedAmount = (numberFormatter.string(from: NSNumber(value: amount))!).replacingOccurrences(of: ",", with: "")
        
        return formattedAmount
    }
    
    func currencyFormatterForNumber(currencySymbol: String = "") -> String {
        if(self.isEmpty) {
            return ""
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = ""
        numberFormatter.currencySymbol = currencySymbol
        numberFormatter.numberStyle = .currency
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.locale = Locale.init(identifier: "id_ID")

        let amount = (self as NSString).doubleValue
        let formattedAmount = (numberFormatter.string(from: NSNumber(value: amount))!)
        
        return formattedAmount
    }
}
