//
//  MenuPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit
import DokuWalletSDK

class MenuPresenter: MenuPresenterProtocol {
    
    var view: MenuViewProtocol?
    var router: MenuRouterProtocol?
    var interactor: MenuInteractorProtocol?
    var walletFeature: WalletFeature = .none
    
    init (view: MenuViewProtocol, router: MenuRouterProtocol, interactor: MenuInteractorProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    func goToAccountCreationFlow() {
        view?.showActivityIndicator()
        walletFeature = .accountCreation
        interactor?.getB2BToken()
    }
    
    func goToGenerateQrisFlow() {
        view?.showActivityIndicator()
        walletFeature = .generateQris
        interactor?.getB2BToken()
    }
    
    func goToPaymentQrisFlow() {
        view?.showActivityIndicator()
        walletFeature = .paymentQris
        interactor?.getB2BToken()
    }
    
}

extension MenuPresenter: MenuInteractorOutputProtocol {
    func processGetB2BTokenResponse(result: Result<GetTokenB2BResponse, WalletError>) {
        switch result {
        case .success(let getTokenB2BResponse):
            if (getTokenB2BResponse.responseCode == SnapResponseCode.successGetTokenB2B) {
                AppHelper.shared.saveToKeychain(keychainKey: .b2bAccessToken, data: getTokenB2BResponse.accessToken ?? "")
                if(walletFeature == .accountCreation) {
                    view?.hideActivityIndicator()
                    router?.goToAccountCreation()
                } else if(walletFeature == .generateQris) {
                    view?.hideActivityIndicator()
                    router?.goToGenerateQrisFlow()
                } else if(walletFeature == .paymentQris) {
                    interactor?.queryAccountBinding(accountId: Credential.premiumAccountId)
                }
            } else {
                view?.hideActivityIndicator()
                view?.showCommonError(title: "Pemberitahuan", detail: "Failed to get b2b token", action: {})
            }
        case .failure(let error):
            view?.hideActivityIndicator()
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
    
    func processQueryAccountBindingResponse(result: Result<QueryAccountBindingResponse, WalletError>) {
        switch result {
        case .success(let queryAccountBindingResponse):
            if (queryAccountBindingResponse.responseCode == SnapResponseCode.successQueryAccountBinding) {
                let encryptedAuthCode = queryAccountBindingResponse.additionalInfo?.authCode ?? ""
                let decryptedAuthCode = encryptedAuthCode.decryptAuthCode(secret: Credential.authCodeSecretKey)
                interactor?.getB2B2CToken(authCode: decryptedAuthCode)
            } else {
                view?.hideActivityIndicator()
                view?.showCommonError(title: "Pemberitahuan", detail: "Failed", action: {})
            }
        case .failure(let error):
            view?.hideActivityIndicator()
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
    
    func processGetB2B2CTokenResponse(result: Result<GetTokenB2B2CResponse, WalletError>) {
        view?.hideActivityIndicator()
        switch result {
        case .success(let getTokenB2B2CResponse):
            if (getTokenB2B2CResponse.responseCode == SnapResponseCode.successGetTokenB2B2C) {
                AppHelper.shared.saveToKeychain(keychainKey: .b2b2cAccessToken, data: getTokenB2B2CResponse.accessToken ?? "")
                if(walletFeature == .paymentQris) {
                    router?.goToPaymentQrisFlow()
                }
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
