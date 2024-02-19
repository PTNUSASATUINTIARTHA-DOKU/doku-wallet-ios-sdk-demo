//
//  WebviewConfig.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 13/11/23.
//

import Foundation

struct WebviewConfig {
    
    var title: String
    var url: String
    var backType: BackType
    var httpMethod: WebHttpMethod
    var httpBody: String
    var observeValue: Bool
    
    init(title: String = "", url: String, backType: BackType = .back, httpMethod: WebHttpMethod = .POST,  httpBody: String = "", observeValue: Bool = false) {
        self.title = title
        self.url = url
        self.backType = backType
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.observeValue = observeValue
    }
}
