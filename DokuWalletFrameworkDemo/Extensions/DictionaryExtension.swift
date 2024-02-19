//
//  DictionaryExtension.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import Foundation

extension Dictionary {
    func toJsonString() -> String {
        do {
            if #available(iOS 13.0, *) {
                let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.withoutEscapingSlashes])
                return String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
            } else {
                let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
                return String(data: jsonData, encoding: String.Encoding.utf8)?.replacingOccurrences(of: "\\/", with: "/") ?? ""
            }
            
        } catch {
            print("Error converting dictionary to JSON string: \(error)")
            return ""
        }
    }
}
