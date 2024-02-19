//
//  ResultMessageDataStruct.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 07/12/23.
//

import UIKit

struct ResultMessageDataStruct {
    var image: UIImage?
    var header: NSMutableAttributedString?
    var description: NSMutableAttributedString?
    var isAutoRedirectPage: Bool
    
    init(image: UIImage?, header: NSMutableAttributedString?, description: NSMutableAttributedString?, isAutoRedirectPage: Bool) {
        self.image = image
        self.header = header
        self.description = description
        self.isAutoRedirectPage = isAutoRedirectPage
    }
}
