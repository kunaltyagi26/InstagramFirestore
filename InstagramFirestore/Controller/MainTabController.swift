//
//  MainTabController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit
import Firebase
import YPImagePicker

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    var imageSelectorController = YPImagePicker()
    var user: User? {
        didSet {
            profileController.user = user
        }
    }
    var profileController = ProfileController()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        fetchUser()
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
        
        imageSelectorController = createImageSelectorController()
        didFinishPickingImage(imageSelectorController)
        
        let notificationsController = NotificationsController()
        let notificationsNavigationController = templateNavigationController(unselectedImage: "heart", selectedImage: "heart.fill", rootViewController: notificationsController)
                
        let profileLayout = UICollectionViewFlowLayout()
        profileController = ProfileController(collectionViewLayout: profileLayout)
        let profileNavigationController = templateNavigationController(unselectedImage: "person", selectedImage: "person.fill", rootViewController: profileController)
        
        self.viewControllers = [feedNavigationController, searchNavigationController, imageSelectorController, notificationsNavigationController, profileNavigationController]
        
        self.selectedIndex = 0
        addSwipeFeature()
        self.tabBar.tintColor = .label
        self.tabBar.barTintColor = UIColor(named: "background")?.withAlphaComponent(0.1)
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(uid: uid) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func templateNavigationController(unselectedImage: String, selectedImage: String, rootViewController: UIViewController)-> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        if rootViewController.isKind(of: NotificationsController.self) {
            navigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: unselectedImage), selectedImage: UIImage(systemName: selectedImage)?.withRenderingMode(.alwaysOriginal).withTintColor(.systemRed))
        } else {
            navigationController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: unselectedImage), selectedImage: UIImage(systemName: selectedImage))
        }
        navigationController.navigationBar.tintColor = .label
        navigationController.navigationBar.barTintColor = UIColor(named: "background")?.withAlphaComponent(0.1)
        
        return navigationController
    }
    
    func createImageSelectorController()-> YPImagePicker {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.shouldSaveNewPicturesToAlbum = true
        config.startOnScreen = .library
        config.screens = [.library]
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.library.maxNumberOfItems = 1
        config.hidesCancelButton = true
        config.colors.libraryScreenBackgroundColor = UIColor(named: "background") ?? .systemBackground
        config.colors.filterBackgroundColor = UIColor(named: "background") ?? .systemBackground
        
        let imageSelectorController = YPImagePicker(configuration: config)
        imageSelectorController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus.circle"), selectedImage: UIImage(systemName: "plus.circle.fill"))
        return imageSelectorController
    }
    
    func didFinishPickingImage(_ picker: YPImagePicker) {
        picker.didFinishPicking { items, cancelled in
            DispatchQueue.main.async {
                guard let selectedImage = items.singlePhoto?.image else { return }
                let uploadPostController = UploadPostController()
                uploadPostController.selectedImage = selectedImage
                uploadPostController.user = self.user
                self.imageSelectorController.pushViewController(uploadPostController, animated: true)
            }
        }
    }
    
    func addSwipeFeature() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    func set(selectedIndex index : Int) {
       _ = self.tabBarController(self, shouldSelect: self.viewControllers![index])
    }
    
    // MARK: - Actions
    
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

// MARK: - UITabBarControllerDelegate Extension

extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view, fromView != toView else {
            return false
        }

        UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        
        return true
    }
}
