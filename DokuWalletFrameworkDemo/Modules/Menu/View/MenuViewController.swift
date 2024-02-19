//
//  MenuViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var accountCreationView: UIView!
    @IBOutlet weak var generateQrisView: UIView!
    @IBOutlet weak var paymentQrisView: UIView!
    
    var presenter: MenuPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupMenuTapGesture()
        
    }
    
    private func setupMenuTapGesture() {
        let accountCreationTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.accountCreationTapped(_:)))
        accountCreationView.addGestureRecognizer(accountCreationTapGesture)
        
        let generateQrisTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.generateQrisTapped(_:)))
        generateQrisView.addGestureRecognizer(generateQrisTapGesture)
        
        let paymentQrisTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.paymentQrisTapped(_:)))
        paymentQrisView.addGestureRecognizer(paymentQrisTapGesture)
    }
    
    @objc func accountCreationTapped(_ sender: UITapGestureRecognizer) {
        presenter?.goToAccountCreationFlow()
    }
    
    @objc func generateQrisTapped(_ sender: UITapGestureRecognizer) {
        presenter?.goToGenerateQrisFlow()
    }
    
    @objc func paymentQrisTapped(_ sender: UITapGestureRecognizer) {
        presenter?.goToPaymentQrisFlow()
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "Partner App (SDK Wallet)"
        let logoImage = UIImage(named: "AppIcon")
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        logoImageView.contentMode = .scaleAspectFit
        let logoImageItem = UIBarButtonItem.init(customView: logoImageView)

        logoImageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        self.navigationItem.leftBarButtonItems = [logoImageItem]
        
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium) as Any, NSAttributedString.Key.foregroundColor: AppHelper.shared.getColor(color: .c212832)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.isTranslucent = false
        
    }
}

// MARK: - MenuViewProtocol
extension MenuViewController: MenuViewProtocol {
   
}
