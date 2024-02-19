//
//  QrisAmountConfirmationInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

class QrisAmountConfirmationInteractor: QrisAmountConfirmationInteractorProtocol {
    
    var presenter: QrisAmountConfirmationInteractorOutputProtocol?
    
    func paymentQris(qrContent: String, transactionAmount: String, feeAmount: String, currency: String) {
        DispatchQueue.global(qos: .background).async {
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let externalId = AppHelper.shared.generateRandomNumber(length: 12)
            let b2bAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2bAccessToken)
            let b2b2cAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2b2cAccessToken)
            let httpMethod = WebHttpMethod.POST.rawValue
            let endpointPath = Endpoint.paymentQris.path
            let partnerReferenceNo = "\(AppHelper.shared.generateRandomAlphabet(length: 8))\(AppHelper.shared.generateRandomNumber(length: 8))"
            
            let amount: [String:Any] = [
                WalletRequest.value : transactionAmount,
                WalletRequest.currency : currency,
            ]
            
            let feeAmount: [String:Any] = [
                WalletRequest.value : feeAmount,
                WalletRequest.currency : currency,
            ]
            
            let additionalInfo: [String:Any] = [
                WalletRequest.qrContent : qrContent
            ]
            
            let parameters: [String:Any] = [
                WalletRequest.partnerReferenceNo : partnerReferenceNo,
                WalletRequest.amount : amount,
                WalletRequest.feeAmount : feeAmount,
                WalletRequest.additionalInfo : additionalInfo,
            ]
            
            let jsonStringParameters = parameters.toJsonString()
            let minifiedParameters = jsonStringParameters.minify()
            let encryptedParameters = minifiedParameters.sha256()
            let lowercasedEncryptedParameters = encryptedParameters.lowercased()
            let signatureComponent = "\(httpMethod):\(endpointPath):\(b2bAccessToken):\(lowercasedEncryptedParameters):\(timeStamp)"
            print(signatureComponent)
            let signature = signatureComponent.hmacSha512(secret: Credential.secretKey)
            
            let headers: [String:Any] = [
                WalletRequest.timestamp: timeStamp,
                WalletRequest.partnerId: Credential.clientId,
                WalletRequest.externalId: externalId,
                WalletRequest.signature: signature,
                WalletRequest.authorization: "Bearer \(b2bAccessToken)",
                WalletRequest.authorizationCustomer: "Bearer \(b2b2cAccessToken)",
            ]
            
            Wallet.sharedInstance.paymentQris(headers: headers, parameters: parameters) { (result:  Result<PaymentQrisResponse, WalletError>) in
                DispatchQueue.main.async {
                    self.presenter?.processPaymentQrisResponse(result: result)
                    print(result)
                }
            }
        }
    }
}
