//
//  VerifyOtpStruct.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 13/11/23.
//

import Foundation

struct VerifyOtpStruct {
    var referenceNo: String
    var partnerReferenceNo: String
    
    init(referenceNo: String, partnerReferenceNo: String) {
        self.referenceNo = referenceNo
        self.partnerReferenceNo = partnerReferenceNo
    }
}
