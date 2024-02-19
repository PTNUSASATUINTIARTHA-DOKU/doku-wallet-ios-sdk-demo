//
//  AccountCreationContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import UIKit
import DokuWalletSDK

protocol AccountCreationViewProtocol: ViewProtocol {
    var presenter: AccountCreationPresenterProtocol? { get set }
}

protocol AccountCreationPresenterProtocol {
    
    var router: AccountCreationRouterProtocol? { get set }
    var view: AccountCreationViewProtocol? { get set }
    var interactor: AccountCreationInteractorProtocol? { get set }
    
    func createAccount(accountCreationData: AccountCreationStruct)
}

protocol AccountCreationInteractorProtocol {
    var presenter: AccountCreationInteractorOutputProtocol? { get set }
    
    func createAccount(accountCreationData: AccountCreationStruct)
}

protocol AccountCreationInteractorOutputProtocol {
    
    func processAccountCreationResponse(result: Result<AccountCreationResponse,WalletError>)
}

protocol AccountCreationRouterProtocol: RouterProtocol {
    
    func goToVerifyOtp(verifyOtpStruct: VerifyOtpStruct, accountCreationData: AccountCreationStruct)
}
