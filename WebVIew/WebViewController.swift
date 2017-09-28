//
//  WebViewController.swift
//  WKWebViewSample
//
//  Created by Xing He on 9/22/17.
//  Copyright © 2017 Xing He. All rights reserved.
//

import UIKit
import WebKit

let webViewProcessPool = WKProcessPool()
var webViewEstimatedProgressContext = 0

class WebViewController: UIViewController {

    var webView: WKWebView!
    var progressView: UIProgressView!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        // All webviews use the same process pool to share the cookies
        webConfiguration.processPool = webViewProcessPool
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = Bundle.main.path(forResource: "sample.html", ofType: nil)!
        let localHTMLURL = URL(fileURLWithPath: myURL)
        webView.loadFileURL(localHTMLURL, allowingReadAccessTo: localHTMLURL)

        setupWebView()
        setupProgressView()
    }

    func setupWebView() {
        webView.allowsBackForwardNavigationGestures = true
    }

    func setupProgressView() {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.alpha = 0
        progressView.trackTintColor = .white
        webView.addSubview(progressView)
        self.progressView = progressView

        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: webView.leftAnchor),
            progressView.rightAnchor.constraint(equalTo: webView.rightAnchor),
            progressView.topAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.topAnchor)
        ])

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.initial, .new], context: &webViewEstimatedProgressContext)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress", context: &webViewEstimatedProgressContext)
    }

    // MARK: KVO

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &webViewEstimatedProgressContext {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            progressView.alpha = 1

            // Load Complete
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.4, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finished) in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        } else {
            // Always call super
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: WKUIDelegate

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // REQUIRED: When user click on `target="_blank"` link, just tell the webview to load the request
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // REQUIRED: Implement `alert()`
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // REQUIRED: Implement `confirm()`
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // REQUIRED: Implement `prompt()`
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(nil)
        }))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleFailingURL(error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleFailingURL(error: error)
    }

    private func handleFailingURL(error: Error) {
        let error = error as NSError
        // Handling URL Scheme
        if let failingURLString = error.userInfo[NSURLErrorFailingURLStringErrorKey] as? String {
            if let failingURL = URL(string: failingURLString) {
                UIApplication.shared.open(failingURL, options: [:], completionHandler: { (finished) in
                    if finished {
                        print("Open \(failingURLString) Success.")
                        return
                    }
                })
            }
        }
    }
}

