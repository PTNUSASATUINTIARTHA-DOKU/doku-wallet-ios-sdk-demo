//
//  QrisInputAmountRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

class QrisInputAmountRouter: QrisInputAmountRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule(decodeQrisResponse: DecodeQrisResponse, qrContent: String) -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.qrisInputAmount.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.qrisInputAmount.viewController) as! QrisInputAmountViewController
        
        let router = QrisInputAmountRouter()
        let presenter = QrisInputAmountPresenter(view: view, router: router, decodeQrisResponse: decodeQrisResponse, qrContent: qrContent)
        
        view.presenter = presenter
        router.viewController = view
        return view
    }

    func goToQrisConfirmation(dataResponse: DecodeQrisResponse, qrContent: String, transactionAmount: String)  {
        let qrisAmountConfirmationView = QrisAmountConfirmationRouter.assembleModule(decodeQrisResponse: dataResponse, qrContent: qrContent, transactionAmount: transactionAmount)
        viewController?.navigationController?.pushViewController(qrisAmountConfirmationView, animated: true)
    }
    
    func showAlert(alert: UIAlertController) {
        viewController?.present(alert, animated: true, completion: nil)
    }
    
}
