//
//  QrDisplayInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 07/12/23.
//

import UIKit
import DokuWalletSDK

class QrDisplayInteractor: QrDisplayInteractorProtocol {
    
    var presenter: QrDisplayInteractorOutputProtocol?
    var timer = Timer()
    var seconds = 15
    var appDidEnterBackgroundDate = Date()
    var timerStopped = false
    
    func queryQris(referenceNo: String, partnerReferenceNo: String) {
        DispatchQueue.global(qos: .background).async {
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let externalId = AppHelper.shared.generateRandomNumber(length: 12)
            let b2bAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2bAccessToken)
            let httpMethod = WebHttpMethod.POST.rawValue
            let endpointPath = Endpoint.queryQris.path
      
            let merchantId = "2997"
            let serviceCode = "50"
            
            let parameters: [String:Any] = [
                WalletRequest.originalPartnerReferenceNo : partnerReferenceNo,
                WalletRequest.originalReferenceNo : referenceNo,
                WalletRequest.serviceCode : serviceCode,
                WalletRequest.merchantId : merchantId,
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
            
            Wallet.sharedInstance.queryQris(headers: headers, parameters: parameters) { (result:  Result<QueryQrisResponse, WalletError>) in
                DispatchQueue.main.async {
                    if(!self.timerStopped) {
                        self.startCountdownTimer()
                    }
                    self.presenter?.processQueryQrisResponse(result: result)
                }
            }
        }
    }
    
    func startCountdownTimer() {
        seconds = 15
        presenter?.updateTimerCountdown(seconds: seconds)
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func handleBackgroundProcessTimer() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        appDidEnterBackgroundDate = Date()
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        let previousDate = appDidEnterBackgroundDate
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.second], from: previousDate, to: Date())
        let secondsDifference = difference.second!
        seconds -= secondsDifference
        
        if(seconds > 0) {
            self.presenter?.updateTimerCountdown(seconds: seconds)
        } else {
            timer.invalidate()
            self.presenter?.updateTimerCountdown(seconds: 0)
        }
    }
    
    @objc func updateTimer() {
        if(seconds > 0) {
            seconds -= 1
            self.presenter?.updateTimerCountdown(seconds: seconds)
        } else {
            timer.invalidate()
        }
    }
    
    func stopTimer() {
        timerStopped = true
        timer.invalidate()
    }
    
}
