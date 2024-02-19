//
//  UIViewControllerExtension.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import UIKit

extension UIViewController {
    
    private static let association = ObjectAssociation<UIActivityIndicatorView>()
    
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var indicator: UIActivityIndicatorView {
        set {
            UIViewController.association[self] = newValue
            
        }
        get {
            if let indicator = UIViewController.association[self] {
                return indicator
            } else {
                UIViewController.association[self] = UIActivityIndicatorView.middleIndicator(at: self.view.center)
                return UIViewController.association[self]!
            }
        }
    }
    
    // MARK: - Acitivity Indicator
    func startActivityIndicator() {
        DispatchQueue.main.async {
            self.navigationController?.view.addSubview(self.indicator)
            self.indicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    internal final class ObjectAssociation<T: AnyObject> {
        
        private let policy: objc_AssociationPolicy
        public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
            
            self.policy = policy
        }
        
        public subscript(index: AnyObject) -> T? {
            
            get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
            set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
        }
    }
    
    func setupDefaultNavigation(title: String, backAction: Selector, backType: BackType) {
        
        self.navigationItem.title = title
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium) as Any, NSAttributedString.Key.foregroundColor: AppHelper.shared.getColor(color: .c212832)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.isTranslucent = false
        var backButtonImage: UIImage?
        if (backType == .back) {
            backButtonImage = UIImage(named: "back")
        } else {
            backButtonImage = UIImage(named: "close")
        }
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: backAction)
        backButton.tintColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)
        navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }
    
    func showToast(mutableAttributedStringMessage: NSMutableAttributedString, image: UIImage?, backgroundColor: UIColor, topConstraintConstant: CGFloat = 16, isSingleLine: Bool = false, containerHeight: CGFloat = 64) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = backgroundColor
        toastContainer.layer.cornerRadius = 4
        toastContainer.clipsToBounds  = true
        toastContainer.alpha = 0
        
        let toastImageView = UIImageView()
        toastImageView.image = image
        toastImageView.clipsToBounds = true
        toastContainer.addSubview(toastImageView)
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.attributedText = mutableAttributedStringMessage
        toastLabel.setLineSpacing(lineSpacing: 4, lineHeightMultiple: 1, alignment: .left)
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        toastContainer.addSubview(toastLabel)
        
        self.view.addSubview(toastContainer)
        
        toastImageView.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        var imageViewTopConstraint: NSLayoutConstraint?
        if isSingleLine {
            imageViewTopConstraint = NSLayoutConstraint(item: toastImageView, attribute: .centerY, relatedBy: .equal, toItem: toastContainer, attribute: .centerY, multiplier: 1, constant: 0)
        } else {
            imageViewTopConstraint = NSLayoutConstraint(item: toastImageView, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 16)
        }
        let imageViewLeadingConstraint = NSLayoutConstraint(item: toastImageView, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 24)
        let imageViewWidthConstraint = NSLayoutConstraint(item: toastImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16)
        let imageViewHeightConstraint = NSLayoutConstraint(item: toastImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 16)
        toastContainer.addConstraints([imageViewLeadingConstraint, imageViewTopConstraint!, imageViewWidthConstraint, imageViewHeightConstraint])
        
        let labelMessageLeadingConstraint = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastImageView, attribute: .trailing, multiplier: 1, constant: 12)
        let labelMessageTrailingConstraint = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -24)
        let labelMessageBottomConstraint = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -16)
        let labelMessageTopConstraint = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 16)
        toastContainer.addConstraints([labelMessageLeadingConstraint, labelMessageTrailingConstraint, labelMessageBottomConstraint, labelMessageTopConstraint])
        
        let containerLeadingConstraint = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 16)
        let containerTrailingContraint = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -16)
        
        let containerTopConstraint = NSLayoutConstraint(item: toastContainer, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: topConstraintConstant)
        
        let containerHeightConstraint = NSLayoutConstraint(item: toastContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: containerHeight)
        self.view.addConstraints([containerLeadingConstraint, containerTrailingContraint, containerTopConstraint, containerHeightConstraint])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 3, delay: 2, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
