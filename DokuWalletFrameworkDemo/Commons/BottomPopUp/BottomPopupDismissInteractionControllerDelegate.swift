//
//  BottomPopupDismissInteractionControllerDelegate.swift
//  WalletSDK
//
//  Created by DOKU on 18/05/22.
//

import UIKit

protocol BottomPopupDismissInteractionControllerDelegate: class {
    func dismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat)
}

class BottomPopupDismissInteractionController: UIPercentDrivenInteractiveTransition {
    
    private let kMinPercentOfVisiblePartToCompleteAnimation = CGFloat(0.5)
    private let kSwipeDownThreshold = CGFloat(1000)
    private weak var presentedViewController: BottomPresentableViewController?
    private weak var transitioningDelegate: BottomPopupTransitionHandler?
    weak var delegate: BottomPopupDismissInteractionControllerDelegate?
    
    private var currentPercent: CGFloat = 0 {
        didSet {
            delegate?.dismissInteractionPercentChanged(from: oldValue, to: currentPercent)
        }
    }
    
    init(presentedViewController: BottomPresentableViewController?) {
        self.presentedViewController = presentedViewController
        self.transitioningDelegate = presentedViewController?.transitioningDelegate as? BottomPopupTransitionHandler
        super.init()
        preparePanGesture(in: presentedViewController?.view)
    }
    
    private func finishAnimation(withVelocity velocity: CGPoint) {
        if currentPercent > kMinPercentOfVisiblePartToCompleteAnimation || velocity.y > kSwipeDownThreshold {
            finish()
        } else {
            cancel()
        }
    }
    
    private func preparePanGesture(in view: UIView?) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        presentedViewController?.view?.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let translationY = pan.translation(in: presentedViewController?.view).y
        currentPercent = min(max(translationY/(presentedViewController?.view.frame.size.height ?? 0), 0), 1)
        
        switch pan.state {
        case .began:
            transitioningDelegate?.isInteractiveDismissStarted = true
            presentedViewController?.dismiss(animated: true, completion: nil)
        case .changed:
            update(currentPercent)
        default:
            let velocity = pan.velocity(in: presentedViewController?.view)
            transitioningDelegate?.isInteractiveDismissStarted = false
            finishAnimation(withVelocity: velocity)
        }
    }
}

