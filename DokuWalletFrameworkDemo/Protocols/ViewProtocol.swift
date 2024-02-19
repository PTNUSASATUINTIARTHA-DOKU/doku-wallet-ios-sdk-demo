//
//  ViewProtocol.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit

protocol ViewProtocol {
    func showActivityIndicator()
    
    func hideActivityIndicator()
    
    func showCommonError(title: String, detail: String, action: @escaping () -> Void)
}
