//
//  OnBoardingContainerViewController.swift
//  JenkinsiOS
//
//  Created by Robert on 21.08.18.
//  Copyright © 2018 MobiLab Solutions. All rights reserved.
//

import UIKit

protocol OnBoardingViewControllerDelegate {
    func didFinishOnboarding(skipped: Bool)
}

class OnBoardingContainerViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    @IBOutlet var container: UIView!
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var pageControl: UIPageControl!

    var options: [OnBoardingOption] = []
    var delegate: OnBoardingViewControllerDelegate?

    private var pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                          navigationOrientation: .horizontal, options: nil)
    private lazy var onboardingViewControllers = options.lazy.map(onboardingViewController)

    private var pendingIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        addPageViewController()
        setupControls()
    }

    private func addPageViewController() {
        addChild(pageViewController)
        pageViewController.view.frame = container.bounds
        container.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        if let first = onboardingViewControllers.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }

        pageViewController.dataSource = self
        pageViewController.delegate = self
    }

    private func setupControls() {
        pageControl.numberOfPages = options.count
        pageControl.addTarget(self, action: #selector(updateShownPage), for: .valueChanged)

        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
    }

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnBoardingViewController,
            let option = current.option,
            let index = options.index(of: option)
        else { return nil }

        if index == onboardingViewControllers.indices.first {
            return nil
        }

        return onboardingViewControllers[onboardingViewControllers.index(before: index)]
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnBoardingViewController,
            let option = current.option,
            let index = options.index(of: option)
        else { return nil }

        if index == onboardingViewControllers.indices.last {
            return nil
        }

        return onboardingViewControllers[onboardingViewControllers.index(after: index)]
    }

    func pageViewController(_: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? OnBoardingViewController, let option = viewController.option
        else { return }
        pendingIndex = options.index(of: option)
    }

    func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let pending = pendingIndex
        else { return }

        pageControl.currentPage = pending
        skipButton.isHidden = !options[pending].canSkip

        pendingIndex = nil
    }

    private func onboardingViewController(option: OnBoardingOption) -> OnBoardingViewController {
        let viewController = OnBoardingViewController(nibName: "OnBoardingViewController", bundle: .main)
        viewController.option = option
        return viewController
    }

    @objc private func nextPage() {
        if pageControl.currentPage + 1 < options.count {
            pageControl.currentPage = pageControl.currentPage + 1
            updateShownPage()
        } else {
            delegate?.didFinishOnboarding(skipped: false)
        }
    }

    @objc private func skip() {
        delegate?.didFinishOnboarding(skipped: true)
    }

    @objc private func updateShownPage() {
        skipButton.isHidden = !options[pageControl.currentPage].canSkip
        pageViewController.setViewControllers([onboardingViewControllers[pageControl.currentPage]], direction: .forward, animated: true, completion: nil)
    }
}
