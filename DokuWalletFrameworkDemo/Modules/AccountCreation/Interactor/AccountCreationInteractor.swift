//
//  AccountCreationInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import UIKit
import DokuWalletSDK

class AccountCreationInteractor: AccountCreationInteractorProtocol {
    
    var presenter: AccountCreationInteractorOutputProtocol?
    
    func createAccount(accountCreationData: AccountCreationStruct) {
        DispatchQueue.global(qos: .background).async {
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let externalId = AppHelper.shared.generateRandomNumber(length: 12)
            let b2bAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2bAccessToken)
            let httpMethod = WebHttpMethod.POST.rawValue
            let endpointPath = Endpoint.createAccount.path
            let redirectUrl = RedirectUrl.accountCreationRedirectUrl
            let partnerReferenceNo = "\(AppHelper.shared.generateRandomAlphabet(length: 8))\(AppHelper.shared.generateRandomNumber(length: 8))"
            
            let parameters: [String:Any] = [
                WalletRequest.partnerReferenceNo : partnerReferenceNo,
                WalletRequest.email : accountCreationData.email,
                WalletRequest.name : accountCreationData.name,
                WalletRequest.phoneNo : accountCreationData.phoneNo,
                WalletRequest.redirectUrl : redirectUrl,
            ]
            
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
            
            Wallet.sharedInstance.createAccount(headers: headers, parameters: parameters) { (result:  Result<AccountCreationResponse, WalletError>) in
                DispatchQueue.main.async {
                    self.presenter?.processAccountCreationResponse(result: result)
                }
            }
        }
        
    }
}
