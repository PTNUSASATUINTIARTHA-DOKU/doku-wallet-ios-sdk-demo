//
//  BottomPopUpMessageRouter.swift
//  WalletSDK
//
//  Created by DOKU on 30/05/22.
//

import Foundation
import UIKit

class BottomPopUpMessageRouter: BottomPopUpMessageRouterProtocol {
    weak var viewController: UIViewController?
    
    static func assembleModule(bottomPopUpData: BottomPopUpDataStruct) -> UIViewController {
        let storyboard = UIStoryboard(name: ViewId.bottomPopUpMessage.storyboard, bundle: Bundle.main)
        let view = storyboard.instantiateViewController(withIdentifier: ViewId.bottomPopUpMessage.viewController) as! BottomPopUpMessageViewController
        
        let router = BottomPopUpMessageRouter()
        let presenter = BottomPopUpMessagePresenter(view: view, router: router, bottomPopUpData: bottomPopUpData)
        view.presenter = presenter
        view.height = bottomPopUpData.height
        
        return view
    }
}
