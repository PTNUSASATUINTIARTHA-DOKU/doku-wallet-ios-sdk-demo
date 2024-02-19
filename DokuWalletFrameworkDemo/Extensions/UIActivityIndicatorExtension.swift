//
//  UIActivityIndicatorExtension.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 09/11/23.
//

import UIKit

extension UIActivityIndicatorView {
    
    internal static func middleIndicator(at center: CGPoint) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 100))
        indicator.center = center
        indicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            indicator.style = UIActivityIndicatorView.Style.large
        } else {
            indicator.style = UIActivityIndicatorView.Style.whiteLarge
        }
        indicator.layer.cornerRadius = 10
        indicator.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        indicator.color = .white
        
        return indicator
    }
}
