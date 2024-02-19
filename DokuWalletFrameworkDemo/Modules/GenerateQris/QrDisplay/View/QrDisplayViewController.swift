//
//  QrDisplayViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 07/12/23.
//

import UIKit
import DokuWalletSDK

class QrDisplayViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var autoQueryLabel: UILabel!
    var presenter: QrDisplayPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewdidLoad()
        setupDefaultNavigation(title: "Detail Transaksi", backAction: #selector(backButtonTapped), backType: .close)
        
    }
    
    @objc func backButtonTapped() {
        presenter?.back()
    }
    
    @IBAction func checkStatusTapped(_ sender: Any) {
        presenter?.queryQris()
    }
    
    @IBAction func returnToTransactionListTapped(_ sender: Any) {
        presenter?.back()
    }
}

extension QrDisplayViewController: QrDisplayViewProtocol {
    func displayData(qrContent: String, formattedTotalAmount: String) {
        totalAmountLabel.text = formattedTotalAmount
        qrImageView.image = SnapHelper.shared.stringToQrCode(qr: qrContent)
    }
    
    func updateCountdownLabel(seconds: String) {
        let highlightString = "\(seconds) detik"
        let countdownAttributedString = NSMutableAttributedString(string: "Melakukan cek status otomatis dalam \(highlightString)", attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: AppHelper.shared.getColor(color: .c818995),
          .kern: 0.0
        ])
        let highlightLocation = 36
        countdownAttributedString.addAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium),
                                                 .foregroundColor: AppHelper.shared.getColor(color: .c2c333c)], range: NSRange(location:highlightLocation, length: highlightString.count))
        autoQueryLabel.attributedText = countdownAttributedString
    }
}
