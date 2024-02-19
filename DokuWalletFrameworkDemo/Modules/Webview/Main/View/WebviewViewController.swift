//
//  WebviewViewController.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 13/11/23.
//

import UIKit
import WebKit

class WebviewViewController: UIViewController {
    
    var presenter: WebviewPresenterProtocol?
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var loadSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        presenter?.loadData()
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"

        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webview.configuration.userContentController.addUserScript(script)
        
    }
    
    @objc func backButtonTapped() {
        presenter?.back()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.loadSpinner.stopAnimating()
        self.loadSpinner.isHidden = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            let urlString = "\(key)"
            print("webview url: \(urlString)")
            presenter?.detectUrl(urlString: urlString)
        }
    }
}

extension WebviewViewController: WebviewViewProtocol {
    
    func loadData(webviewConfig: WebviewConfig) {
        if(webviewConfig.observeValue) {
            self.webview.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        }
        setupDefaultNavigation(title: "Account Creation", backAction: #selector(backButtonTapped), backType: webviewConfig.backType)
        self.loadAddress(webviewConfig: webviewConfig)
    }
    
    private func loadAddress(webviewConfig: WebviewConfig) {
        
        guard let url = URL(string: webviewConfig.url) else {
            loadSpinner.stopAnimating()
            loadSpinner.isHidden = true
            print("uri not valid")
            return
        }
        
        let urlRequest = NSMutableURLRequest(url: url)
        if(webviewConfig.httpMethod == .POST) {
            urlRequest.httpMethod = webviewConfig.httpMethod.rawValue
            urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let post: String = webviewConfig.httpBody
            let postData: Data = post.data(using: String.Encoding.ascii, allowLossyConversion: true)!
            urlRequest.httpBody = postData
            
        }
        webview.load(urlRequest as URLRequest)
    }
    
    func loadBlankScreen() {
        webview.loadHTMLString("", baseURL: nil)
    }
}

extension WebviewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start to load")
        loadSpinner.isHidden = false
        loadSpinner.startAnimating()
        
        if let url = webView.url?.absoluteString{
            print("webview url start = \(url)")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finished load")
        loadSpinner.stopAnimating()
        loadSpinner.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("failed load = \(error.localizedDescription)")
        loadSpinner.stopAnimating()
        loadSpinner.isHidden = true
    }
}
