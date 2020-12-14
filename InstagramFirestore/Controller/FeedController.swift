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
    
    var posts: [Post] = [Post]()
    
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
        self.view.backgroundColor = UIColor(named: "background")?.withAlphaComponent(0.4)
        self.collectionView.backgroundColor = UIColor(named: "background")
        self.showLogoutButton()
        self.showMessageButton()
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.collectionView.showsVerticalScrollIndicator = false
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        //configureNoFeedsView()
    }
    
    func configureNoFeedsView() {
        view.addSubview(noFeedsView)
        noFeedsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        noFeedsView.addSubview(noFeedsLabel)
        noFeedsLabel.center(inView: noFeedsView)
    }
    
    // MARK: - API
    
    func getData() {
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
                            self.collectionView.backgroundColor = UIColor(named: "background")
                        } else {
                            self.collectionView.backgroundView = nil
                            self.posts = posts
                            self.collectionView.backgroundColor = UIColor(named: "background")?.withAlphaComponent(0.4)
                        }
                        self.showFinalizedActivityIndicator(for: FeedController.activityIndicator, withMessage: "Success", andTime: 0.5)
                        self.collectionView.reloadData()
                    case .failure(let error):
                        self.collectionView.backgroundView = self.noFeedsLabel
                        self.collectionView.backgroundColor = UIColor(named: "background")
                        self.showFinalizedActivityIndicator(for: FeedController.activityIndicator, withMessage: error.localizedDescription)
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
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeedCell else { return UICollectionViewCell() }
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
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
