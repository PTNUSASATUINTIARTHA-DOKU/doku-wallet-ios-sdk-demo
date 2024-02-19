//
//  VerifyOtpViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 11/11/23.
//

import UIKit

class VerifyOtpViewController: BaseViewController {

    @IBOutlet weak var otpTextFieldView: CustomTextFieldView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendOtpCountdownLabel: UILabel!
    @IBOutlet weak var resendOtpButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    var isValidOtp = false
    var presenter: VerifyOtpPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        presenter?.loadPhoneNo()
        presenter?.startOtpTimer()
        setupDefaultNavigation(title: "Account Creation", backAction: #selector(backButtonTapped), backType: .back)
        descriptionLabel.setLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, alignment: .left)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTextField() {
        otpTextFieldView.textField.delegate = self
        otpTextFieldView.setupView(title: "OTP", placeHolder: "Masukan OTP", keyboardType: .numberPad, contentType: .oneTimeCode)
        otpTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        presenter?.verifyOtp(otp: otpTextFieldView.textField.text ?? "")
    }
    
    @IBAction func resendOtpButtonTapped(_ sender: Any) {
        presenter?.resendOtp()
    }
}

// MARK: - VerifyOtpTextFieldDelegate
extension VerifyOtpViewController: UITextFieldDelegate {
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        do {
            _ = try self.otpTextFieldView.textField.validatedText(validationType: .otp(forField: "OTP"))
            isValidOtp = true
            otpTextFieldView.setMistakeLabel("")
        } catch let error {
            guard let validationError = error as? ValidationError else {
                return
            }
            isValidOtp = false
            otpTextFieldView.setMistakeLabel(validationError.message)
        }
        self.setupButtonVerification()
    }
    
    private func setupButtonVerification() {
        self.nextButton.isEnabled = isValidOtp
        self.nextButton.backgroundColor = isValidOtp ? AppHelper.shared.getColor(color: .ce1251b) : AppHelper.shared.getColor(color: .ce5e8ec)
        let titleColor = isValidOtp ? AppHelper.shared.getColor(color: .cffffff) : AppHelper.shared.getColor(color: .c818995)
        self.nextButton.setTitleColor(titleColor, for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        if textField == otpTextFieldView.textField  {
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return count <= 6 && allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}


// MARK: - VerifyOtpViewProtocol
extension VerifyOtpViewController: VerifyOtpViewProtocol {
    func displayPhoneNo(phoneNo: String) {
        instructionLabel.text = "Masukkan 6 digit OTP yang telah dikirim melalui nomor telepon \(phoneNo.formatPhoneNumber())"
    }
    
    func updateCountdownLabel(text: String) {
        resendOtpCountdownLabel.text = text
    }
    
    func setupResendOtpButton(isActive: Bool) {
        resendOtpButton.isEnabled = isActive
        self.resendOtpButton.backgroundColor = isActive ? AppHelper.shared.getColor(color: .cffffff) : AppHelper.shared.getColor(color: .ce5e8ec)
        self.resendOtpButton.setTitleColor(isActive ? AppHelper.shared.getColor(color: .ce1251b) : AppHelper.shared.getColor(color: .c818995), for: .normal)
        self.resendOtpButton.borderColor = isActive ? AppHelper.shared.getColor(color: .ce1251b) : .clear
        self.resendOtpButton.borderWidth = isActive ? 1 : 0
    }
    
    func clearOtp() {
        otpTextFieldView.textField.text = ""
    }
}
