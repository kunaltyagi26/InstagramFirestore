//
//  FeedController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit

// MARK: - Reuse-Identifiers

private let reuseIdentifier = "feedCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    var posts: [Post] = [Post]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var selectedPost: Post?
    
    var refreshControl = UIRefreshControl()
    
    var noFeedsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "background")
        view.isHidden = true
        return view
    }()
    
    var noFeedsLabel: UILabel = {
        let label = UILabel()
        label.text = "No post is currently available. Please pull down to refresh."
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        configureCollectionView()
        
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        self.navigationItem.title = "Feed"
        self.navigationItem.backButtonTitle = ""
        self.view.backgroundColor = UIColor(named: "background")?.withAlphaComponent(0.4)
        self.collectionView.backgroundColor = UIColor(named: "background")
        
        if selectedPost == nil {
            self.showLogoutButton()
            self.showMessageButton()
        }
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.collectionView.showsVerticalScrollIndicator = false
        
        if selectedPost == nil {
            self.collectionView.alwaysBounceVertical = true
            self.collectionView.refreshControl = refreshControl
            self.refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        }
    }
    
    func configureNoFeedsView() {
        view.addSubview(noFeedsView)
        noFeedsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        noFeedsView.addSubview(noFeedsLabel)
        noFeedsLabel.center(inView: noFeedsView)
    }
    
    // MARK: - API
    
    func getData() {
        guard selectedPost == nil else { return }
        FeedController.activityIndicator = self.showActivityIndicator()
        PostService.fetchFeedPosts { (result) in
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                switch result {
                    case .success(let posts):
                        if posts.count == 0 {
                            self.collectionView.backgroundView = self.noFeedsLabel
                            self.posts = posts
                            self.collectionView.backgroundColor = UIColor(named: "background")
                            self.collectionView.reloadData()
                            self.showFinalizedActivityIndicator(for: FeedController.activityIndicator, withMessage: "Success", andTime: 0.5)
                        } else {
                            self.collectionView.backgroundView = nil
                            self.posts = posts
                            self.checkIfUserLikedPost()
                            self.collectionView.backgroundColor = UIColor(named: "background")?.withAlphaComponent(0.4)
                            self.showFinalizedActivityIndicator(for: FeedController.activityIndicator, withMessage: "Success", andTime: 0.5)
                        }
                    case .failure(let error):
                        self.collectionView.backgroundView = self.noFeedsLabel
                        self.collectionView.backgroundColor = UIColor(named: "background")
                        self.showFinalizedActivityIndicator(for: FeedController.activityIndicator, withMessage: error.localizedDescription)
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
    
    // MARK: - Actions
    
    @objc func reloadData() {
        self.refreshControl.beginRefreshing()
        getData()
    }
}

// MARK: - UICollectionViewDataSource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPost == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeedCell else { return UICollectionViewCell() }
        cell.delegate = self
        if selectedPost == nil {
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            PostService.checkIfUserLikedThePost(postId: posts[indexPath.row].id) { (didLike) in
                //cell.viewModel?.didLike = didLike
            }
        } else if let selectedPost = selectedPost {
            cell.viewModel = PostViewModel(post: selectedPost)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = 12 + 40 + 12 + width + 24 + 20 + 12 + 15 + 12 + 15 + 12 + 15 + 12
        return CGSize(width: view.frame.width - 24, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24.0
    }
}

// MARK: - FeedCellDelegate

extension FeedController: FeedCellDelegate {
    func handleUsernameClicked(ownerId: String?) {
        let profileLayout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: profileLayout)
        profileController.selectedUserId = ownerId
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(profileController, animated: true)
        }
    }
    
    func handleCommentClicked(postId: String?) {
        let commentsController = CommentsController()
        commentsController.postId = postId
        commentsController.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(commentsController, animated: true)
        }
    }
    
    func handleLikeClicked(for cell: FeedCell, post: Post) {
        cell.viewModel?.didLike.toggle()
        
        if post.didLike {
            PostService.unlikePost(post: post) { (error) in
                if let error = error {
                    self.updateCellAndShowError(cell: cell, error: error)
                }
            }
        } else {
            PostService.likePost(post: post) { (error) in
                if let error = error {
                    self.updateCellAndShowError(cell: cell, error: error)
                }
            }
        }
    }
    
    func updateCellAndShowError(cell: FeedCell, error: Error) {
        cell.viewModel?.didLike.toggle()
        UIView.transition(with: cell.likeButton.imageView ?? UIImageView(),
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { cell.likeButton.setImage(cell.viewModel?.didLike ?? false ? UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.systemRed) : UIImage(systemName: "heart"), for: .normal) },
                          completion: nil)
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
}
