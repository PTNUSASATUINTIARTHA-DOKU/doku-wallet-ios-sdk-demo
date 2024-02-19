//
//  AccountCreationViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import UIKit

class AccountCreationViewController: BaseViewController {

    @IBOutlet weak var nameTextFieldView: CustomTextFieldView!
    @IBOutlet weak var emailTextFieldView: CustomTextFieldView!
    @IBOutlet weak var phoneNumberTextFieldView: CustomTextFieldView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    var isValidName = false, isValidEmail = false, isValidPhoneNumber = false, isValidAllField = false

    var presenter: AccountCreationPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupDefaultNavigation(title: "Account Creation", backAction: #selector(backButtonTapped), backType: .back)
        descriptionLabel.setLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, alignment: .left)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTextField() {
        nameTextFieldView.textField.delegate = self
        nameTextFieldView.setupView(title: "Nama Lengkap", placeHolder: "Contoh: John Doe", keyboardType: .namePhonePad, contentType: .name)
        nameTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        emailTextFieldView.textField.delegate = self
        emailTextFieldView.setupView(title: "Email", placeHolder: "Contoh: your@email.com", keyboardType: .emailAddress, contentType: .emailAddress)
        emailTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        phoneNumberTextFieldView.textField.delegate = self
        phoneNumberTextFieldView.setupView(title: "Nomor Telepon", placeHolder: "Contoh: 628123456789", keyboardType: .phonePad, contentType: .telephoneNumber)
        phoneNumberTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let accountCreationData = AccountCreationStruct(name: nameTextFieldView.textField.text ?? "", email: emailTextFieldView.textField.text ?? "", phoneNo: phoneNumberTextFieldView.textField.text ?? "")
        presenter?.createAccount(accountCreationData: accountCreationData)
    }
}

// MARK: - AccountCreationTextFieldDelegate
extension AccountCreationViewController: UITextFieldDelegate {
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        do {
            switch textField {
            case self.nameTextFieldView.textField :
                _ = try self.nameTextFieldView.textField.validatedText(validationType: .name(forField: "Nama lengkap"))
                isValidName = true
                nameTextFieldView.setMistakeLabel("")
            case self.emailTextFieldView.textField :
                _ = try self.emailTextFieldView.textField.validatedText(validationType: .email)
                isValidEmail = true
                emailTextFieldView.setMistakeLabel("")
            case self.phoneNumberTextFieldView.textField  :
                _ = try self.phoneNumberTextFieldView.textField.validatedText(validationType: .phoneNumber(forField: "Nomor telepon"))
                isValidPhoneNumber = true
                phoneNumberTextFieldView.setMistakeLabel("")
            default:
                break
            }
        } catch let error {
            guard let validationError = error as? ValidationError else {
                return
            }
            self.isValidAllField = false
            switch textField {
            case self.nameTextFieldView.textField :
                isValidName = false
                nameTextFieldView.setMistakeLabel(validationError.message)
            case self.emailTextFieldView.textField :
                isValidEmail = false
                emailTextFieldView.setMistakeLabel(validationError.message)
            case self.phoneNumberTextFieldView.textField  :
                isValidPhoneNumber = false
                phoneNumberTextFieldView.setMistakeLabel(validationError.message)
            default:
                break
            }
        }
        
        isValidAllField = (isValidName && isValidEmail && isValidPhoneNumber)
        self.setupButtonVerification()
    }
    
    private func setupButtonVerification() {
        self.nextButton.isEnabled = isValidAllField
        self.nextButton.backgroundColor = isValidAllField ? AppHelper.shared.getColor(color: .ce1251b) : AppHelper.shared.getColor(color: .ce5e8ec)
        let titleColor = isValidAllField ? AppHelper.shared.getColor(color: .cffffff) : AppHelper.shared.getColor(color: .c818995)
        self.nextButton.setTitleColor(titleColor, for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        if textField == nameTextFieldView.textField {
            let allowedCharacters = CharacterSet.letters.union(CharacterSet.whitespaces)
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        } else if textField == phoneNumberTextFieldView.textField  {
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return count <= 14 && allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}


// MARK: - AccountCreationViewProtocol
extension AccountCreationViewController: AccountCreationViewProtocol {
   
}
