//
//  QrDisplayContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 07/12/23.
//

import UIKit
import DokuWalletSDK

protocol QrDisplayViewProtocol: ViewProtocol {
    var presenter: QrDisplayPresenterProtocol? { get set }
    
    func displayData(qrContent: String, formattedTotalAmount: String)
    
    func updateCountdownLabel(seconds: String)
}

protocol QrDisplayPresenterProtocol {
    
    var router: QrDisplayRouterProtocol? { get set }
    var view: QrDisplayViewProtocol? { get set }
    var interactor: QrDisplayInteractorProtocol? { get set }
    
    func viewdidLoad()
    
    func back()
    
    func queryQris()
}

protocol QrDisplayInteractorProtocol {
    var presenter: QrDisplayInteractorOutputProtocol? { get set }
    
    func queryQris(referenceNo: String, partnerReferenceNo: String)
    
    func startCountdownTimer()
    
    func stopTimer()
    
    func handleBackgroundProcessTimer()
}

protocol QrDisplayInteractorOutputProtocol {
    
    func processQueryQrisResponse(result: Result<QueryQrisResponse,WalletError>)
    
    func updateTimerCountdown(seconds: Int)
}

protocol QrDisplayRouterProtocol: RouterProtocol {
    
    func goToResultMessage(data: ResultMessageDataStruct)
    
    func back()
    
}
