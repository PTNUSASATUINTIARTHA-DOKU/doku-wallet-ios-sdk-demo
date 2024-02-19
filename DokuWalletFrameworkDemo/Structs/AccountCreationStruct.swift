//
//  AccountCreationStruct.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 17/11/23.
//

import Foundation

struct AccountCreationStruct {
    var name: String
    var email: String
    var phoneNo: String
  
    init(name: String, email: String, phoneNo: String) {
        self.name = name
        self.email = email
        self.phoneNo = phoneNo
    }
}
