//
//  GenerateQrisInputFormContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 05/12/23.
//

import UIKit
import DokuWalletSDK

protocol GenerateQrisInputFormViewProtocol: ViewProtocol {
    var presenter: GenerateQrisInputFormPresenterProtocol? { get set }
}

protocol GenerateQrisInputFormPresenterProtocol {
    
    var router: GenerateQrisInputFormRouterProtocol? { get set }
    var view: GenerateQrisInputFormViewProtocol? { get set }
    var interactor: GenerateQrisInputFormInteractorProtocol? { get set }
    
    func generateQris(generateQrisInputFormData: GenerateQrisInputFormStruct)
}

protocol GenerateQrisInputFormInteractorProtocol {
    var presenter: GenerateQrisInputFormInteractorOutputProtocol? { get set }
    
    func generateQris(generateQrisInputFormData: GenerateQrisInputFormStruct)
}

protocol GenerateQrisInputFormInteractorOutputProtocol {
    
    func processGenerateQrisResponse(result: Result<GenerateQrisResponse,WalletError>)
}

protocol GenerateQrisInputFormRouterProtocol: RouterProtocol {
    
    func goToQrDisplay(data: GenerateQrisInputFormStruct)
}

