//
//  OnBoardingHandler.swift
//  JenkinsiOS
//
//  Created by Robert on 21.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol OnBoardingDelegate {
    func didFinishOnboarding(didAddAccount: Bool)
}

class OnBoardingHandler: OnBoardingViewControllerDelegate {
    private(set) lazy var options: [OnBoardingOption] = {
        [
            OnBoardingOption(title: "Monitor your Server", subtitle: "View your server's data including jobs, builds, users and nodes",
                             imageName: "ic-onboarding-1", canSkip: true),
            OnBoardingOption(title: "Trigger Builds", subtitle: "Trigger a build with or without parameters whenever or whereever you want",
                             imageName: "ic-onboarding-2", canSkip: true),
            OnBoardingOption(title: "Download Artifacts", subtitle: "Download the artifacts your build created at any time",
                             imageName: "ic-onboarding-3", canSkip: false),
        ]
    }()

    private var delegate: OnBoardingDelegate?
    private weak var presentedViewController: UINavigationController?

    func shouldStartOnBoarding() -> Bool {
        return ApplicationUserManager.manager.applicationUser.timesOpenedApp <= 1 && AccountManager.manager.accounts.isEmpty
    }

    func startOnBoarding(on viewController: UIViewController, delegate: OnBoardingDelegate) {
        let container = OnBoardingContainerViewController(nibName: "OnBoardingContainerViewController", bundle: .main)
        container.options = options
        container.delegate = self
        self.delegate = delegate

        let navigationController = UINavigationController(rootViewController: container)
        navigationController.isNavigationBarHidden = true

        viewController.present(navigationController, animated: false, completion: nil)
        presentedViewController = navigationController
    }

    func shouldShowAccountCreationViewController() -> Bool {
        return AccountManager.manager.accounts.isEmpty
    }

    func didFinishOnboarding(skipped _: Bool) {
        guard shouldShowAccountCreationViewController(), let navigationController = self.presentedViewController, let accountViewController = accountCreationViewController()
        else { closeViewController(didAddAccount: false); return }

        showAccountCreationViewController(viewController: accountViewController, in: navigationController)
    }

    func showAccountCreationViewController(on navigationController: UINavigationController, delegate: OnBoardingDelegate) {
        guard let accountCreationViewController = accountCreationViewController()
        else { return }

        presentedViewController = navigationController
        self.delegate = delegate
        showAccountCreationViewController(viewController: accountCreationViewController, in: navigationController)
    }

    private func showAccountCreationViewController(viewController: AddAccountContainerViewController,
                                                   in navigationController: UINavigationController) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.isNavigationBarHidden = false
        navigationController.pushViewController(viewController, animated: true)
    }

    private func accountCreationViewController() -> AddAccountContainerViewController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let accountViewController = appDelegate.getViewController(name: "AddAccountContainerViewController") as? AddAccountContainerViewController
        else { return nil }

        accountViewController.delegate = self
        accountViewController.addingFirstAccount = true
        accountViewController.title = "Add Account"
        accountViewController.navigationItem.hidesBackButton = true
        return accountViewController
    }

    private func closeViewController(didAddAccount: Bool) {
        presentedViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        presentedViewController = nil
        delegate?.didFinishOnboarding(didAddAccount: didAddAccount)
    }
}

extension OnBoardingHandler: AddAccountTableViewControllerDelegate {
    func didDeleteAccount(account _: Account) {
        fatalError("You should not be able to delete an account from the onboarding flow")
    }

    func didEditAccount(account: Account, oldAccount _: Account?, useAsCurrentAccount: Bool) {
        if var accountProvidable = presentedViewController?.presentingViewController as? AccountProvidable {
            accountProvidable.account = account
        }

        let accountCreatedViewController = AccountCreatedViewController(nibName: "AccountCreatedViewController", bundle: .main)
        accountCreatedViewController.delegate = self
        presentedViewController?.pushViewController(accountCreatedViewController, animated: true)
    }
}

extension OnBoardingHandler: AccountCreatedViewControllerDelegate {
    func doneButtonPressed() {
        closeViewController(didAddAccount: true)
    }
}
