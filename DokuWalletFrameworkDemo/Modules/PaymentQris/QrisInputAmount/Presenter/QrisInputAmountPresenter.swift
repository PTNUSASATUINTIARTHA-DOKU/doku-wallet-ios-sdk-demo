//
//  QrisInputAmountPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

class QrisInputAmountPresenter: QrisInputAmountPresenterProtocol {
    
    var view: QrisInputAmountViewProtocol?
    var router: QrisInputAmountRouterProtocol?
    var decodeQrisResponse: DecodeQrisResponse
    var qrContent: String
    
    init (view: QrisInputAmountViewProtocol, router: QrisInputAmountRouterProtocol, decodeQrisResponse: DecodeQrisResponse, qrContent: String) {
        self.view = view
        self.router = router
        self.decodeQrisResponse = decodeQrisResponse
        self.qrContent = qrContent
    }
    
    func requestData() {
        view?.displayData(data: decodeQrisResponse)
    }
    
    func goToNextPage(transactionAmount: String) {
        router?.goToQrisConfirmation(dataResponse: decodeQrisResponse, qrContent: qrContent, transactionAmount: transactionAmount)
    }
}
