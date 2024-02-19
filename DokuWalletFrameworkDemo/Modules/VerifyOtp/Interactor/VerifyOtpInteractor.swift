//
//  VerifyOtpInteractor.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 11/11/23.
//

import UIKit
import DokuWalletSDK

class VerifyOtpInteractor: VerifyOtpInteractorProtocol {
    
    var presenter: VerifyOtpInteractorOutputProtocol?
    var timer = Timer()
    var seconds = 300
    var appDidEnterBackgroundDate = Date()
    
    func verifyOtp(otp: String, verifyOtpData: VerifyOtpStruct) {
        DispatchQueue.global(qos: .background).async {
            let timeStamp = SnapHelper.shared.getCurrentTimestamp()
            let externalId = AppHelper.shared.generateRandomNumber(length: 12)
            let b2bAccessToken = AppHelper.shared.getDataFromKeychain(keychainKey: .b2bAccessToken)
            let httpMethod = WebHttpMethod.POST.rawValue
            let endpointPath = Endpoint.verifyOtp.path
            
            let parameters: [String:Any] = [
                WalletRequest.originalPartnerReferenceNo : verifyOtpData.partnerReferenceNo,
                WalletRequest.originalReferenceNo : verifyOtpData.referenceNo,
                WalletRequest.otp : otp,
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
            
            Wallet.sharedInstance.verifyOtp(headers: headers, parameters: parameters) { (result:  Result<VerifyOtpResponse, WalletError>) in
                DispatchQueue.main.async {
                    self.presenter?.processVerifyOtpResponse(result: result)
                }
            }
        }
    }
    
    func resendOtp(accountCreationData: AccountCreationStruct) {
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
                    self.startResendOtpTimer()
                    self.presenter?.processResendOtpResponse(result: result)
                }
            }
        }
    }
    
    func startResendOtpTimer() {
        seconds = 300
        handleBackgroundProcessTimer()
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
}

