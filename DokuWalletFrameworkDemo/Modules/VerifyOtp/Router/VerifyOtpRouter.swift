//
//  VerifyOtpRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 11/11/23.
//

import UIKit

class VerifyOtpRouter: VerifyOtpRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule(verifyOtpStruct: VerifyOtpStruct, accountCreationData: AccountCreationStruct) -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.verifyOtp.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.verifyOtp.viewController) as! VerifyOtpViewController
        
        let router = VerifyOtpRouter()
        let interactor = VerifyOtpInteractor()
        let presenter = VerifyOtpPresenter(view: view, router: router, interactor: interactor, verifyOtpStruct: verifyOtpStruct, accountCreationData: accountCreationData)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        return view
    }
    
    func goToCreatePinWebview(webviewConfig: WebviewConfig) {
        let createPinWebview = CreatePinWebviewRouter.assembleModule(webviewConfig: webviewConfig)
        viewController?.navigationController?.pushViewController(createPinWebview, animated: true)
    }

}
