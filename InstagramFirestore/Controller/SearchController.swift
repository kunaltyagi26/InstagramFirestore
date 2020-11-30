//
//  SearchController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit
import JGProgressHUD

// MARK: - Reuse-Identifiers

private let searchCellReuseIdentifier = "searchCell"

class SearchController: UITableViewController {
    
    // MARK: - Properties
    
    var users: [User]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var activityIndicator = JGProgressHUD(automaticStyle: ())
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = self.showActivityIndicator()
        configureView()
    }
    
    // MARK: - Helpers
    
    func configureView() {
        self.navigationItem.title = "Search"
        self.view.backgroundColor = UIColor(named: "background")
        self.tableView.backgroundColor = UIColor(named: "background")
        self.showLogoutButton()
        self.showMessageButton()
        configureTableView()
        fetchUsers()
    }
    
    func configureTableView() {
        self.tableView.register(UserCell.self, forCellReuseIdentifier: searchCellReuseIdentifier)
        let footerView = UIView()
        self.tableView.tableFooterView = footerView
        tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func fetchUsers() {
        UserService.fetchUsers { (result) in
            switch result {
            case .success(let users):
                self.showFinalizedActivityIndicator(for: self.activityIndicator, withMessage: "Success", andTime: 0.5)
                print(users)
                self.users = users
            case .failure(let error):
                print(error)
                self.showFinalizedActivityIndicator(for: self.activityIndicator, withMessage: error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSourceDelegate

extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: searchCellReuseIdentifier) as? UserCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
    
        if let user = users?[indexPath.row] {
            cell.configureData(user: user)
        }
        
        return cell
    }
}
