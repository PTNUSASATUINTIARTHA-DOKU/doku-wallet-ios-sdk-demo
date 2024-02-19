//
//  ScanQrPresenter.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import DokuWalletSDK

class ScanQrPresenter: ScanQrPresenterProtocol {
    
    var view: ScanQrViewProtocol?
    var router: ScanQrRouterProtocol?
    var interactor: ScanQrInteractorProtocol?
    var qrString = ""
    
    init (view: ScanQrViewProtocol, router: ScanQrRouterProtocol, interactor: ScanQrInteractorProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    func processQrString(qrString: String) {
        view?.showActivityIndicator()
        self.qrString = qrString
        interactor?.processQrString(qrString: qrString)
    }
    
    func needCameraAccess() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        let alert = UIAlertController(title: NSLocalizedString("Pemberitahuan", comment: ""), message: "Butuh Akses Kamera untuk Scan QR", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let OKAction = UIAlertAction(title: "Allow Camera", style: .default, handler: { (_) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        alert.preferredAction = OKAction
        
        router?.showAlert(alert: alert)
    }
    
}

extension ScanQrPresenter: ScanQrInteractorOutputProtocol {
    func processDecodeQrisResponse(result: Result<DecodeQrisResponse, WalletError>) {
        view?.hideActivityIndicator()
        switch result {
        case .success(let decodeQrisResponse):
            if (decodeQrisResponse.responseCode == SnapResponseCode.successDecodeQris) {
                if(decodeQrisResponse.additionalInfo?.pointOfInitiationMethod == QrisPointOfInitiationMethod.qrisStatic) {
                    // transaction amount not provided --> need to input transaction amount
                    router?.goToQrisInputAmount(dataResponse: decodeQrisResponse, qrContent: self.qrString)
                } else if(decodeQrisResponse.additionalInfo?.pointOfInitiationMethod == QrisPointOfInitiationMethod.qrisDynamic) {
                    // transaction amount provided --> no need to input transaction amount
                    router?.goToQrisConfirmation(dataResponse: decodeQrisResponse, qrContent: self.qrString)
                }
            } else {
                view?.showCommonError(title: "Pemberitahuan", detail: "Failed", action: {self.view?.setupCameraQrScan()})
            }
        case .failure(let error):
            
            var detail = ""
            switch error {
            case .apiError(_, let responseMessage, _):
                detail = responseMessage
            case .networkError(let type, _):
                detail = type.rawValue
            @unknown default:
                detail = error.localizedDescription
            }
            view?.showCommonError(title: "Pemberitahuan", detail: detail, action: {self.view?.setupCameraQrScan()})
        }
    }
}
