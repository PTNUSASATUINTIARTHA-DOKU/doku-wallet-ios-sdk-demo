//
//  DataBindingWebviewInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/11/23.
//

import Foundation
import DokuWalletSDK

class DataBindingWebviewInteractor: WebviewInteractorProtocol {
    
    var presenter: WebviewInteractorOutputProtocol?
    
    func hitApi(urlString: String) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString), let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                if let authCode = components.queryItems?.first(where: { $0.name == WalletRequest.authCode })?.value {
                    
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
                            self.presenter?.processHitApiResponse(data: result)
                        }
                    }
                }
            }
        }
    }
}
