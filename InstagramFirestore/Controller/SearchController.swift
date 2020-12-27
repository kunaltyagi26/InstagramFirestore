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
    
    private var users: [User]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var filteredUsers = [User]()
    private var inSearchMode: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? false)
    }
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SearchController.activityIndicator = self.showActivityIndicator()
        fetchUsers()
    }
    
    // MARK: - Helpers
    
    func configureView() {
        self.navigationItem.title = "Search"
        self.navigationItem.backButtonTitle = ""
        self.view.backgroundColor = UIColor(named: "background")
        self.tableView.backgroundColor = UIColor(named: "background")
        configureTableView()
        configureSearchController()
    }
    
    func configureTableView() {
        self.tableView.register(UserCell.self, forCellReuseIdentifier: searchCellReuseIdentifier)
        let footerView = UIView()
        self.tableView.tableFooterView = footerView
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    func configureSearchController() {
        self.navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    // MARK: - API
    
    func fetchUsers() {
        UserService.fetchUsers { (result) in
            switch result {
            case .success(let users):
                self.users = users
                self.showFinalizedActivityIndicator(for: SearchController.activityIndicator, withMessage: "Success", andTime: 0.5)
            case .failure(let error):
                self.showFinalizedActivityIndicator(for: SearchController.activityIndicator, withMessage: error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        inSearchMode ? filteredUsers.count : users?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: searchCellReuseIdentifier) as? UserCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        var user: User?
        user = inSearchMode ? filteredUsers[indexPath.row] : users?[indexPath.row]
        if let user = user {
            cell.user = UserCellViewModel(user: user)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
            let profileLayout = UICollectionViewFlowLayout()
            let profileController = ProfileController(collectionViewLayout: profileLayout)
            if let user = self.users?[indexPath.row] {
                profileController.user = user
                profileController.hidesBottomBarWhenPushed = true
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(profileController, animated: true)
                }
            }
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        guard let users = users else { return }
        filteredUsers = users.filter {
            $0.username.lowercased().contains(searchText) ||
                $0.fullName.lowercased().contains(searchText)
        }
        self.tableView.reloadData()
    }
}
