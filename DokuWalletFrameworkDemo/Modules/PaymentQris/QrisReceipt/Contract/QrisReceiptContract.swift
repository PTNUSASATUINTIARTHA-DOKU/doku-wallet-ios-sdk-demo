//
//  QrisReceiptContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit

protocol QrisReceiptViewProtocol: ViewProtocol {
    var presenter: QrisReceiptPresenterProtocol? { get set }
    
    func displayData(data: PaymentQrisReceiptDataStruct)
}

protocol QrisReceiptPresenterProtocol {
    
    var router: QrisReceiptRouterProtocol? { get set }
    var view: QrisReceiptViewProtocol? { get set }
    
    func requestData()
    
    func returnToHome()
}

protocol QrisReceiptRouterProtocol: RouterProtocol {
    
    func returnToHome()
}
