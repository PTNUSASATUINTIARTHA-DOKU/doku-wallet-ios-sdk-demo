//
//  QrisReceiptViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import AVFoundation

class QrisReceiptViewController: UIViewController {

    @IBOutlet weak var receiptTableView: UITableView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var transactionTimeLabel: UILabel!
    @IBOutlet weak var merchantNameLabel: UILabel!
    @IBOutlet weak var merchantLocationLabel: UILabel!
    
    var presenter: QrisReceiptPresenterProtocol?
    var tableViewTitleArray: [String] = []
    var tableViewDescriptionArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupTableView()
        presenter?.requestData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupTableView() {
        receiptTableView.delegate = self
        receiptTableView.dataSource = self
        receiptTableView.separatorColor = .clear
    }
  
    @IBAction func returnToHomeTapped(_ sender: Any) {
        presenter?.returnToHome()
    }
}

extension QrisReceiptViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = receiptTableView.dequeueReusableCell(withIdentifier: "QrisReceiptTableViewCell") as! QrisReceiptTableViewCell
        
        let title = tableViewTitleArray[indexPath.row]
        cell.titleLabel?.text = title
        
        let description = tableViewDescriptionArray[indexPath.row]
        cell.descriptionLabel?.text = description
        
        if(title == "TOTAL BAYAR") {
            cell.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            cell.titleLabel?.textColor = AppHelper.shared.getColor(color: .c3f464f)
            
            cell.descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}

extension QrisReceiptViewController: QrisReceiptViewProtocol {
    
    func displayData(data: PaymentQrisReceiptDataStruct) {
        let formattedTotalAmount = String(data.totalAmount).currencyFormatterForNumber(currencySymbol: "Rp")
        totalAmountLabel.text = formattedTotalAmount
        
        let formattedTransactionAmount = String(data.transactionAmount).currencyFormatterForNumber(currencySymbol: "Rp")
        let formattedFeeAmount = String(data.feeAmount).currencyFormatterForNumber(currencySymbol: "Rp")
        
        let timestampString = data.transactionDate

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let timestamp = dateFormatter.date(from: timestampString) ?? Date()

        let firstFormat = DateFormatter()
        firstFormat.dateFormat = "dd MMMM yyyy - HH:mm"
        firstFormat.locale = Locale(identifier: "id_ID")

        let secondFormat = DateFormatter()
        secondFormat.dateFormat = "dd MMMM yyyy"
        secondFormat.locale = Locale(identifier: "id_ID")

        let thirdFormat = DateFormatter()
        thirdFormat.dateFormat = "HH:mm:ss"
        thirdFormat.locale = Locale(identifier: "id_ID")

        let firstFormattedDateString = firstFormat.string(from: timestamp)
        let secondFormattedDateString = secondFormat.string(from: timestamp)
        let thirdFormattedDateString = thirdFormat.string(from: timestamp)
        
        transactionTimeLabel.text = firstFormattedDateString
        merchantNameLabel.text = data.merchantName
        merchantLocationLabel.text = data.merchantLocation
        
        if(data.success) {
            statusImageView.image = UIImage(named: "success-status")
            statusLabel.text = "Pembayaran Berhasil"
            tableViewTitleArray = [
                "No Referensi",
                "Tanggal",
                "Waktu",
                "Nominal",
            ]
            
            tableViewDescriptionArray = [
                data.referenceNumber,
                secondFormattedDateString,
                thirdFormattedDateString,
                formattedTransactionAmount
            ]
            
            
        } else {
            statusImageView.image = UIImage(named: "failed-status")
            statusLabel.text = "Pembayaran Gagal"
            tableViewTitleArray = [
                "Tanggal",
                "Waktu",
                "Nominal",
            ]
            
            tableViewDescriptionArray = [
                secondFormattedDateString,
                thirdFormattedDateString,
                formattedTransactionAmount
            ]
        }
        
        if(data.feeAmount > 0) {
            tableViewTitleArray.append("Fee")
            tableViewDescriptionArray.append(formattedFeeAmount)
        }
        tableViewTitleArray.append("TOTAL BAYAR")
        tableViewDescriptionArray.append(formattedTotalAmount)
        receiptTableView.reloadData()
    }
}
