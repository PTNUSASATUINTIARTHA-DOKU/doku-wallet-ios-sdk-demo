//
//  BottomPopUpDataStruct.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 09/11/23.
//

import UIKit

struct BottomPopUpDataStruct {
    var image: UIImage?
    var title: NSMutableAttributedString?
    var detail: NSMutableAttributedString?
    
    var primaryButtonTitle: String?
    var primaryButtonTitleColor: UIColor?
    var primaryButtonBackgroundColor: UIColor?
    var primaryButtonBorderColor: UIColor?
    var primaryButtonBorderWidth: CGFloat?
    var primaryButtonBordered: Bool?
    
    var secondaryButtonTitle: String?
    var secondaryButtonTitleColor: UIColor?
    var secondaryButtonBackgroundColor: UIColor?
    var secondaryButtonBorderColor: UIColor?
    var secondaryButtonBorderWidth: CGFloat?
    var secondaryButtonBordered: Bool?
    
    var primaryButtonAction: () -> Void
    var secondaryButtonAction: () -> Void
    
    var height: CGFloat?
    var dismissAction: () -> Void
    var implementClientTheme: Bool = true
    var stopMainButtonDismiss: Bool = false
    
    init(image: UIImage?, title: NSMutableAttributedString?, detail: NSMutableAttributedString?, primaryButtonTitle: String?, primaryButtonTitleColor: UIColor?, primaryButtonBackgroundColor: UIColor?, primaryButtonBorderColor: UIColor? = nil, primaryButtonBorderWidth: CGFloat? = 0, primaryButtonBordered: Bool? = false, primaryButtonAction: @escaping () -> Void, height: CGFloat = 334, dismissAction: @escaping () -> Void = {}, secondaryButtonTitle: String? = nil, secondaryButtonTitleColor: UIColor? = nil, secondaryButtonBackgroundColor: UIColor? = nil, secondaryButtonBorderColor: UIColor? = nil, secondaryButtonBorderWidth: CGFloat? = 0, secondaryButtonBordered: Bool? = false, secondaryButtonAction: @escaping ()-> Void = {}) {
        self.image = image
        self.title = title
        self.detail = detail
        
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonTitleColor = primaryButtonTitleColor
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor
        self.primaryButtonBorderColor = primaryButtonBorderColor
        self.primaryButtonBorderWidth = primaryButtonBorderWidth
        self.primaryButtonBordered = primaryButtonBordered
        
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonTitleColor = secondaryButtonTitleColor
        self.secondaryButtonBackgroundColor = secondaryButtonBackgroundColor
        self.secondaryButtonBorderColor = secondaryButtonBorderColor
        self.secondaryButtonBorderWidth = secondaryButtonBorderWidth
        self.secondaryButtonBordered = secondaryButtonBordered
        
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction
        
        self.height = height
        self.dismissAction = dismissAction
    }
}
