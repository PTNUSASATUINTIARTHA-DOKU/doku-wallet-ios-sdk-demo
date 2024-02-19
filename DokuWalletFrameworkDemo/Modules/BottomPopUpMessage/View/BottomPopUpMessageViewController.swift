//
//  BottomPopUpMessageViewController.swift
//  WalletSDK
//
//  Created by DOKU on 30/05/22.
//

import UIKit

class BottomPopUpMessageViewController: BottomPopupViewController {
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    var buttonAction: () -> Void = {}
    var dismissAction: () -> Void = {}
    var presenter: BottomPopUpMessagePresenterProtocol?
    var bottomPopUpData: BottomPopUpDataStruct?
    var buttonTapped = false
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.onLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if(!buttonTapped) {
            dismissAction()
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        buttonTapped = true
        self.dismiss(animated: true)
        buttonAction()
    }
    
    override func getPopupHeight() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        if let popUpHeight = height {
            return popUpHeight + bottomPadding
        } else {
            return 334 + bottomPadding
        }
    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override func getPopupPresentDuration() -> Double {
        return presentDuration ?? 0.5
    }
    
    override func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 0.5
    }
    
    override func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
    
}

extension BottomPopUpMessageViewController: BottomPopUpMessageViewProtocol {
    func onLoad(bottomPopUpData: BottomPopUpDataStruct) {
        self.mainImage.image = bottomPopUpData.image
        self.titleLabel.attributedText = bottomPopUpData.title
        self.detailLabel.attributedText = bottomPopUpData.detail
        self.titleLabel.setLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, alignment: .center)
        self.detailLabel.setLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, alignment: .center)
        
        self.button.setTitle(bottomPopUpData.primaryButtonTitle, for: .normal)
        self.button.backgroundColor = bottomPopUpData.primaryButtonBackgroundColor
        self.button.setTitleColor(bottomPopUpData.primaryButtonTitleColor, for: .normal)
        if(bottomPopUpData.primaryButtonBordered == true) {
            self.button.borderColor = bottomPopUpData.primaryButtonBorderColor
            self.button.borderWidth = bottomPopUpData.primaryButtonBorderWidth ?? 0
        }
        self.buttonAction = bottomPopUpData.primaryButtonAction
        
        self.dismissAction = bottomPopUpData.dismissAction
    }
}
