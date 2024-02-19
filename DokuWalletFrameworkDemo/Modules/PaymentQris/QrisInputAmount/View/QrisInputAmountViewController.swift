//
//  QrisInputAmountViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import AVFoundation
import DokuWalletSDK

class QrisInputAmountViewController: BaseViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var merchantNameLabel: UILabel!
    @IBOutlet weak var merchantLocationLabel: UILabel!
    @IBOutlet weak var amountTextFieldView: CustomTextFieldView!
    
    var presenter: QrisInputAmountPresenterProtocol?
    var isValidAmount = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupDefaultNavigation(title: "Payment QRIS", backAction: #selector(backButtonTapped), backType: .back)
        presenter?.requestData()
        
    }
    
    private func setupTextField() {
        amountTextFieldView.textField.delegate = self
        amountTextFieldView.setupView(title: "Masukan Nominal Pembayaran", placeHolder: "Dalam rupiah", keyboardType: .numberPad, contentType: .name)
        amountTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let originalAmount = AppHelper.shared.getOriginalAmount(data: amountTextFieldView.textField.text ?? "0")
        presenter?.goToNextPage(transactionAmount: originalAmount)
    }
}

// MARK: - QrisInputAmountTextFieldDelegate
extension QrisInputAmountViewController: UITextFieldDelegate {
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        do {
            switch textField {
            case self.amountTextFieldView.textField :
                self.amountTextFieldView.textField.text = self.amountTextFieldView.textField.text?.currencyFormatterForCurrencyIntegerString(currencySymbol: "Rp")
                _ = try self.amountTextFieldView.textField.validatedText(validationType: .amount(field: "Nominal pembayaran", amountType: .qrisAmountPayment))
                isValidAmount = true
                amountTextFieldView.setMistakeLabel("")
            default:
                break
            }
        } catch let error {
            guard let validationError = error as? ValidationError else {
                return
            }
            if validationError.action == .removeAll {
                textField.text = ""
            }
            switch textField {
            case self.amountTextFieldView.textField :
                isValidAmount = false
                amountTextFieldView.setMistakeLabel(validationError.message)
            default:
                break
            }
        }
        self.setupButtonVerification()
    }
    
    private func setupButtonVerification() {
        self.nextButton.isEnabled = isValidAmount
        self.nextButton.backgroundColor = isValidAmount ? AppHelper.shared.getColor(color: .ce1251b) : AppHelper.shared.getColor(color: .ce5e8ec)
        let titleColor = isValidAmount ? AppHelper.shared.getColor(color: .cffffff) : AppHelper.shared.getColor(color: .c818995)
        self.nextButton.setTitleColor(titleColor, for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        
        if textField == amountTextFieldView.textField {
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            return count <= 12
        }
        
        return true
    }
}

extension QrisInputAmountViewController: QrisInputAmountViewProtocol {
    
    func displayData(data: DecodeQrisResponse) {
        merchantNameLabel.text = data.merchantName
        merchantLocationLabel.text = data.merchantLocation
    }
}
