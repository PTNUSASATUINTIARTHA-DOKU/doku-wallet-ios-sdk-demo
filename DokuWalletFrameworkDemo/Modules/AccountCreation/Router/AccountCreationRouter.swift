//
//  AccountCreationRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import UIKit

class AccountCreationRouter: AccountCreationRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule() -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.accountCreation.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.accountCreation.viewController) as! AccountCreationViewController
        
        let router = AccountCreationRouter()
        let interactor = AccountCreationInteractor()
        let presenter = AccountCreationPresenter(view: view, router: router, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        return view
    }
    
    func goToVerifyOtp(verifyOtpStruct: VerifyOtpStruct, accountCreationData: AccountCreationStruct) {
        let verifyOtpView = VerifyOtpRouter.assembleModule(verifyOtpStruct: verifyOtpStruct, accountCreationData: accountCreationData)
        viewController?.navigationController?.pushViewController(verifyOtpView, animated: true)
    }

}
