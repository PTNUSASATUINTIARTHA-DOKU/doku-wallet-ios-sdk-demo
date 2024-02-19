//
//  ScanQrRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

class ScanQrRouter: ScanQrRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule() -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.scanQr.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.scanQr.viewController) as! ScanQrViewController
        
        let router = ScanQrRouter()
        let interactor = ScanQrInteractor()
        let presenter = ScanQrPresenter(view: view, router: router, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        return view
    }
    
    func goToQrisInputAmount(dataResponse: DecodeQrisResponse, qrContent: String) {
        let qrisInputAmountView = QrisInputAmountRouter.assembleModule(decodeQrisResponse: dataResponse, qrContent: qrContent)
        viewController?.navigationController?.pushViewController(qrisInputAmountView, animated: true)
    }
    
    func goToQrisConfirmation(dataResponse: DecodeQrisResponse, qrContent: String)  {
        let qrisAmountConfirmationView = QrisAmountConfirmationRouter.assembleModule(decodeQrisResponse: dataResponse, qrContent: qrContent, transactionAmount: nil)
        viewController?.navigationController?.pushViewController(qrisAmountConfirmationView, animated: true)
    }
    
    func showAlert(alert: UIAlertController) {
        viewController?.present(alert, animated: true, completion: nil)
    }
}
