//
//  QrisAmountConfirmationContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 18/12/23.
//

import UIKit
import DokuWalletSDK

protocol QrisAmountConfirmationViewProtocol: ViewProtocol {
    var presenter: QrisAmountConfirmationPresenterProtocol? { get set }
    
    func displayData(decodeQrisData: DecodeQrisResponse, transactionAmount: String)
    
}

protocol QrisAmountConfirmationPresenterProtocol {
    
    var router: QrisAmountConfirmationRouterProtocol? { get set }
    var view: QrisAmountConfirmationViewProtocol? { get set }
    var interactor: QrisAmountConfirmationInteractorProtocol? { get set }
    
    func requestData()
    
    func processTransaction(tips: String?)
}

protocol QrisAmountConfirmationInteractorProtocol {
    var presenter: QrisAmountConfirmationInteractorOutputProtocol? { get set }
    
    func paymentQris(qrContent: String, transactionAmount: String, feeAmount: String, currency: String)
}

protocol QrisAmountConfirmationInteractorOutputProtocol {
    
    func processPaymentQrisResponse(result: Result<PaymentQrisResponse,WalletError>)
}

protocol QrisAmountConfirmationRouterProtocol: RouterProtocol {
    
    func goToReceiptPage(paymentQrisReceiptData: PaymentQrisReceiptDataStruct)
}
