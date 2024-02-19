//
//  QrisAmountConfirmationRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

class QrisAmountConfirmationRouter: QrisAmountConfirmationRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule(decodeQrisResponse: DecodeQrisResponse, qrContent: String, transactionAmount: String?) -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.qrisAmountConfirmation.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.qrisAmountConfirmation.viewController) as! QrisAmountConfirmationViewController
        
        let router = QrisAmountConfirmationRouter()
        let interactor = QrisAmountConfirmationInteractor()
        let presenter = QrisAmountConfirmationPresenter(view: view, router: router, interactor: interactor, decodeQrisResponse: decodeQrisResponse, qrContent: qrContent, transactionAmount: transactionAmount)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        return view
    }
    
    func goToReceiptPage(paymentQrisReceiptData: PaymentQrisReceiptDataStruct) {
        let receiptPageView = QrisReceiptRouter.assembleModule(data: paymentQrisReceiptData)
        self.viewController?.navigationController?.setNavigationBarHidden(true, animated: true)
        viewController?.navigationController?.pushViewController(receiptPageView, animated: true)
    }
}
