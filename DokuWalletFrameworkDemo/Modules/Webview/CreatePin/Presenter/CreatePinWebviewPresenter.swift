//
//  CreatePinWebviewPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/11/23.
//

import Foundation
import DokuWalletSDK

class CreatePinWebviewPresenter: WebviewPresenterProtocol {

    var view: WebviewViewProtocol?
    var router: WebviewRouterProtocol?
    var interactor: WebviewInteractorProtocol?
    let webviewConfig: WebviewConfig
    
    init(view: WebviewViewProtocol?, interactor: WebviewInteractorProtocol?, router: WebviewRouterProtocol, webviewConfig: WebviewConfig) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.webviewConfig = webviewConfig
    }
    
    func loadData() {
        view?.loadData(webviewConfig: webviewConfig)
    }
    
    func back() {
        router?.back(backType: webviewConfig.backType)
    }
    
    func detectUrl(urlString: String) {
        if(urlString.contains(RedirectUrl.accountCreationRedirectUrl)) {
            view?.loadBlankScreen()
            view?.showActivityIndicator()
            interactor?.hitApi(urlString: urlString)
        }
    }
}

extension CreatePinWebviewPresenter: WebviewInteractorOutputProtocol {
    func processHitApiResponse<T>(data: T?) {
        view?.hideActivityIndicator()
        let hitApiResult = data as! Result<AccountBindingResponse, WalletError>
        
        switch hitApiResult {
        case .success(let accountBindingResponse):
            if (accountBindingResponse.responseCode == SnapResponseCode.successBindAccount) {
                let webviewConfig = WebviewConfig(title: "PIN", url: accountBindingResponse.nextAction ?? "", backType: .back, httpMethod: .GET, observeValue: true)
                router?.goToNextPage(data: webviewConfig)
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
