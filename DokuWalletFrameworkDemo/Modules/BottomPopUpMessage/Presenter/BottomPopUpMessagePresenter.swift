//
//  BottomPopUpMessagePresenter.swift
//  WalletSDK
//
//  Created by DOKU on 30/05/22.
//

import Foundation
import UIKit

class BottomPopUpMessagePresenter: BottomPopUpMessagePresenterProtocol {
    var view: BottomPopUpMessageViewProtocol?
    var router: BottomPopUpMessageRouterProtocol?
    var bottomPopUpData: BottomPopUpDataStruct
    
    init(view: BottomPopUpMessageViewProtocol?, router: BottomPopUpMessageRouterProtocol?, bottomPopUpData: BottomPopUpDataStruct) {
        self.view = view
        self.router = router
        self.bottomPopUpData = bottomPopUpData
    }
    
    func onLoad() {
        view?.onLoad(bottomPopUpData: bottomPopUpData)
    }
}
