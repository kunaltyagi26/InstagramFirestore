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

// MARK: - ViewEnum

enum SearchControllerView: Int {
    case followers
    case followings
}

class SearchController: UIViewController {
    
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
    
    var selectedUserId: String?
    var searchControllerView: SearchControllerView?
    
    private let tableView = UITableView()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor(named: "background")
        return cv
    }()
    
    private var posts: [Post] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var postsRefreshControl = UIRefreshControl()
    var usersRefreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        if selectedUserId == nil {
            fetchPosts()
        }
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Helpers
    
    func configureView() {
        self.navigationItem.title = "Explore"
        self.navigationItem.backButtonTitle = ""
        self.view.backgroundColor = UIColor(named: "background")
        self.tableView.backgroundColor = UIColor(named: "background")
        if selectedUserId == nil {
            configureCollectionView()
        }
        configureTableView()
        configureSearchController()
    }
    
    func configureTableView() {
        self.view.addSubview(tableView)
        tableView.fillSuperview()
        if selectedUserId == nil {
            self.tableView.isHidden = true
        }
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: searchCellReuseIdentifier)
        let footerView = UIView()
        self.tableView.tableFooterView = footerView
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.alwaysBounceVertical = true
        self.tableView.refreshControl = usersRefreshControl
        self.usersRefreshControl.addTarget(self, action: #selector(reloadUsers), for: .valueChanged)
    }
    
    func configureCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.fillSuperview()
        self.collectionView.backgroundColor = UIColor(named: "background")
        self.collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellReuseIdentifier)
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.refreshControl = postsRefreshControl
        self.postsRefreshControl.addTarget(self, action: #selector(reloadPosts), for: .valueChanged)
    }
    
    func configureSearchController() {
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.isHidden = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    // MARK: - API
    
    func fetchUsers() {
        if let selectedUserId = selectedUserId {
            SearchController.activityIndicator = self.showActivityIndicator()
            if let searchControllerView = searchControllerView, searchControllerView.rawValue == 0 {
                self.navigationItem.title = "Followers"
                UserService.fetchFollowers(for: selectedUserId) { (result) in
                    self.populateUsers(result: result)
                }
            } else if searchControllerView?.rawValue == 1 {
                self.navigationItem.title = "Followings"
                UserService.fetchFollowings(for: selectedUserId) { (result) in
                    self.populateUsers(result: result)
                }
            }
        } else {
            UserService.fetchUsers { (result) in
                self.populateUsers(result: result)
            }
        }
    }
    
    func fetchPosts() {
        SearchController.activityIndicator = self.showActivityIndicator()
        PostService.fetchAllPosts { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.posts = posts
                    self.checkIfUserLikedPost()
                    self.showFinalizedActivityIndicator(for: SearchController.activityIndicator, withMessage: "Success", andTime: 0.5)
                case .failure(let error):
                    self.showFinalizedActivityIndicator(for: SearchController.activityIndicator, withMessage: error.localizedDescription)
                }
            }
        }
    }
    
    func checkIfUserLikedPost() {
        self.posts.forEach { (post) in
            PostService.checkIfUserLikedThePost(postId: post.id) { (didLike) in
                if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                    self.posts[index].didLike = didLike
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func populateUsers(result: Result<[User], Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let users):
                self.users = users
                self.showFinalizedActivityIndicator(for: SearchController.activityIndicator, withMessage: "Success", andTime: 0.5)
            case .failure(let error):
                self.showFinalizedActivityIndicator(for: SearchController.activityIndicator, withMessage: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func reloadPosts() {
        self.postsRefreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.postsRefreshControl.endRefreshing()
        }
    }
    
    @objc func reloadUsers() {
        self.usersRefreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.usersRefreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        inSearchMode ? filteredUsers.count : users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

// MARK: - UISearchBarDelegate

extension SearchController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        if selectedUserId == nil {
            collectionView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        if selectedUserId == nil {
            collectionView.isHidden = false
            tableView.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SearchController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.selectedPost = posts[indexPath.row]
        feedController.hidesBottomBarWhenPushed = true
        feedController.delegate = self
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(feedController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SearchController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellReuseIdentifier, for: indexPath) as? ProfileCell else { return UICollectionViewCell() }
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: (width - 4) / 3, height: width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

// MARK: - FeedControllerDelegate

extension SearchController: FeedControllerDelegate {
    func updatePost(post: Post) {
        if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
            self.posts[index].didLike = post.didLike
            self.posts[index].likes = post.likes
        }
    }
}
