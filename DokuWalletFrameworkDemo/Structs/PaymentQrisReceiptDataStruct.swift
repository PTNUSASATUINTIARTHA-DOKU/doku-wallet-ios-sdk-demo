//
//  PaymentQrisReceiptDataStruct.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 19/12/23.
//

import UIKit

struct PaymentQrisReceiptDataStruct {
    var success: Bool
    var merchantName: String
    var merchantLocation: String
    var referenceNumber: String
    var transactionDate: String
    var transactionAmount: Double
    var feeAmount: Double
    var totalAmount: Double
    
    init(success: Bool, merchantName: String, merchantLocation: String, referenceNumber: String, transactionDate: String, transactionAmount: Double, feeAmount: Double, totalAmount: Double) {
        self.success = success
        self.merchantName = merchantName
        self.merchantLocation = merchantLocation
        self.referenceNumber = referenceNumber
        self.transactionDate = transactionDate
        self.transactionAmount = transactionAmount
        self.feeAmount = feeAmount
        self.totalAmount = totalAmount
    }
}
