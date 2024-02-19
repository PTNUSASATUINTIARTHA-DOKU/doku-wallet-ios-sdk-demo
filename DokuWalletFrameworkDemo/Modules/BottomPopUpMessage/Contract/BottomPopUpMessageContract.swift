//
//  BottomPopUpMessageContract.swift
//  WalletSDK
//
//  Created by DOKU on 30/05/22.
//

import Foundation

protocol BottomPopUpMessageViewProtocol {
    func onLoad(bottomPopUpData: BottomPopUpDataStruct)
}

protocol BottomPopUpMessagePresenterProtocol {
    var view: BottomPopUpMessageViewProtocol? { get set }
    var router: BottomPopUpMessageRouterProtocol? { get set }
    
    func onLoad()
}

protocol BottomPopUpMessageRouterProtocol {
    
}
