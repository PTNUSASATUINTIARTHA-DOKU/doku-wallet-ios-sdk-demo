//
//  CustomTextFieldView.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import UIKit

class CustomTextFieldView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mistakeLabel: UILabel!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func loadViewFromNib() -> UIView? {
        return UINib(nibName: "CustomTextFieldView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView
    }
    
    func setupView(title: String, placeHolder: String, keyboardType: UIKeyboardType = .default, contentType: UITextContentType? = nil, isSecureTextEntry: Bool = false) {
        titleLabel.text = title
        textField.placeholder = placeHolder
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecureTextEntry
        
        if let contentType = contentType {
            textField.textContentType = contentType
        }
    }
    
    func setMistakeLabel(_ mistakeMessage: String) {
        mistakeLabel.text = mistakeMessage
    }
}
