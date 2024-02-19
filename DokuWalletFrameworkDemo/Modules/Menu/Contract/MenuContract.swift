//
//  MenuContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit
import DokuWalletSDK

protocol MenuViewProtocol: ViewProtocol {
    var presenter: MenuPresenterProtocol? { get set }
}

protocol MenuPresenterProtocol {
    
    var router: MenuRouterProtocol? { get set }
    var view: MenuViewProtocol? { get set }
    var interactor: MenuInteractorProtocol? { get set }
    
    func goToAccountCreationFlow()
    
    func goToGenerateQrisFlow()
    
    func goToPaymentQrisFlow()
}

protocol MenuInteractorProtocol {
    var presenter: MenuInteractorOutputProtocol? { get set }
    
    func getB2BToken()
    
    func queryAccountBinding(accountId: String)
    
    func getB2B2CToken(authCode: String)
}

protocol MenuInteractorOutputProtocol {
    
    func processGetB2BTokenResponse(result: Result<GetTokenB2BResponse,WalletError>)
    
    func processGetB2B2CTokenResponse(result: Result<GetTokenB2B2CResponse,WalletError>)
    
    func processQueryAccountBindingResponse(result: Result<QueryAccountBindingResponse,WalletError>)
    
    
}

protocol MenuRouterProtocol: RouterProtocol {
    func goToAccountCreation()
    
    func goToGenerateQrisFlow()
    
    func goToPaymentQrisFlow()
}


