//
//  MenuRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit

class MenuRouter: MenuRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule() -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.menu.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.menu.viewController) as! MenuViewController
        
        let router = MenuRouter()
        let interactor = MenuInteractor()
        let presenter = MenuPresenter(view: view, router: router, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        return view
    }
    
    func goToAccountCreation() {
        let accountCreationView = AccountCreationRouter.assembleModule()
        viewController?.navigationController?.pushViewController(accountCreationView, animated: true)
    }
    
    func goToGenerateQrisFlow() {
        let generateQrisInputFormView = GenerateQrisInputFormRouter.assembleModule()
        viewController?.navigationController?.pushViewController(generateQrisInputFormView, animated: true)
    }
    
    func goToPaymentQrisFlow() {
        let scanQrView = ScanQrRouter.assembleModule()
        viewController?.navigationController?.pushViewController(scanQrView, animated: true)
    }
}
