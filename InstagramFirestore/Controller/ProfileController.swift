//
//  ProfileController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit
import JGProgressHUD
import Firebase

// MARK: - Reuse-Identifiers

private let profileHeaderCellReuseIdentifier = "profileHeaderCell"
private let profileCellReuseIdentifier = "profileCell"

class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    
    enum Section {
      case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Post>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Post>
    
    private lazy var dataSource = makeDataSource()
    
    var user: User? {
        didSet {
            if selectedUserId != nil {
                self.navigationItem.title = user?.username
            }
        }
    }
    var posts: [Post] = []
    var selectedUserId: String?

    let dispatchGroup = DispatchGroup()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        configureView()
    }
    
    // MARK: - API
    
    func getData() {
        ProfileController.activityIndicator = self.showActivityIndicator()
        
        fetchUserData()
        fetchUserFollowDetail()
        fetchUserStats()
        fetchProfilePosts()
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.showFinalizedActivityIndicator(for: ProfileController.activityIndicator, withMessage: "Success", andTime: 0.5)
            }
        }
    }
    
    // MARK: - API
    
    func fetchUserData() {
        if let selectedUserId = self.selectedUserId {
            self.dispatchGroup.enter()
            UserService.fetchUser(uid: selectedUserId) { (result) in
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    self.showFinalizedActivityIndicator(for: ProfileController.activityIndicator, withMessage: error.localizedDescription)
                }
                self.dispatchGroup.leave()
                
            }
        }
    }
    
    func fetchUserFollowDetail() {
        self.dispatchGroup.enter()
        UserService.checkIfUserIsFollowed(uid: self.user?.uid ?? self.selectedUserId) { (isFollowed) in
            DispatchQueue.main.async {
                self.user?.isFollowed = isFollowed
                self.dispatchGroup.leave()
            }
        }
    }
    
    func fetchUserStats() {
        self.dispatchGroup.enter()
        UserService.getStats(uid: self.user?.uid ?? self.selectedUserId) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userStats):
                    self.user?.stats = userStats
                case.failure(let error):
                    print(error)
                }
                self.dispatchGroup.leave()
            }
        }
    }
    
    func fetchProfilePosts() {
        dispatchGroup.enter()
        PostService.fetchProfilePosts(for: (user?.uid ?? selectedUserId) ?? "") { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.posts = posts
                    self.applySnapshot(animatingDifferences: true)
                case.failure(let error):
                    print(error)
                }
                self.dispatchGroup.leave()
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureView() {
        if selectedUserId == nil {
            self.navigationItem.title = user?.username
        }
        self.navigationItem.backButtonTitle = ""
        self.view.backgroundColor = UIColor(named: "background")
        configureCollectionView()
    }
    
    func configureCollectionView() {
        self.collectionView.backgroundColor = UIColor(named: "background")
        self.collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileHeaderCellReuseIdentifier)
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellReuseIdentifier)
    }
    
    func makeDataSource() -> DataSource {
      let dataSource = DataSource(
        collectionView: collectionView,
        cellProvider: { (collectionView, indexPath, post) ->
          ProfileCell? in
          let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: profileCellReuseIdentifier,
            for: indexPath) as? ProfileCell
            cell?.viewModel = PostViewModel(post: post)
          return cell
      })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
          guard kind == UICollectionView.elementKindSectionHeader else {
            return nil
          }
          let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: profileHeaderCellReuseIdentifier,
            for: indexPath) as? ProfileHeader
            if let user = self.user {
                view?.viewModel = ProfileHeaderViewModel(user: user)
            }
            view?.delegate = self
          return view
        }
      return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
          var snapshot = Snapshot()
          snapshot.appendSections([.main])
          snapshot.appendItems(posts)
          dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.selectedPost = posts[indexPath.row]
        feedController.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(feedController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 228)
    }
}

// MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        if user.isCurrentUser {
            
        } else {
            if let isFollowed = user.isFollowed, !isFollowed {
                UserService.followUser(uid: user.uid) { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.user?.isFollowed = true
                        self.getData()
                    }
                }
            } else {
                UserService.unfollowUser(uid: user.uid) { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.user?.isFollowed = false
                        self.getData()
                    }
                }
            }
        }
    }
}

