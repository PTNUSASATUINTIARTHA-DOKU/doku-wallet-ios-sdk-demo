//
//  ResultMessagePresenter.swift
//  WalletSDK
//
//  Created by DOKU on 11/05/23.
//

import Foundation

class ResultMessagePresenter: ResultMessagePresenterProtocol {

    var router: ResultMessageRouterProtocol?
    var view: ResultMessageViewProtocol?
    var data: ResultMessageDataStruct
    
    init(router: ResultMessageRouterProtocol, view: ResultMessageViewProtocol?, data: ResultMessageDataStruct) {
        self.router = router
        self.view = view
        self.data = data
    }
    
    func displayData() {
        view?.displayData(data: data)
    }
    
    func goBackToMainMenu() {
        router?.goBackToMainMenu()
    }
}
