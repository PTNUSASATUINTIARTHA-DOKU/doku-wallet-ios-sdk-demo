//
//  QrisAmountConfirmationViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import AVFoundation
import DokuWalletSDK

class QrisAmountConfirmationViewController: BaseViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var merchantNameLabel: UILabel!
    @IBOutlet weak var merchantLocationLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var nominalAmountLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var tipsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipsStackView: UIStackView!
    
    @IBOutlet weak var button2000: UIButton!
    @IBOutlet weak var button5000: UIButton!
    @IBOutlet weak var button10000: UIButton!
    @IBOutlet weak var button15000: UIButton!
    @IBOutlet weak var button20000: UIButton!
    
    var presenter: QrisAmountConfirmationPresenterProtocol?
    var transactionAmount: Double = 0.0
    var feeAmount: Double = 0.0
    var tipsForm = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultNavigation(title: "Payment QRIS", backAction: #selector(backButtonTapped), backType: .back)
        presenter?.requestData()
        
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if tipsForm {
            presenter?.processTransaction(tips: "\(feeAmount)")
        } else {
            presenter?.processTransaction(tips: nil)
        }
    }
    
    private func setupTipsForm() {
        tipsForm = true
        tipsStackView.isHidden = false
        feeLabel.text = "Tips"
        tipsViewTopConstraint.constant = 18
        tipsViewHeightConstraint.constant = 92
    }
    
    @IBAction func tipsButtonTapped(_ sender: UIButton) {
        if (sender.isSelected) {
            sender.isSelected = false
            sender.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            self.feeAmount = 0
            updateTotalAmount()
            return;
        }
        else {
            button2000.isSelected = false
            button5000.isSelected = false
            button10000.isSelected = false
            button15000.isSelected = false
            button20000.isSelected = false
            
            button2000.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            button5000.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            button10000.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            button15000.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            button20000.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            
            self.feeAmount = Double(sender.tag)
            updateTotalAmount()
            sender.isSelected = true
            sender.layer.borderColor = AppHelper.shared.getColor(color: .ce1251b).cgColor
        }
    }
    
    func updateTotalAmount() {
        let totalAmount = transactionAmount + feeAmount
        totalAmountLabel.text = String(totalAmount).currencyFormatterForNumber(currencySymbol: "Rp")
    }
    
}

extension QrisAmountConfirmationViewController: QrisAmountConfirmationViewProtocol {
    func displayData(decodeQrisData: DecodeQrisResponse, transactionAmount: String) {
        self.merchantNameLabel.text = decodeQrisData.merchantName
        self.merchantLocationLabel.text = decodeQrisData.merchantLocation
        self.nominalAmountLabel.text = transactionAmount.currencyFormatterForNumber(currencySymbol: "Rp")
        self.transactionAmount = Double(transactionAmount) ?? 0.0
        
        let feeTypeDescription = decodeQrisData.additionalInfo?.feeTypeDescription
        if feeTypeDescription == nil || feeTypeDescription == QrisFeeTypeDescription.noTips.rawValue {
            self.feeAmountLabel.text = "Rp0"
            self.totalAmountLabel.text = transactionAmount.currencyFormatterForNumber(currencySymbol: "Rp")
        } else if feeTypeDescription == QrisFeeTypeDescription.fixedTips.rawValue {
            self.feeAmount = decodeQrisData.feeAmount?.value ?? 0.0
            self.feeAmountLabel.text = "\(self.feeAmount)".currencyFormatterForNumber(currencySymbol: "Rp")
            let totalAmount = self.transactionAmount + self.feeAmount
            self.totalAmountLabel.text = "\(totalAmount)".currencyFormatterForNumber(currencySymbol: "Rp")
        } else if feeTypeDescription == QrisFeeTypeDescription.openTips.rawValue {
            setupTipsForm()
            self.feeAmountLabel.text = ""
            self.totalAmountLabel.text = transactionAmount.currencyFormatterForNumber(currencySymbol: "Rp")
        } else {
            // undefined feeType
            self.feeAmountLabel.text = "Rp ??"
            self.totalAmountLabel.text = "Rp ??"
        }
    }
    
}
