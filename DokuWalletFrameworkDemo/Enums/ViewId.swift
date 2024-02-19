//
//  ViewId.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 08/11/23.
//

import Foundation

enum ViewId: StoryboardViewControllerProtocol {
    
    case menu
    case bottomPopUpMessage
    case accountCreation
    case verifyOtp
    case webview
    case generateQrisInputForm
    case qrDisplay
    case resultMessage
    case scanQr
    case qrisInputAmount
    case qrisAmountConfirmation
    case qrisReceipt
    
    var storyboard: String {
        switch self {
        case .menu:
            return "MenuStoryboard"
        case .bottomPopUpMessage:
            return "BottomPopUpMessageStoryboard"
        case .accountCreation:
            return "AccountCreationStoryboard"
        case .verifyOtp:
            return "VerifyOtpStoryboard"
        case .webview:
            return "WebviewStoryboard"
        case .generateQrisInputForm:
            return "GenerateQrisInputFormStoryboard"
        case .qrDisplay:
            return "QrDisplayStoryboard"
        case .resultMessage:
            return "ResultMessageStoryboard"
        case .scanQr:
            return "ScanQrStoryboard"
        case .qrisInputAmount:
            return "QrisInputAmountStoryboard"
        case .qrisAmountConfirmation:
            return "QrisAmountConfirmationStoryboard"
        case .qrisReceipt:
            return "QrisReceiptStoryboard"
        }
    }
    
    var viewController: String {
        switch self {
        case .menu:
            return "MenuViewController"
        case .bottomPopUpMessage:
            return "BottomPopUpMessageViewController"
        case .accountCreation:
            return "AccountCreationViewController"
        case .verifyOtp:
            return "VerifyOtpViewController"
        case .webview:
            return "WebviewViewController"
        case .generateQrisInputForm:
            return "GenerateQrisInputFormViewController"
        case .qrDisplay:
            return "QrDisplayViewController"
        case .resultMessage:
            return "ResultMessageViewController"
        case .scanQr:
            return "ScanQrViewController"
        case .qrisInputAmount:
            return "QrisInputAmountViewController"
        case .qrisAmountConfirmation:
            return "QrisAmountConfirmationViewController"
        case .qrisReceipt:
            return "QrisReceiptViewController"
        }
    }
}
