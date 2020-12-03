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
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, UploadedImage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UploadedImage>
    
    private lazy var dataSource = makeDataSource()
    private var uploadedImages = [UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!), UploadedImage(image: UIImage(named: "venom-7")!)]
    
    var user: User?

    private var activityIndicator = JGProgressHUD(automaticStyle: ())
    var isFromSearch: Bool = false
    
    let dispatchGroup = DispatchGroup()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        configureView()
        applySnapshot(animatingDifferences: true)
    }
    
    // MARK: - API
    
    func getData() {
        activityIndicator = self.showActivityIndicator()
        if user == nil {
            dispatchGroup.enter()
            if let uid = Auth.auth().currentUser?.uid {
                fetchUser(uid: uid)
            }
        }
        
        dispatchGroup.enter()
        UserService.getStats(uid: user?.uid ?? Auth.auth().currentUser?.uid) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userStats):
                    self.user?.stats = userStats
                    self.dispatchGroup.leave()
                case.failure(let error):
                    print(error)
                }
            }
        }
        
        dispatchGroup.enter()
        UserService.checkIfUserIsFollowed(uid: user?.uid ?? Auth.auth().currentUser?.uid) { (isFollowed) in
            self.user?.isFollowed = isFollowed
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.collectionView.reloadData()
            self.showFinalizedActivityIndicator(for: self.activityIndicator, withMessage: "Success", andTime: 0.5)
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
                    self.showFinalizedActivityIndicator(for: self.activityIndicator, withMessage: error.localizedDescription)
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
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileHeaderCellReuseIdentifier)
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellReuseIdentifier)
    }
    
    func makeDataSource() -> DataSource {
      let dataSource = DataSource(
        collectionView: collectionView,
        cellProvider: { (collectionView, indexPath, image) ->
          UICollectionViewCell? in
          let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: profileCellReuseIdentifier,
            for: indexPath) as? ProfileCell
            cell?.setImage(image: image.image)
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
          snapshot.appendItems(uploadedImages)
          dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: (width - 2) / 3, height: width / 3)
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

