import UIKit

class TabBarViewController: UITabBarController {
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blueColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
        tabBar.tintColor = blueColor
        tabBar.barTintColor = .gray
        tabBar.backgroundColor = .white
        
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
        
        let trackersViewController = TrackersViewController()
        let statisticViewController = StatisticViewController()
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "smallcircle.filled.circle.fill"),
            selectedImage: nil
        )
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        let controllers = [trackersViewController, statisticViewController]
        
        viewControllers = controllers
    }
}
