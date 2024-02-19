import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private lazy var pages: [OnboardingPageViewController] = {
        let firstPage = OnboardingPageViewController()
        firstPage.backgroundImage.image = UIImage(named: "OnboardingBlue")
        firstPage.label.text = NSLocalizedString("onePageOnboarding", comment: "")
        firstPage.label.textColor = .blackDay
        let secondPage = OnboardingPageViewController()
        secondPage.backgroundImage.image = UIImage(named: "OnboardingPink")
        secondPage.label.text = NSLocalizedString("twoPageOnboarding", comment: "")
        secondPage.label.textColor = .blackDay
        return [firstPage, secondPage]
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blackDay
        button.setTitleColor(.blackNight, for: .normal)
        button.setTitle(NSLocalizedString("buttonOnboarding", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .blackDay
        return control
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        let tabBar = TabBarViewController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
}

// MARK: - Extensions
extension OnboardingViewController {
    
    func configureView() {
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
        [pageControl, enterButton].forEach { view.addSubview($0) }
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: enterButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            enterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            enterButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! OnboardingPageViewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return pages.last }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! OnboardingPageViewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return pages.first }
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentViewController) else { return }
        pageControl.currentPage = currentIndex
    }
}
