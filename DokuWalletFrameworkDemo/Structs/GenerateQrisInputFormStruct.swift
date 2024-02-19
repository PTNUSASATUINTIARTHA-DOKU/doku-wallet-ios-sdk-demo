//
//  GenerateQrisInputFormStruct.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 05/12/23.
//

import Foundation

struct GenerateQrisInputFormStruct {
    var amountValue: String
    var feeValue: String
    var feeType: String
    var qrContent = ""
    var referenceNo = ""
    var partnerReferenceNo = ""
  
    init(amountValue: String, feeValue: String, feeType: String) {
        self.amountValue = amountValue
        self.feeValue = feeValue
        self.feeType = feeType
    }
}
