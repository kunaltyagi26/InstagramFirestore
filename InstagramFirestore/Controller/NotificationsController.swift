//
//  NotificationsController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit

// MARK: - Reuse Identifier

private let resuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: - Properties
    
    var noNotificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No notification is currently available. Please pull down to refresh."
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var notifications: [Notification] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarItems = tabBarController?.tabBar.items {
            let tabBarItem = tabBarItems[3]
            if tabBarItem.badgeValue == "●" {
                tabBarItem.badgeValue = nil
            }
        }
    }
    
    // API
    
    func fetchNotifications() {
        NotificationsController.activityIndicator = self.showActivityIndicator()
        NotificationService.fetchNotifications { result in
            DispatchQueue.main.async {
                if let refreshControl = self.refreshControl, refreshControl.isRefreshing {
                    self.refreshControl?.endRefreshing()
                }
                switch result {
                    case .success(let notifications):
                        let lastNotificationCount = self.notifications.count
                        if notifications.count > 0 {
                            self.tableView.backgroundView = nil
                            self.notifications = notifications
                            self.checkIfUserIsFollowed()
                            self.setBadgeValue(lastNotificationCount: lastNotificationCount, newNotificationCount: notifications.count)
                            self.showFinalizedActivityIndicator(for: NotificationsController.activityIndicator, withMessage: "Success", andTime: 0.5)
                        } else {
                            self.tableView.backgroundView = self.noNotificationsLabel
                            self.notifications = notifications
                            self.showFinalizedActivityIndicator(for: NotificationsController.activityIndicator, withMessage: "Success", andTime: 0.5)
                        }
                    case .failure(let error):
                        self.tableView.backgroundView = self.noNotificationsLabel
                        self.reloadData()
                        self.showFinalizedActivityIndicator(for: NotificationsController.activityIndicator, withMessage: error.localizedDescription)
                }
            }
        }
    }
    
    func checkIfUserIsFollowed() {
        self.notifications.forEach { (notification) in
            guard notification.type == .follow else { return }
            UserService.checkIfUserIsFollowed(uid: notification.uid) { (isFollowed) in
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self.notifications[index].isUserFollowed = isFollowed
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureTableView() {
        self.navigationItem.title = "Notifications"
        self.view.backgroundColor = UIColor(named: "background")
        self.navigationItem.backButtonTitle = ""
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: resuseIdentifier)
        tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
        let footerView = UIView()
        self.tableView.tableFooterView = footerView
        tableView.separatorStyle = .none
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tableView.alwaysBounceVertical = true
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    func setBadgeValue(lastNotificationCount: Int, newNotificationCount: Int) {
        if newNotificationCount > lastNotificationCount {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }

                if let selectedIndex = (topController as? MainTabController)?.selectedIndex, selectedIndex != 3 {
                    if let tabBarItems = self.tabBarController?.tabBar.items {
                        let tabBarItem = tabBarItems[3]
                        tabBarItem.badgeValue = "●"
                        tabBarItem.badgeColor = .clear
                        tabBarItem.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemRed], for: .normal)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func reloadData() {
        self.refreshControl?.beginRefreshing()
        fetchNotifications()
    }
    
    func moveToProfile(uid: String) {
        let profileLayout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: profileLayout)
        profileController.selectedUserId = uid
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(profileController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension NotificationsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier) as? NotificationCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.section])
        cell.delegate = self
        cell.infoLabel.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = view.backgroundColor
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - NotificationCellDelegate

extension NotificationsController: NotificationCellDelegate {
    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
        NotificationsController.activityIndicator = self.showActivityIndicator()
        UserService.followUser(uid: uid) { (error) in
            self.hideActivityIndicator(for: NotificationsController.activityIndicator)
            if let error = error {
                print(error)
            } else {
                cell.viewModel?.isUserFollowed = true
                NotificationService.uploadNotification(toUid: uid, type: .follow)
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String) {
        NotificationsController.activityIndicator = self.showActivityIndicator()
        UserService.unfollowUser(uid: uid) { (error) in
            self.hideActivityIndicator(for: NotificationsController.activityIndicator)
            if let error = error {
                print(error)
            } else {
                cell.viewModel?.isUserFollowed = false
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost post: String) {
        NotificationsController.activityIndicator = self.showActivityIndicator()
        PostService.fetchSelectedPost(postId: post) { (result) in
            self.hideActivityIndicator(for: NotificationsController.activityIndicator)
            switch result {
            case .success(let post):
                let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
                feedController.selectedPost = post
                feedController.hidesBottomBarWhenPushed = true
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(feedController, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewProfile uid: String) {
        moveToProfile(uid: uid)
    }
}

// MARK: - UITextViewDelegate

extension NotificationsController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let selectedUserId = URL.absoluteString
        moveToProfile(uid: selectedUserId)
        return false
    }
}
