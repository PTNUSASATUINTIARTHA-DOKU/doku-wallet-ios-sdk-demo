//
//  GenerateQrisInputFormViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 05/12/23.
//

import UIKit

class GenerateQrisInputFormViewController: BaseViewController {

    @IBOutlet weak var amountTextFieldView: CustomTextFieldView!
    @IBOutlet weak var feeTypeDropDownTextFieldView: CustomDropDownTextFieldView!
    @IBOutlet weak var feeAmounTextFieldView: CustomTextFieldView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var fixedFeeView: UIView!
    @IBOutlet weak var feeSwitch: UISwitch!
    var feeTypes = ["Open for tips", "Fixed Fee"]
    
    var isValidAmount = false, isOpenForTips = true, isValidFeeAmount = false, isValidAllField = false

    var presenter: GenerateQrisInputFormPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupDropdown()
        setupDefaultNavigation(title: "Generate QRIS", backAction: #selector(backButtonTapped), backType: .back)
        descriptionLabel.setLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, alignment: .left)
    }
    
    func setupDropdown() {
        let dropdownTextField = feeTypeDropDownTextFieldView.textField
        dropdownTextField?.delegate = self
        dropdownTextField?.optionArray = feeTypes
        let dropDownRowHeight = (dropdownTextField?.frame.height ?? 0) + 4
        dropdownTextField?.rowHeight = dropDownRowHeight
        dropdownTextField?.listHeight = dropDownRowHeight * CGFloat(5)
        dropdownTextField?.selectedRowColor = UIColor.white
        dropdownTextField?.arrowSize = 9
        dropdownTextField?.arrowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7)
        dropdownTextField?.checkMarkEnabled = false
        dropdownTextField?.isSearchEnable = false
        dropdownTextField?.handleKeyboard = false
        dropdownTextField?.separatorStyle = .singleLine
        dropdownTextField?.clickedPlaceholder = "Pilih kategori kendala"
        dropdownTextField?.hideListPlaceholder = "Pilih kategori kendala"
        dropdownTextField?.isShowKeyboard = false
        dropdownTextField?.keyboardIsShown = false
        dropdownTextField?.text = "Open for tips"
        
        dropdownTextField?.didSelect { selectedText, index, id in
            if selectedText == "Open for tips" {
                self.isOpenForTips = true
                self.fixedFeeView.isHidden = true
            } else if selectedText == "Fixed Fee" {
                self.isOpenForTips = false
                self.fixedFeeView.isHidden = false
            }
            self.resetFixedFeeView()
            self.setupButtonVerification()
            self.calculateTotalAmountTextFieldDidSelectFeeType()
        }
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        if sender.isOn {
            feeTypeDropDownTextFieldView.isHidden = false
            if feeTypeDropDownTextFieldView.textField.text == "Fixed Fee" {
                self.fixedFeeView.isHidden = false
            }
        } else {
            feeTypeDropDownTextFieldView.isHidden = true
            fixedFeeView.isHidden = true
        }
        resetFixedFeeView()
        setupButtonVerification()
    }
    
  
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTextField() {
        amountTextFieldView.textField.delegate = self
        amountTextFieldView.setupView(title: "Masukan Jumlah Transaksi", placeHolder: "Dalam rupiah", keyboardType: .numberPad, contentType: .name)
        amountTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        feeTypeDropDownTextFieldView.textField.delegate = self
        feeTypeDropDownTextFieldView.setupView(title: "Tipe Fee", placeHolder: "", keyboardType: .emailAddress, contentType: .emailAddress)
        feeTypeDropDownTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        feeAmounTextFieldView.textField.delegate = self
        feeAmounTextFieldView.setupView(title: "Masukan Nominal Fee", placeHolder: "Dalam rupiah", keyboardType: .phonePad, contentType: .telephoneNumber)
        feeAmounTextFieldView.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        var feeAmount = ""
        var feeType = ""
        let originalAmount = AppHelper.shared.getOriginalAmount(data: amountTextFieldView.textField.text ?? "0")
        if(!feeSwitch.isOn) {
            feeType = QrisFeeType.noTips.rawValue
        } else if (isOpenForTips) {
            feeType = QrisFeeType.openTips.rawValue
        } else {
            feeType = QrisFeeType.fixedTips.rawValue
            feeAmount = AppHelper.shared.getOriginalAmount(data: feeAmounTextFieldView.textField.text ?? "0")
        }
        let data = GenerateQrisInputFormStruct(amountValue: originalAmount, feeValue: feeAmount, feeType: feeType)
        presenter?.generateQris(generateQrisInputFormData: data)
    }
}

// MARK: - GenerateQrisInputFormTextFieldDelegate
extension GenerateQrisInputFormViewController: UITextFieldDelegate {
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        do {
            switch textField {
            case self.amountTextFieldView.textField :
                self.amountTextFieldView.textField.text = self.amountTextFieldView.textField.text?.currencyFormatterForCurrencyIntegerString()
                calculateTotalAmount()
                _ = try self.amountTextFieldView.textField.validatedText(validationType: .amount(field: "Jumlah transaksi", amountType: .qrisAmountGenerate))
                isValidAmount = true
                amountTextFieldView.setMistakeLabel("")
            case self.feeAmounTextFieldView.textField  :
                self.feeAmounTextFieldView.textField.text = self.feeAmounTextFieldView.textField.text?.currencyFormatterForCurrencyIntegerString()
                calculateTotalAmount()
                _ = try self.feeAmounTextFieldView.textField.validatedText(validationType: .amount(field: "Nominal fee", amountType: .qrisFee))
                isValidFeeAmount = true
                feeAmounTextFieldView.setMistakeLabel("")
            default:
                break
            }
        } catch let error {
            guard let validationError = error as? ValidationError else {
                return
            }
            self.isValidAllField = false
            if validationError.action == .removeAll {
                textField.text = ""
            }
            switch textField {
            case self.amountTextFieldView.textField :
                isValidAmount = false
                amountTextFieldView.setMistakeLabel(validationError.message)
            case self.feeAmounTextFieldView.textField  :
                isValidFeeAmount = false
                feeAmounTextFieldView.setMistakeLabel(validationError.message)
            default:
                break
            }
        }
        self.setupButtonVerification()
    }
    
    private func setupButtonVerification() {
        isValidAllField = (isValidAmount && (isOpenForTips || isValidFeeAmount))
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
        
        if textField == amountTextFieldView.textField || textField == feeAmounTextFieldView.textField  {
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            return count <= 10
        }
        
        return true
    }
    
    private func calculateTotalAmount() {
        if (feeSwitch.isOn && feeTypeDropDownTextFieldView.textField.text == "Fixed Fee") {
            let originalAmount = AppHelper.shared.getOriginalAmount(data: amountTextFieldView.textField.text ?? "0")
            let originalFeeAmount = AppHelper.shared.getOriginalAmount(data: feeAmounTextFieldView.textField.text ?? "0")
            let totalAmount = (Double(originalAmount) ?? 0.0) + (Double(originalFeeAmount) ?? 0.0)
            let formattedTotalAmount = "\(Int(totalAmount))".currencyFormatterForCurrencyIntegerString(currencySymbol: "Rp")
            totalAmountLabel.text = formattedTotalAmount
        }
    }
    
    private func calculateTotalAmountTextFieldDidSelectFeeType() {
        let originalAmount = AppHelper.shared.getOriginalAmount(data: amountTextFieldView.textField.text ?? "0")
        let originalFeeAmount = AppHelper.shared.getOriginalAmount(data: feeAmounTextFieldView.textField.text ?? "0")
        let totalAmount = (Double(originalAmount) ?? 0.0) + (Double(originalFeeAmount) ?? 0.0)
        let formattedTotalAmount = "\(Int(totalAmount))".currencyFormatterForCurrencyIntegerString(currencySymbol: "Rp")
        totalAmountLabel.text = formattedTotalAmount
    }
    
    private func resetFixedFeeView() {
        feeAmounTextFieldView.textField.text = ""
        isValidFeeAmount = false
        totalAmountLabel.text = "-"
        feeAmounTextFieldView.mistakeLabel.text = ""
    }
}

extension GenerateQrisInputFormViewController: GenerateQrisInputFormViewProtocol {
   
}

