//
//  QrisReceiptRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit

class QrisReceiptRouter: QrisReceiptRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule(data: PaymentQrisReceiptDataStruct) -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.qrisReceipt.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.qrisReceipt.viewController) as! QrisReceiptViewController
        
        let router = QrisReceiptRouter()
        let presenter = QrisReceiptPresenter(view: view, router: router, data: data)
        
        view.presenter = presenter
        router.viewController = view
        return view
    }

    func returnToHome() {
        if let viewControllers = viewController?.navigationController?.viewControllers {
            for viewController in viewControllers {
                if let menuViewController = viewController as? MenuViewController {
                    viewController.navigationController?.popToViewController(menuViewController, animated: true)
                }
            }
        }
    }
}
