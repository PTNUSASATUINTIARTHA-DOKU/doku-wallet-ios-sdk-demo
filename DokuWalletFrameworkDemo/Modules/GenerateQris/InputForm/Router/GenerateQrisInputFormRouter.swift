//
//  GenerateQrisInputFormRouter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 05/12/23.
//

import UIKit

class GenerateQrisInputFormRouter: GenerateQrisInputFormRouterProtocol {
    
    var viewController: UIViewController?
    
    static func assembleModule() -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.generateQrisInputForm.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.generateQrisInputForm.viewController) as! GenerateQrisInputFormViewController
        
        let router = GenerateQrisInputFormRouter()
        let interactor = GenerateQrisInputFormInteractor()
        let presenter = GenerateQrisInputFormPresenter(view: view, router: router, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        return view
    }
    
    func goToQrDisplay(data: GenerateQrisInputFormStruct) {
        let qrDisplayView = QrDisplayRouter.assembleModule(generateQrisInputFormStruct: data)
        viewController?.navigationController?.pushViewController(qrDisplayView, animated: true)
    }
}
