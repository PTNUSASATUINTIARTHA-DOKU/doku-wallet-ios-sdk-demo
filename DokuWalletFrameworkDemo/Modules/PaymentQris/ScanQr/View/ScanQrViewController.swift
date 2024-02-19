//
//  ScanQrViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 15/12/23.
//

import UIKit
import AVFoundation

class ScanQrViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    var presenter: ScanQrPresenterProtocol?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultNavigation(title: "Payment QRIS", backAction: #selector(backButtonTapped), backType: .back)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCameraPermission()
        setupCameraQrScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    private func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        print("cameraAuthorizationStatus = \(cameraAuthorizationStatus)")
        if cameraAuthorizationStatus == .restricted || cameraAuthorizationStatus == .denied {
            self.alertCameraAccessNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.cameraView.bounds.width, height: self.cameraView.bounds.height)
    }
    
    private func alertCameraAccessNeeded() {
        DispatchQueue.main.async {
            self.presenter?.needCameraAccess()
        }
    }
    
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        return nil
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
   
}

extension ScanQrViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.isEmpty {
            return
        }
        self.captureSession.stopRunning()
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.supportedCodeTypes.contains(metadataObj.type) {
            if let qrString = metadataObj.stringValue  {
                presenter?.processQrString(qrString: qrString)
            }
        }
    }
}

extension ScanQrViewController: ScanQrViewProtocol {
    func setupCameraQrScan() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("camera not support")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                captureSession.startRunning()
                print("cannot capturesession")
                return
            }
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            print(error)
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraView.layer.addSublayer(videoPreviewLayer!)
        captureSession.startRunning()
    }
    
    func stopCamera() {
        if captureSession.isRunning {
            DispatchQueue.global().sync {
                self.captureSession.stopRunning()
            }
            
        }
    }
}
