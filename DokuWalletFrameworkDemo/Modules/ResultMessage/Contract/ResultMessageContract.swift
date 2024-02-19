//
//  ResultMessageContract.swift
//  WalletSDK
//
//  Created by DOKU on 11/05/23.
//

import Foundation

protocol ResultMessagePresenterProtocol {
    var router: ResultMessageRouterProtocol? { get set }
    var view: ResultMessageViewProtocol? { get set }
    
    func displayData()
    
    func goBackToMainMenu()
    
}

protocol ResultMessageViewProtocol {
    
    func displayData(data: ResultMessageDataStruct)
    
}

protocol ResultMessageRouterProtocol {

    func goBackToMainMenu()

}
