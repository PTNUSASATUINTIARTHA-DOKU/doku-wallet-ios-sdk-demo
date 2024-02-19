//
//  ResultMessageRouter.swift
//  WalletSDK
//
//  Created by DOKU on 11/05/23.
//

import UIKit

class ResultMessageRouter: ResultMessageRouterProtocol {
    
    weak var viewController: UIViewController?
    
    static func assembleModule(data: ResultMessageDataStruct) -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.resultMessage.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.resultMessage.viewController) as? ResultMessageViewController
        let router = ResultMessageRouter()
        let presenter = ResultMessagePresenter(router: router, view: view, data: data)
        
        view?.presenter = presenter
        router.viewController = view
        
        return view!
    }
    
    func goBackToMainMenu() {
        if let viewControllers = viewController?.navigationController?.viewControllers {
            for viewController in viewControllers {
                if let menuViewController = viewController as? MenuViewController {
                    viewController.navigationController?.popToViewController(menuViewController, animated: true)
                }
            }
        }
    }
}
