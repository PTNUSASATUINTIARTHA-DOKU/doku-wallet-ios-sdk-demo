//
//  GenerateQrisInputFormPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 05/12/23.
//

import UIKit
import DokuWalletSDK

class GenerateQrisInputFormPresenter: GenerateQrisInputFormPresenterProtocol {
    
    var view: GenerateQrisInputFormViewProtocol?
    var router: GenerateQrisInputFormRouterProtocol?
    var interactor: GenerateQrisInputFormInteractorProtocol?
    var generateQrisInputFormData = GenerateQrisInputFormStruct(amountValue: "", feeValue: "", feeType: "")
    
    init (view: GenerateQrisInputFormViewProtocol, router: GenerateQrisInputFormRouterProtocol, interactor: GenerateQrisInputFormInteractorProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    func generateQris(generateQrisInputFormData: GenerateQrisInputFormStruct) {
        view?.showActivityIndicator()
        self.generateQrisInputFormData = generateQrisInputFormData
        interactor?.generateQris(generateQrisInputFormData: generateQrisInputFormData)
    }
    
}

extension GenerateQrisInputFormPresenter: GenerateQrisInputFormInteractorOutputProtocol {

    func processGenerateQrisResponse(result: Result<GenerateQrisResponse, WalletError>) {
        view?.hideActivityIndicator()
        switch result {
        case .success(let generateQrisResponse):
            if (generateQrisResponse.responseCode == SnapResponseCode.successGenerateQris) {
                self.generateQrisInputFormData.qrContent = generateQrisResponse.qrContent ?? ""
                self.generateQrisInputFormData.referenceNo = generateQrisResponse.referenceNo ?? ""
                self.generateQrisInputFormData.partnerReferenceNo = generateQrisResponse.partnerReferenceNo ?? ""
                router?.goToQrDisplay(data: self.generateQrisInputFormData)
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
