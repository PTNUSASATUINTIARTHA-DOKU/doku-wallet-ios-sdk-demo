//
//  QrisInputAmountContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

protocol QrisInputAmountViewProtocol: ViewProtocol {
    var presenter: QrisInputAmountPresenterProtocol? { get set }
    
    func displayData(data: DecodeQrisResponse)
}

protocol QrisInputAmountPresenterProtocol {
    
    var router: QrisInputAmountRouterProtocol? { get set }
    var view: QrisInputAmountViewProtocol? { get set }
    
    func requestData()
    
    func goToNextPage(transactionAmount: String)
}

protocol QrisInputAmountRouterProtocol: RouterProtocol {
    
    func goToQrisConfirmation(dataResponse: DecodeQrisResponse, qrContent: String, transactionAmount: String)
    
    func showAlert(alert: UIAlertController)
}
