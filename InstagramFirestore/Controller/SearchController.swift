//
//  SearchController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit

class SearchController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        self.view.backgroundColor = .systemBackground
        self.showLogoutButton()
    }
    
    // MARK: - Helpers
}
