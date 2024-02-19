//
//  VerifyOtpPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 11/11/23.
//

import UIKit
import DokuWalletSDK

class VerifyOtpPresenter: VerifyOtpPresenterProtocol {
    
    var view: VerifyOtpViewProtocol?
    var router: VerifyOtpRouterProtocol?
    var interactor: VerifyOtpInteractorProtocol?
    var verifyOtpStruct: VerifyOtpStruct
    var accountCreationData: AccountCreationStruct
    
    init (view: VerifyOtpViewProtocol, router: VerifyOtpRouterProtocol, interactor: VerifyOtpInteractorProtocol, verifyOtpStruct: VerifyOtpStruct, accountCreationData: AccountCreationStruct) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.verifyOtpStruct = verifyOtpStruct
        self.accountCreationData = accountCreationData
    }
    
    func verifyOtp(otp: String) {
        view?.showActivityIndicator()
        interactor?.verifyOtp(otp: otp, verifyOtpData: verifyOtpStruct)
    }
    
    func loadPhoneNo() {
        view?.displayPhoneNo(phoneNo: accountCreationData.phoneNo)
    }
    
    func resendOtp() {
        view?.showActivityIndicator()
        interactor?.resendOtp(accountCreationData: accountCreationData)
    }
    
    func startOtpTimer() {
        interactor?.startResendOtpTimer()
    }
    
}

extension VerifyOtpPresenter: VerifyOtpInteractorOutputProtocol {

    func processVerifyOtpResponse(result: Result<VerifyOtpResponse, WalletError>) {
        view?.hideActivityIndicator()
        switch result {
        case .success(let verifyOtpResponse):
            if (verifyOtpResponse.responseCode == SnapResponseCode.successVerifyOtp) {
                let webviewConfig = WebviewConfig(title: "PIN", url: "\(verifyOtpResponse.qparamsURL ?? "")?token=\(verifyOtpResponse.qparams?.token ?? "")", backType: .back, httpMethod: .GET, observeValue: true)
                router?.goToCreatePinWebview(webviewConfig: webviewConfig)
            } else {
                view?.showCommonError(title: "Pemberitahuan", detail: "Failed", action: {})
            }
        case .failure(let error):
            var detail = ""
            switch error {
            case .apiError(let responseCode, let responseMessage, _):
                print(responseCode)
                if(responseCode == SnapResponseCode.invalidOtp) {
                    view?.clearOtp()
                }
                detail = responseMessage
            case .networkError(let type, _):
                detail = type.rawValue
            @unknown default:
                detail = error.localizedDescription
            }
            view?.showCommonError(title: "Pemberitahuan", detail: detail, action: {})
        }
    }
    
    func processResendOtpResponse(result: Result<AccountCreationResponse, WalletError>) {
        view?.hideActivityIndicator()
        switch result {
        case .success(let accountCreationResponse):
            if (accountCreationResponse.responseCode == SnapResponseCode.successAccountCreation) {
                verifyOtpStruct = VerifyOtpStruct(referenceNo: accountCreationResponse.referenceNo ?? "", partnerReferenceNo: accountCreationResponse.partnerReferenceNo ?? "")
            } else {
                view?.showCommonError(title: "Pemberitahuan", detail: "Failed", action: {})
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
            view?.showCommonError(title: "Pemberitahuan", detail: detail, action: {})
        }
    }
    
    func updateTimerCountdown(seconds: Int) {
        if(seconds > 0) {
            let time = AppHelper.shared.countDownTime(time: seconds)
            let resendText = "Ulangi dalam \(time)"
            view?.updateCountdownLabel(text: resendText)
            view?.setupResendOtpButton(isActive: false)
        } else {
            view?.updateCountdownLabel(text: "")
            view?.setupResendOtpButton(isActive: true)
        }
    }
}
