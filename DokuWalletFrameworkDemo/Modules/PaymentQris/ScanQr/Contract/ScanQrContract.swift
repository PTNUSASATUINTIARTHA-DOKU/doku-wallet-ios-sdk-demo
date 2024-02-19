//
//  ScanQrContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

protocol ScanQrViewProtocol: ViewProtocol {
    var presenter: ScanQrPresenterProtocol? { get set }
    
    func setupCameraQrScan()
    
    func stopCamera()
}

protocol ScanQrPresenterProtocol {
    
    var router: ScanQrRouterProtocol? { get set }
    var view: ScanQrViewProtocol? { get set }
    var interactor: ScanQrInteractorProtocol? { get set }
    
    func processQrString(qrString: String)
    
    func needCameraAccess()
}

protocol ScanQrInteractorProtocol {
    var presenter: ScanQrInteractorOutputProtocol? { get set }
    
    func processQrString(qrString: String)
}

protocol ScanQrInteractorOutputProtocol {
    
    func processDecodeQrisResponse(result: Result<DecodeQrisResponse,WalletError>)
}

protocol ScanQrRouterProtocol: RouterProtocol {
    
    func goToQrisInputAmount(dataResponse: DecodeQrisResponse, qrContent: String)
    
    func goToQrisConfirmation(dataResponse: DecodeQrisResponse, qrContent: String)
    
    func showAlert(alert: UIAlertController)
}
