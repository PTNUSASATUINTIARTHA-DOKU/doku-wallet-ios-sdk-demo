//
//  QrDisplayRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 07/12/23.
//

import UIKit

class QrDisplayRouter: QrDisplayRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule(generateQrisInputFormStruct: GenerateQrisInputFormStruct) -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.qrDisplay.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.qrDisplay.viewController) as! QrDisplayViewController
        
        let router = QrDisplayRouter()
        let interactor = QrDisplayInteractor()
        let presenter = QrDisplayPresenter(view: view, router: router, interactor: interactor, generateQrisInputFormStruct: generateQrisInputFormStruct)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        return view
    }
    
    func back() {
        if let viewControllers = viewController?.navigationController?.viewControllers {
            for viewController in viewControllers {
                if let menuViewController = viewController as? MenuViewController {
                    viewController.navigationController?.popToViewController(menuViewController, animated: true)
                }
            }
        }
    }
    
    func goToResultMessage(data: ResultMessageDataStruct) {
        let view = ResultMessageRouter.assembleModule(data: data)
        viewController?.navigationController?.pushViewController(view, animated: true)
    }
}
