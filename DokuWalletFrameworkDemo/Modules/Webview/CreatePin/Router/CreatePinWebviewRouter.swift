//
//  CreatePinWebviewRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/11/23.
//

import UIKit

class CreatePinWebviewRouter: WebviewRouterProtocol {
    
    weak var viewController: UIViewController?
    var window: UIWindow?
    
    static func assembleModule(webviewConfig: WebviewConfig) -> UIViewController {
        
        let storyboard = UIStoryboard(name: ViewId.webview.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.webview.viewController) as! WebviewViewController
        let router = CreatePinWebviewRouter()
        let interactor = CreatePinWebviewInteractor()
        let presenter = CreatePinWebviewPresenter(view: view, interactor: interactor, router: router, webviewConfig: webviewConfig)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
    
        return view
    }
    
    func back(backType: BackType) {
        if backType == .back {
            viewController?.navigationController?.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func goToNextPage<T>(data: T?) {
        let webviewConfig = data as! WebviewConfig
        let dataBindingWebview = DataBindingWebviewRouter.assembleModule(webviewConfig: webviewConfig)
        viewController?.navigationController?.pushViewController(dataBindingWebview, animated: true)
    }
}
