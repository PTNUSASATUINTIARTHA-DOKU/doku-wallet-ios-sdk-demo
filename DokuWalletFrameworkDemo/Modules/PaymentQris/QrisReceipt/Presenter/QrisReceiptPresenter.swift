//
//  QrisReceiptPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit

class QrisReceiptPresenter: QrisReceiptPresenterProtocol {
    
    var view: QrisReceiptViewProtocol?
    var router: QrisReceiptRouterProtocol?
    var data: PaymentQrisReceiptDataStruct
    
    init (view: QrisReceiptViewProtocol, router: QrisReceiptRouterProtocol, data: PaymentQrisReceiptDataStruct) {
        self.view = view
        self.router = router
        self.data = data
    }
    
    func requestData() {
        view?.displayData(data: data)
    }
    
    func returnToHome() {
        router?.returnToHome()
    }
}
