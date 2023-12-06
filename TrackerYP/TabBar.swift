import UIKit

class TabBarViewController: UITabBarController {
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "reentry")
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whiteDay
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        let blueColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
        tabBar.tintColor = blueColor
//        tabBar.barTintColor = .gray
//        tabBar.backgroundColor = .white
//        
//        tabBar.layer.borderColor = UIColor.lightGray.cgColor
//        tabBar.layer.borderWidth = 1
//        tabBar.layer.masksToBounds = true
        
        let trackerStore = TrackerStore()
        let trackersViewController = TrackersViewController(trackerStore: trackerStore)
        let statisticViewController = StatisticViewController()
        let statisticViewModel = StatisticViewModel()
        statisticViewController.statisticViewModel = statisticViewModel
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: (NSLocalizedString("title.tracker", comment: "")),
            image: UIImage(systemName: "smallcircle.filled.circle.fill"),
            selectedImage: nil
        )
        statisticViewController.tabBarItem = UITabBarItem(
            title: (NSLocalizedString("title.statistics", comment: "")),
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        let controllers = [trackersViewController, statisticViewController]
        
        viewControllers = controllers
    }
}
