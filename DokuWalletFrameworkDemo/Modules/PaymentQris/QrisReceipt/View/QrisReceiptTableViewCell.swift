//
//  QrisReceiptTableViewCell.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 19/12/23.
//

import UIKit

class QrisReceiptTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        descriptionLabel.text = ""
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        titleLabel.textColor = AppHelper.shared.getColor(color: .c69707a)
    }

}

