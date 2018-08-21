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

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var options: [OnBoardingOption] = []
    var delegate: OnBoardingViewControllerDelegate?
    
    private var pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                          navigationOrientation: .horizontal, options: nil)
    private lazy var onboardingViewControllers = options.lazy.map(onboardingViewController)
    
    private var pendingIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPageViewController()
        setupControls()
    }
    
    private func addPageViewController() {
        self.addChildViewController(pageViewController)
        pageViewController.view.frame = container.bounds
        self.container.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        if let first = onboardingViewControllers.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    private func setupControls() {
        self.pageControl.numberOfPages = options.count
        self.pageControl.addTarget(self, action: #selector(updateShownPage), for: .valueChanged)
        
        self.nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        self.skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnBoardingViewController,
            let option = current.option,
            let index = options.index(of: option)
            else { return nil }
        
        if index == onboardingViewControllers.indices.first {
            return nil
        }
        
        return onboardingViewControllers[onboardingViewControllers.index(before: index)]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? OnBoardingViewController,
            let option = current.option,
            let index = options.index(of: option)
            else { return nil }
        
        if index == onboardingViewControllers.indices.last {
            return nil
        }
        
        return onboardingViewControllers[onboardingViewControllers.index(after: index)]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? OnBoardingViewController, let option = viewController.option
            else { return }
        pendingIndex = options.index(of: option)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let pending = pendingIndex
            else { return }
        
        self.pageControl.currentPage = pending
        self.skipButton.isHidden = !self.options[pending].canSkip
        
        pendingIndex = nil
    }
    
    private func onboardingViewController(option: OnBoardingOption) -> OnBoardingViewController {
        let viewController = OnBoardingViewController(nibName: "OnBoardingViewController", bundle: .main)
        viewController.option = option
        return viewController
    }
    
    @objc private func nextPage() {
        if pageControl.currentPage + 1 < self.options.count {
            pageControl.currentPage = pageControl.currentPage + 1
            updateShownPage()
        }
        else {
            delegate?.didFinishOnboarding(skipped: false)
        }
    }
    
    @objc private func skip() {
        delegate?.didFinishOnboarding(skipped: true)
    }
    
    @objc private func updateShownPage() {
        self.skipButton.isHidden = !self.options[pageControl.currentPage].canSkip
        pageViewController.setViewControllers([onboardingViewControllers[pageControl.currentPage]], direction: .forward, animated: true, completion: nil)
    }

}
