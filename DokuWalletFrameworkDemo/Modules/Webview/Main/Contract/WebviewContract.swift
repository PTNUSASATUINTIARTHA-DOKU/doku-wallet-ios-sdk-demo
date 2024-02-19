//
//  WebviewContract.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 13/11/23.
//

import Foundation

protocol WebviewViewProtocol: ViewProtocol {

    func loadData(webviewConfig: WebviewConfig)
    
    func loadBlankScreen()
}

protocol WebviewPresenterProtocol {

    var view: WebviewViewProtocol? { get set }
    var interactor: WebviewInteractorProtocol? { get set }
    var router: WebviewRouterProtocol? { get set }
    
    func loadData()
    
    func detectUrl(urlString: String)

    func back()

}

protocol WebviewInteractorProtocol {
    func hitApi(urlString: String)
}

protocol WebviewInteractorOutputProtocol {
    func processHitApiResponse<T>(data: T?)
}

protocol WebviewRouterProtocol: RouterProtocol {

    func back(backType: BackType)
    
    func goToNextPage<T>(data: T?)
    
}
