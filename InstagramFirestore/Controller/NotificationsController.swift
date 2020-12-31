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
    
    var notifications: [Notification] = []
    
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
        NotificationService.fetchNotifications2 { result in
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
                            self.setBadgeValue(lastNotificationCount: lastNotificationCount, newNotificationCount: notifications.count)
                            self.tableView.reloadData()
                            self.showFinalizedActivityIndicator(for: NotificationsController.activityIndicator, withMessage: "Success", andTime: 0.5)
                        } else {
                            self.tableView.backgroundView = self.noNotificationsLabel
                            self.tableView.reloadData()
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
    
    // MARK: - Helpers
    
    func configureTableView() {
        self.navigationItem.title = "Notifications"
        self.view.backgroundColor = UIColor(named: "background")
        
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
}

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier) as? NotificationCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        return cell
    }
}
