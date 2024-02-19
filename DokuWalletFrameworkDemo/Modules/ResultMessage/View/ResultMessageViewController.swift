//
//  ResultMessageViewController.swift
//  WalletSDK
//
//  Created by DOKU on 11/05/23.
//

import UIKit

class ResultMessageViewController: UIViewController {
    
    var presenter: ResultMessagePresenterProtocol?
    var titleString: String?
    
    @IBOutlet weak var labelHeaderMessage: UILabel!
    @IBOutlet weak var labelDetailMessage: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var upperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    var timer: Timer?
    lazy var time = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = titleString ?? ""
        presenter?.displayData()
        labelDetailMessage.setLineSpacing(lineSpacing: 8, lineHeightMultiple: 1, alignment: .center)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        presenter?.goBackToMainMenu()
    }
}

extension ResultMessageViewController: ResultMessageViewProtocol {
    
    func displayData(data: ResultMessageDataStruct) {
        self.labelHeaderMessage.attributedText = data.header
        self.labelDetailMessage.attributedText = data.description
        self.resultImageView.image = data.image
        if data.isAutoRedirectPage {
            self.time = 3
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(redirect), userInfo: nil, repeats: true)
        }
    }
    
    @objc func redirect() {
        if time != 0 {
            time -= 1
        } else {
            self.timer = nil
            presenter?.goBackToMainMenu()
        }
    }
}
