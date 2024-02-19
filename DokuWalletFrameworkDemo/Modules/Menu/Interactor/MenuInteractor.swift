//
//  MenuInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit
import DokuWalletSDK

class MenuInteractor: MenuInteractorProtocol {
    
    var presenter: MenuInteractorOutputProtocol?
    
    func getB2BToken() {
        DispatchQueue.global(qos: .background).async {
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let signatureComponent = "\(Credential.clientId)|\(timeStamp)"
            let signature = signatureComponent.sha256WithRSA(privateKeyString: Credential.privateKey)
            
            let headers: [String:Any] = [
                WalletRequest.clientKey: Credential.clientId,
                WalletRequest.timestamp: timeStamp,
                WalletRequest.signature: signature,
                
            ]
            
            let parameters: [String:Any] = [
                WalletRequest.grantType : "client_credentials"
            ]
            
            Wallet.sharedInstance.getTokenB2B(headers: headers, parameters: parameters) { (result:  Result<GetTokenB2BResponse, WalletError>) in
                DispatchQueue.main.async {
                    self.presenter?.processGetB2BTokenResponse(result: result)
                }
            }
        }
    }
    
    func queryAccountBinding(accountId: String) {
        DispatchQueue.global(qos: .background).async {
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let externalId = AppHelper.shared.generateRandomNumber(length: 12)
            let b2bAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2bAccessToken)
            let httpMethod = WebHttpMethod.POST.rawValue
            let endpointPath = Endpoint.queryAccountBinding.path
            let partnerReferenceNo = "\(AppHelper.shared.generateRandomAlphabet(length: 8))\(AppHelper.shared.generateRandomNumber(length: 8))"
            
            let additionalInfo: [String:Any] = [
                WalletRequest.accountId : "1517447489"
            ]
            
            let parameters: [String:Any] = [
                WalletRequest.partnerReferenceNo : partnerReferenceNo,
                WalletRequest.additionalInfo : additionalInfo,
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
            
            Wallet.sharedInstance.queryAccountBinding(headers: headers, parameters: parameters) { (result:  Result<QueryAccountBindingResponse, WalletError>) in
                DispatchQueue.main.async {
                    self.presenter?.processQueryAccountBindingResponse(result: result)
                }
            }
        }
    }
    
    func getB2B2CToken(authCode: String) {
        DispatchQueue.global(qos: .background).async {
            
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let signatureComponent = "\(Credential.clientId)|\(timeStamp)"
            let signature = signatureComponent.sha256WithRSA(privateKeyString: Credential.privateKey)
            
            let headers: [String:Any] = [
                WalletRequest.clientKey: Credential.clientId,
                WalletRequest.timestamp: timeStamp,
                WalletRequest.signature: signature,
                
            ]
            
            let parameters: [String:Any] = [
                WalletRequest.grantType : "authorization_code",
                WalletRequest.authCode : authCode,
            ]
            
            Wallet.sharedInstance.getTokenB2B2C(headers: headers, parameters: parameters) { (result:  Result<GetTokenB2B2CResponse, WalletError>) in
                DispatchQueue.main.async {
                    self.presenter?.processGetB2B2CTokenResponse(result: result)
                }
            }
            
            
        }
        
    }
}
