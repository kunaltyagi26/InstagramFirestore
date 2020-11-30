//
//  NotificationsController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit

class NotificationsController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"
        self.view.backgroundColor = UIColor(named: "background")?.withAlphaComponent(0.4)
        self.showLogoutButton()
        self.showMessageButton()
    }
    
    // MARK: - Helpers
}
