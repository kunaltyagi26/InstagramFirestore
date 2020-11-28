//
//  MainTabController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit

class MainTabController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureViewControllers()
    }
    
    // MARK: - Helpers
    
    func configureViewControllers() {
        self.view.backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        let feedController = FeedController(collectionViewLayout: layout)
        let feedNavigationController = templateNavigationController(unselectedImage: "house", selectedImage: "house.fill", rootViewController: feedController)
        
        let searchController = SearchController()
        let searchNavigationController = templateNavigationController(unselectedImage: "magnifyingglass", selectedImage: "magnifyingglass", rootViewController: searchController)
    
        let imageSelectorController = ImageSelectorController()
        let imageSelectorNavigationController = templateNavigationController(unselectedImage: "plus.circle", selectedImage: "plus.circle.fill", rootViewController: imageSelectorController)
        
        let notificationsController = NotificationsController()
        let notificationsNavigationController = templateNavigationController(unselectedImage: "heart", selectedImage: "heart.fill", rootViewController: notificationsController)
                
        let profileController = ProfileController()
        let profileNavigationController = templateNavigationController(unselectedImage: "person", selectedImage: "person.fill", rootViewController: profileController)
        
        self.viewControllers = [feedNavigationController, searchNavigationController, imageSelectorNavigationController, notificationsNavigationController, profileNavigationController]
        
        self.selectedIndex = 0
        addSwipeFeature()
        self.tabBar.tintColor = .label
        self.tabBar.barTintColor = UIColor(named: "background")
    }
    
    func templateNavigationController(unselectedImage: String, selectedImage: String, rootViewController: UIViewController)-> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        if rootViewController.isKind(of: NotificationsController.self) {
            navigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: unselectedImage), selectedImage: UIImage(systemName: selectedImage)?.withRenderingMode(.alwaysOriginal).withTintColor(.systemRed))
        } else {
            navigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: unselectedImage), selectedImage: UIImage(systemName: selectedImage))
        }
        navigationController.navigationBar.tintColor = .label
        navigationController.navigationBar.barTintColor = UIColor(named: "background")
        
        return navigationController
    }
    
    func addSwipeFeature() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left && self.selectedIndex < 4 {
            if let fromView = self.selectedViewController?.view, let toView = self.viewControllers?[self.selectedIndex + 1].view {
                UIView.transition(from: fromView, to: toView, duration: 0.3, options: .transitionCrossDissolve) { (finished) in
                    if finished {
                        self.selectedIndex += 1
                    }
                }
            }
        }
        if sender.direction == .right && self.selectedIndex > 0 {
            if let fromView = self.selectedViewController?.view, let toView = self.viewControllers?[self.selectedIndex - 1].view {
                UIView.transition(from: fromView, to: toView, duration: 0.3, options: .transitionCrossDissolve) { (finished) in
                    if finished {
                        self.selectedIndex -= 1
                    }
                }
            }
        }
    }
}

extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view, fromView != toView else {
            return false
        }

        UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        return true
    }
}
