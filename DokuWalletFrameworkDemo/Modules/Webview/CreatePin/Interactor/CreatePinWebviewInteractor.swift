//
//  CreatePinWebviewInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/11/23.
//

import Foundation
import DokuWalletSDK

class CreatePinWebviewInteractor: WebviewInteractorProtocol {
    
    var presenter: WebviewInteractorOutputProtocol?
    
    func hitApi(urlString: String) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString), let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                if let accountId = components.queryItems?.first(where: { $0.name == WalletRequest.accountId })?.value {
                    let timeStamp = SnapHelper.shared.getCurrentTimestamp()
                    let externalId = AppHelper.shared.generateRandomNumber(length: 12)
                    let b2bAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2bAccessToken)
                    let httpMethod = WebHttpMethod.POST.rawValue
                    let endpoint = Endpoint.bindAccount.path
                    let redirectUrl = RedirectUrl.accountBindingRedirectUrl
                    let partnerReferenceNo = "\(AppHelper.shared.generateRandomAlphabet(length: 8))\(AppHelper.shared.generateRandomNumber(length: 8))"
                    
                    let successParams: [String:Any] = [
                        WalletRequest.accountId : accountId
                    ]
                    
                    let parameters: [String:Any] = [
                        WalletRequest.partnerReferenceNo : partnerReferenceNo,
                        WalletRequest.redirectUrl : redirectUrl,
                        WalletRequest.successParams : successParams,
                    ]
                    
                    let jsonStringParameters = parameters.toJsonString()
                    let minifiedParameters = jsonStringParameters.minify()
                    let encryptedParameters = minifiedParameters.sha256()
                    let lowercasedEncryptedParameters = encryptedParameters.lowercased()
                    let signatureComponent = "\(httpMethod):\(endpoint):\(b2bAccessToken):\(lowercasedEncryptedParameters):\(timeStamp)"
                    print("signatureComponent: \(signatureComponent)")
                    let signature = signatureComponent.hmacSha512(secret: Credential.secretKey)
                    
                    let headers: [String:Any] = [
                        WalletRequest.timestamp: timeStamp,
                        WalletRequest.partnerId: Credential.clientId,
                        WalletRequest.externalId: externalId,
                        WalletRequest.signature: signature,
                        WalletRequest.authorization: "Bearer \(b2bAccessToken)",
                    ]
                    
                    Wallet.sharedInstance.bindAccount(headers: headers, parameters: parameters) { (result:  Result<AccountBindingResponse, WalletError>) in
                        DispatchQueue.main.async {
                            self.presenter?.processHitApiResponse(data: result)
                        }
                    }
                }
            }
        }
    }
}
