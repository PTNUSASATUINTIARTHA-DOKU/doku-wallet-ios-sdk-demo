//
//  GenerateQrisInputFormInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 05/12/23.
//

import UIKit
import DokuWalletSDK

class GenerateQrisInputFormInteractor: GenerateQrisInputFormInteractorProtocol {
    
    var presenter: GenerateQrisInputFormInteractorOutputProtocol?
    
    func generateQris(generateQrisInputFormData: GenerateQrisInputFormStruct) {
        DispatchQueue.global(qos: .background).async {
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let externalId = AppHelper.shared.generateRandomNumber(length: 12)
            let b2bAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2bAccessToken)
            let httpMethod = WebHttpMethod.POST.rawValue
            let endpointPath = Endpoint.generateQris.path
            let partnerReferenceNo = "\(AppHelper.shared.generateRandomAlphabet(length: 8))\(AppHelper.shared.generateRandomNumber(length: 8))"
            
            let amountValue = generateQrisInputFormData.amountValue.decimalValueFromFormattedIDR()
            let feeType = generateQrisInputFormData.feeType
            let currency = "IDR"
            
            let amount: [String:Any] = [
                WalletRequest.value : amountValue,
                WalletRequest.currency : currency,
            ]
            
            let additionalInfo: [String:Any] = [
                WalletRequest.postalCode : "12345",
                WalletRequest.feeType : feeType,
            ]
            
            let merchantId = "2997"
            let terminalId = "K45"
            
            var parameters: [String:Any] = [
                WalletRequest.partnerReferenceNo : partnerReferenceNo,
                WalletRequest.amount : amount,
                WalletRequest.merchantId : merchantId,
                WalletRequest.terminalId : terminalId,
                WalletRequest.additionalInfo : additionalInfo,
            ]
            
            if(feeType == QrisFeeType.fixedTips.rawValue) {
                let feeValue = generateQrisInputFormData.feeValue.decimalValueFromFormattedIDR()
                let feeAmount: [String:Any] = [
                    WalletRequest.value : feeValue,
                    WalletRequest.currency : currency,
                ]
                parameters[WalletRequest.feeAmount] = feeAmount
            }
            
            let jsonStringParameters = parameters.toJsonString()
            let minifiedParameters = jsonStringParameters.minify()
            let encryptedParameters = minifiedParameters.sha256()
            let lowercasedEncryptedParameters = encryptedParameters.lowercased()
            let signatureComponent = "\(httpMethod):\(endpointPath):\(b2bAccessToken):\(lowercasedEncryptedParameters):\(timeStamp)"
            let signature = signatureComponent.hmacSha512(secret: Credential.secretKey)
            
            let headers: [String:Any] = [
                WalletRequest.timestamp: timeStamp,
                WalletRequest.partnerId: Credential.clientId,
                WalletRequest.externalId: externalId,
                WalletRequest.signature: signature,
                WalletRequest.authorization: "Bearer \(b2bAccessToken)",
            ]
            
            Wallet.sharedInstance.generateQris(headers: headers, parameters: parameters) { (result:  Result<GenerateQrisResponse, WalletError>) in
                DispatchQueue.main.async {
                    self.presenter?.processGenerateQrisResponse(result: result)
                }
            }
        }
        
    }
}
