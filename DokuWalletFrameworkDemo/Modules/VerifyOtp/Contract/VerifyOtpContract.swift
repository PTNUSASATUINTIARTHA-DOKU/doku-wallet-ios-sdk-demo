//
//  VerifyOtpContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 11/11/23.
//

import UIKit
import DokuWalletSDK

protocol VerifyOtpViewProtocol: ViewProtocol {
    var presenter: VerifyOtpPresenterProtocol? { get set }
    
    func displayPhoneNo(phoneNo: String)
    
    func updateCountdownLabel(text: String)
    
    func setupResendOtpButton(isActive: Bool)
    
    func clearOtp()
}

protocol VerifyOtpPresenterProtocol {
    
    var router: VerifyOtpRouterProtocol? { get set }
    var view: VerifyOtpViewProtocol? { get set }
    var interactor: VerifyOtpInteractorProtocol? { get set }
    
    func verifyOtp(otp: String)
    
    func resendOtp()
    
    func loadPhoneNo()
    
    func startOtpTimer()
}

protocol VerifyOtpInteractorProtocol {
    var presenter: VerifyOtpInteractorOutputProtocol? { get set }
    
    func verifyOtp(otp: String, verifyOtpData: VerifyOtpStruct)
    
    func resendOtp(accountCreationData: AccountCreationStruct)
    
    func startResendOtpTimer()
}

protocol VerifyOtpInteractorOutputProtocol {
    
    func processVerifyOtpResponse(result: Result<VerifyOtpResponse,WalletError>)
    
    func processResendOtpResponse(result: Result<AccountCreationResponse,WalletError>)
    
    func updateTimerCountdown(seconds: Int)
}

protocol VerifyOtpRouterProtocol: RouterProtocol {
    
    func goToCreatePinWebview(webviewConfig: WebviewConfig)
}
