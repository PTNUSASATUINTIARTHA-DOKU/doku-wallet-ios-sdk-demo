//
//  DataBindingWebviewRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/11/23.
//

import UIKit

class DataBindingWebviewRouter: WebviewRouterProtocol {
    
    weak var viewController: UIViewController?
    var window: UIWindow?
    
    static func assembleModule(webviewConfig: WebviewConfig) -> UIViewController {
        
        let storyboard = UIStoryboard(name: ViewId.webview.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.webview.viewController) as! WebviewViewController
        let router = DataBindingWebviewRouter()
        let interactor = DataBindingWebviewInteractor()
        let presenter = DataBindingWebviewPresenter(view: view, interactor: interactor, router: router, webviewConfig: webviewConfig)
        
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
        if let viewControllers = viewController?.navigationController?.viewControllers {
            for viewController in viewControllers {
                if let menuViewController = viewController as? MenuViewController {
                    viewController.navigationController?.popToViewController(menuViewController, animated: true)
                    let titleText = "Akun kamu berhasil dibuat."
                    let titleAttributedString = NSMutableAttributedString(string: titleText, attributes: [
                        .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                        .foregroundColor: AppHelper.shared.getColor(color: .c00726e),
                        .kern: 0.0
                    ])
                    menuViewController.showToast(mutableAttributedStringMessage: titleAttributedString, image: UIImage(named: "success-circle-fill"), backgroundColor: AppHelper.shared.getColor(color: .cc5edec), containerHeight: 48)
                    return
                }
            }
        }
    }
}
