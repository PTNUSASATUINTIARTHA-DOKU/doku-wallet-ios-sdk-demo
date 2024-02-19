//
//  QrDisplayPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 07/12/23.
//

import UIKit
import DokuWalletSDK

class QrDisplayPresenter: QrDisplayPresenterProtocol {
    
    var view: QrDisplayViewProtocol?
    var router: QrDisplayRouterProtocol?
    var interactor: QrDisplayInteractorProtocol?
    var generateQrisInputFormStruct: GenerateQrisInputFormStruct
    var queryQrisOnProgress = false
    
    init (view: QrDisplayViewProtocol, router: QrDisplayRouterProtocol, interactor: QrDisplayInteractorProtocol, generateQrisInputFormStruct: GenerateQrisInputFormStruct) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.generateQrisInputFormStruct = generateQrisInputFormStruct
    }
    
    func viewdidLoad() {
        let totalAmount = (Double(generateQrisInputFormStruct.amountValue) ?? 0.0) + (Double(generateQrisInputFormStruct.feeValue) ?? 0.0)
        let formattedTotalAmount = "\(Int(totalAmount))".currencyFormatterForCurrencyIntegerString(currencySymbol: "Rp")
        view?.displayData(qrContent: generateQrisInputFormStruct.qrContent, formattedTotalAmount: formattedTotalAmount)
        interactor?.handleBackgroundProcessTimer()
        interactor?.startCountdownTimer()
    }
    
    func queryQris() {
        if(!queryQrisOnProgress) {
            queryQrisOnProgress = true
            view?.showActivityIndicator()
            interactor?.queryQris(referenceNo: generateQrisInputFormStruct.referenceNo, partnerReferenceNo: generateQrisInputFormStruct.partnerReferenceNo)
        }
    }
    
    func back() {
        stopTimer()
        router?.back()
    }
    
    func stopTimer() {
        queryQrisOnProgress = true
        interactor?.stopTimer()
    }
    
}

extension QrDisplayPresenter: QrDisplayInteractorOutputProtocol {

    func processQueryQrisResponse(result: Result<QueryQrisResponse, WalletError>) {
        queryQrisOnProgress = false
        view?.hideActivityIndicator()
        switch result {
        case .success(let queryQrisResponse):
            if(queryQrisResponse.responseCode == SnapResponseCode.successQueryQris) {
                if(queryQrisResponse.latestTransactionStatus == "00") {
                    let header = NSMutableAttributedString(string: "Pembayaran QRIS Sukses!", attributes: [
                        .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                        .foregroundColor: #colorLiteral(red: 0.2156862745, green: 0.2196078431, blue: 0.2, alpha: 1),
                        .kern: 0.0
                    ])
                    
                    let description = NSMutableAttributedString(string: "Pembayaran QRIS berhasil dilakukan", attributes: [
                        .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                        .foregroundColor: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1),
                        .kern: 0.0
                    ])
                    let resultMessageDataStruct = ResultMessageDataStruct(image: UIImage(named: "success"), header: header, description: description, isAutoRedirectPage: false)
                    stopTimer()
                    router?.goToResultMessage(data: resultMessageDataStruct)
                } else if(queryQrisResponse.latestTransactionStatus == "06") {
                    let header = NSMutableAttributedString(string: "Pembayaran QRIS Gagal!", attributes: [
                        .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                        .foregroundColor: #colorLiteral(red: 0.2156862745, green: 0.2196078431, blue: 0.2, alpha: 1),
                        .kern: 0.0
                    ])
                    
                    let description = NSMutableAttributedString(string: "QRIS kadaluwarsa", attributes: [
                        .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                        .foregroundColor: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1),
                        .kern: 0.0
                    ])
                    let resultMessageDataStruct = ResultMessageDataStruct(image: UIImage(named: "failed"), header: header, description: description, isAutoRedirectPage: false)
                    stopTimer()
                    router?.goToResultMessage(data: resultMessageDataStruct)
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
    
    func updateTimerCountdown(seconds: Int) {
        if(seconds <= 0) {
            queryQris()
        }
        view?.updateCountdownLabel(seconds: "\(seconds)")
    }
}
