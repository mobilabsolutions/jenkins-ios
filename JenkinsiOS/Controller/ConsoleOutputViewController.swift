//
//  ConsoleOutputViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 11.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import UIKit
import WebKit

class ConsoleOutputViewController: UIViewController {
    var request: URLRequest?

    private var consoleWebView: WKWebView?
    private var headerView: UIView?
    private var directionButton: UIButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = .all
        }

        consoleWebView = WKWebView(frame: view.frame, configuration: configuration)
        consoleWebView?.navigationDelegate = self

        title = "Logs"
        view.backgroundColor = Constants.UI.backgroundColor

        addHeaderView()
        addConsoleWebViewConstraints()
        addDirectionButton()

        reload()
    }

    private func addHeaderView() {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Logs"
        titleLabel.textColor = Constants.UI.greyBlue

        separator.backgroundColor = Constants.UI.paleGreyColor

        header.backgroundColor = .white

        header.addSubview(titleLabel)
        header.addSubview(separator)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[titleLabel]-|", options: [], metrics: [:], views: ["titleLabel": titleLabel]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator]|", options: [], metrics: [:], views: ["separator": separator]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[titleLabel]-(15)-[separator(==1)]|", options: [], metrics: [:], views: ["titleLabel": titleLabel, "separator": separator]))
        header.layer.cornerRadius = 5
        header.layer.masksToBounds = true

        view.addSubview(header)

        header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        header.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
        header.heightAnchor.constraint(equalToConstant: 50).isActive = true

        header.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        header.layer.borderWidth = 0.5

        headerView = header
    }

    private func addConsoleWebViewConstraints() {
        guard let consoleWebView = self.consoleWebView else { return }
        view.addSubview(consoleWebView)
        consoleWebView.translatesAutoresizingMaskIntoConstraints = false
        consoleWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -65).isActive = true
        consoleWebView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        consoleWebView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true

        if let headerView = headerView {
            consoleWebView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        } else {
            consoleWebView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        }

        consoleWebView.scrollView.contentInset = UIEdgeInsets(top: 20 + (navigationController?.navigationBar.frame.height ?? 0), left: 0, bottom: 0, right: 0)
        consoleWebView.scrollView.layer.cornerRadius = 5
        consoleWebView.scrollView.layer.borderColor = Constants.UI.paleGreyColor.cgColor
        consoleWebView.scrollView.layer.borderWidth = 1
        consoleWebView.scrollView.layer.masksToBounds = true
    }

    private func addIndicatorView() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }

    private func replaceIndicatorViewWithReload() {
        if let activityIndicator = navigationItem.rightBarButtonItem?.customView as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
        }
        let reloadButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        navigationItem.rightBarButtonItem = reloadButtonItem
    }

    @objc private func reload() {
        guard let request = request
        else { return }

        addIndicatorView()
        enableDirectionButton(enable: false)
        consoleWebView?.load(request)
    }

    private func addDirectionButton() {
        guard let consoleWebView = self.consoleWebView else { return }

        directionButton.addTarget(self, action: #selector(scrollToBottom), for: .touchUpInside)
        directionButton.setImage(UIImage(named: "downArrow"), for: .normal)
        enableDirectionButton(enable: false)

        view.addSubview(directionButton)

        directionButton.translatesAutoresizingMaskIntoConstraints = false

        directionButton.bottomAnchor.constraint(equalTo: consoleWebView.bottomAnchor, constant: -20).isActive = true
        directionButton.rightAnchor.constraint(equalTo: consoleWebView.rightAnchor, constant: -16).isActive = true
        directionButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        directionButton.widthAnchor.constraint(lessThanOrEqualTo: directionButton.heightAnchor).isActive = true
    }

    private func enableDirectionButton(enable: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
            [unowned self] in
            self.directionButton.alpha = enable ? 1.0 : 0.0
        }, completion: { _ in
            self.directionButton.isHidden = !enable
        })
    }

    @objc private func scrollToBottom() {
        guard let consoleWebView = self.consoleWebView else { return }

        let y = consoleWebView.scrollView.contentSize.height - consoleWebView.frame.height
        consoleWebView.scrollView.scrollRectToVisible(
            CGRect(x: 0.0, y: y >= 0 ? y : 0.0, width: consoleWebView.frame.width, height: consoleWebView.frame.height),
            animated: true
        )
    }
}

// MARK: - Webview delegate

extension ConsoleOutputViewController: WKNavigationDelegate {
    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        replaceIndicatorViewWithReload()
        enableDirectionButton(enable: true)
    }

    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
