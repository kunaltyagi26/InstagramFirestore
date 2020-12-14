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
    private var uploadedImages = [UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!)]
    
    var user: User?
    var posts: [Post] = []

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
        
        dispatchGroup.enter()
        UserService.getStats(uid: user?.uid ?? Auth.auth().currentUser?.uid) { (result) in
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
        
        dispatchGroup.enter()
        UserService.checkIfUserIsFollowed(uid: user?.uid ?? Auth.auth().currentUser?.uid) { (isFollowed) in
            self.user?.isFollowed = isFollowed
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        PostService.fetchProfilePosts { (result) in
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
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.showFinalizedActivityIndicator(for: ProfileController.activityIndicator, withMessage: "Success", andTime: 0.5)
            }
        }
    }
    
    func fetchUser(uid: String) {
        UserService.fetchUser(uid: uid) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    self.dispatchGroup.leave()
                case .failure(let error):
                    self.showFinalizedActivityIndicator(for: ProfileController.activityIndicator, withMessage: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureView() {
        self.navigationItem.title = "Profile"
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
            cell?.setImage(url: URL(string: post.imageUrl)!)
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

