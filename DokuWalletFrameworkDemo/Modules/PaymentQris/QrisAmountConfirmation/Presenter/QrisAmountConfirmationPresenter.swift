//
//  QrisAmountConfirmationPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

class QrisAmountConfirmationPresenter: QrisAmountConfirmationPresenterProtocol {
    
    var view: QrisAmountConfirmationViewProtocol?
    var router: QrisAmountConfirmationRouterProtocol?
    var interactor: QrisAmountConfirmationInteractorProtocol?
    var decodeQrisResponse: DecodeQrisResponse
    var qrContent: String
    var transactionAmount: String
    var feeTips: String? = nil
    
    init (view: QrisAmountConfirmationViewProtocol, router: QrisAmountConfirmationRouterProtocol, interactor: QrisAmountConfirmationInteractorProtocol, decodeQrisResponse: DecodeQrisResponse, qrContent: String, transactionAmount: String?) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.decodeQrisResponse = decodeQrisResponse
        self.qrContent = qrContent
        if let transactionAmount = transactionAmount {
            self.transactionAmount = transactionAmount
        } else {
            let transactionAmountDouble = decodeQrisResponse.transactionAmount?.value ?? 0.00
            self.transactionAmount = "\(transactionAmountDouble)"
        }
    }
    
    func requestData() {
        view?.displayData(decodeQrisData: decodeQrisResponse, transactionAmount: transactionAmount)
    }
    
    func processTransaction(tips: String?) {
        view?.showActivityIndicator()
        
        let currency = decodeQrisResponse.transactionAmount?.currency ?? "IDR"
        if let feeTips = tips {
            self.feeTips = tips
            interactor?.paymentQris(qrContent: qrContent, transactionAmount: transactionAmount.decimalValueFromFormattedIDR(), feeAmount: feeTips.decimalValueFromFormattedIDR(), currency: currency)
        } else {
            let feeAmount = decodeQrisResponse.feeAmount?.value ?? 0.0
            let formattedFeeAmount = "\(feeAmount)".decimalValueFromFormattedIDR()
            interactor?.paymentQris(qrContent: qrContent, transactionAmount: transactionAmount.decimalValueFromFormattedIDR(), feeAmount: formattedFeeAmount, currency: currency)
        }
    }
}

extension QrisAmountConfirmationPresenter: QrisAmountConfirmationInteractorOutputProtocol {
    func processPaymentQrisResponse(result: Result<PaymentQrisResponse, WalletError>) {
        view?.hideActivityIndicator()
        switch result {
        case .success(let paymentQrisResponse):
            if (paymentQrisResponse.responseCode == SnapResponseCode.successPaymentQris) {
                let success = true
                let merchantName = decodeQrisResponse.merchantName ?? ""
                let merchantLocation = decodeQrisResponse.merchantLocation ?? ""
                let referenceNumber = paymentQrisResponse.referenceNo ?? ""
                let transactionDate = paymentQrisResponse.transactionDate ?? ""
                let transactionAmount = paymentQrisResponse.amount?.value ?? 0.0
                let feeAmount = paymentQrisResponse.feeAmount?.value ?? 0.0
                let totalAmount = transactionAmount + feeAmount
                
                let successPaymentQrisReceiptData = PaymentQrisReceiptDataStruct(success: success, merchantName: merchantName, merchantLocation: merchantLocation, referenceNumber: referenceNumber, transactionDate: transactionDate, transactionAmount: transactionAmount, feeAmount: feeAmount, totalAmount: totalAmount)
                router?.goToReceiptPage(paymentQrisReceiptData: successPaymentQrisReceiptData)
            } else {
                let success = false
                let merchantName = decodeQrisResponse.merchantName ?? ""
                let merchantLocation = decodeQrisResponse.merchantLocation ?? ""
                let referenceNumber = paymentQrisResponse.referenceNo ?? ""
                let transactionDate = paymentQrisResponse.transactionDate ?? ""
                let transactionAmount = paymentQrisResponse.amount?.value ?? 0.0
                let feeAmount = paymentQrisResponse.feeAmount?.value ?? 0.0
                let totalAmount = transactionAmount + feeAmount
                
                let successPaymentQrisReceiptData = PaymentQrisReceiptDataStruct(success: success, merchantName: merchantName, merchantLocation: merchantLocation, referenceNumber: referenceNumber, transactionDate: transactionDate, transactionAmount: transactionAmount, feeAmount: feeAmount, totalAmount: totalAmount)
                router?.goToReceiptPage(paymentQrisReceiptData: successPaymentQrisReceiptData)
            }
        case .failure(let error):
            var detail = ""
            switch error {
            case .apiError(_, let responseMessage, _):
                detail = responseMessage
            case .networkError(let type, _):
                detail = type.rawValue
            @unknown default:
                detail = error.localizedDescription
            }
            let success = false
            let merchantName = decodeQrisResponse.merchantName ?? ""
            let merchantLocation = decodeQrisResponse.merchantLocation ?? ""
            let referenceNumber = ""
            let transactionDate = AppHelper.shared.getCurrentTimestamp()
            let transactionAmount = Double(transactionAmount) ?? 0.0
            var feeAmount = 0.0
            if let feeTips = feeTips {
                feeAmount = Double(feeTips) ?? 0.0
            } else {
                feeAmount = decodeQrisResponse.feeAmount?.value ?? 0.0
            }
            let totalAmount = transactionAmount + feeAmount
            
            let successPaymentQrisReceiptData = PaymentQrisReceiptDataStruct(success: success, merchantName: merchantName, merchantLocation: merchantLocation, referenceNumber: referenceNumber, transactionDate: transactionDate, transactionAmount: transactionAmount, feeAmount: feeAmount, totalAmount: totalAmount)
            router?.goToReceiptPage(paymentQrisReceiptData: successPaymentQrisReceiptData)
        }
    }
}

//public struct PaymentQrisResponse: Codable {
//    public var responseCode: String?
//    public var responseMessage: String?
//    public var referenceNo: String?
//    public var partnerReferenceNo: String?
//    public var transactionDate: String?
//    public var amount: PaymentQrisAmount?
//    public var feeAmount: PaymentQrisAmount?
//    public var additionalInfo: PaymentQrisAdditionalInfo?
//}
//
//public struct PaymentQrisAmount: Codable {
//    public var value: Double?
//    public var currency: String?
//}
