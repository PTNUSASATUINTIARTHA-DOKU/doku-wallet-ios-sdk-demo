//
//  ViewProtocolExtension.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit

extension ViewProtocol where Self: UIViewController {
    func showActivityIndicator() {
        startActivityIndicator()
    }
    
    func hideActivityIndicator() {
        stopActivityIndicator()
    }
    
    func showCommonError(title: String, detail: String, action: @escaping () -> Void = {}) {
        let title = NSMutableAttributedString(string: title, attributes: [
          .foregroundColor: #colorLiteral(red: 0.2156862745, green: 0.2196078431, blue: 0.2, alpha: 1),
          .kern: 0.0
        ])
        
        let detail = NSMutableAttributedString(string: detail, attributes: [
          .foregroundColor: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1),
          .kern: 0.0
        ])
        
        let bottomPopUpData = BottomPopUpDataStruct(image: UIImage(named: "error"), title: title, detail: detail, primaryButtonTitle: "OK", primaryButtonTitleColor: #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1), primaryButtonBackgroundColor: #colorLiteral(red: 0.8823529412, green: 0.1450980392, blue: 0.1058823529, alpha: 1), primaryButtonAction: action, height: 334)
        let view = BottomPopUpMessageRouter.assembleModule(bottomPopUpData: bottomPopUpData)
        self.present(view, animated: true, completion: nil)
    }
}
