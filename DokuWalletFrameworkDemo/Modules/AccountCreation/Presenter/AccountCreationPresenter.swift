//
//  AccountCreationPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import UIKit
import DokuWalletSDK

class AccountCreationPresenter: AccountCreationPresenterProtocol {
    
    var view: AccountCreationViewProtocol?
    var router: AccountCreationRouterProtocol?
    var interactor: AccountCreationInteractorProtocol?
    var accountCreationData = AccountCreationStruct(name: "", email: "", phoneNo: "")
    
    init (view: AccountCreationViewProtocol, router: AccountCreationRouterProtocol, interactor: AccountCreationInteractorProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    func createAccount(accountCreationData: AccountCreationStruct) {
        view?.showActivityIndicator()
        self.accountCreationData = accountCreationData
        interactor?.createAccount(accountCreationData: accountCreationData)
    }
    
}

extension AccountCreationPresenter: AccountCreationInteractorOutputProtocol {

    func processAccountCreationResponse(result: Result<AccountCreationResponse, WalletError>) {
        view?.hideActivityIndicator()
        switch result {
        case .success(let accountCreationResponse):
            if (accountCreationResponse.responseCode == SnapResponseCode.successAccountCreation) {
                let verifyOtpStruct = VerifyOtpStruct(referenceNo: accountCreationResponse.referenceNo ?? "", partnerReferenceNo: accountCreationResponse.partnerReferenceNo ?? "")
                router?.goToVerifyOtp(verifyOtpStruct: verifyOtpStruct, accountCreationData: accountCreationData)
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
}
