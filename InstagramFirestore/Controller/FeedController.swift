//
//  FeedController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit

private let resuseIdentifier = "feedCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    func configureCollectionView() {
        self.navigationItem.title = "Feed"
        self.view.backgroundColor = UIColor(named: "background")?.withAlphaComponent(0.4)
        self.collectionView.backgroundColor = UIColor(named: "background")?.withAlphaComponent(0.4)
        self.showLogoutButton()
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: resuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    // MARK: - Helpers
}

// MARK: - UICollectionViewDataSource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: resuseIdentifier, for: indexPath) as? FeedCell else { return UICollectionViewCell() }
        
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
