//
//  ProfileHeaderViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/11/20.
//

import UIKit
import Firebase

struct ProfileHeaderViewModel {
    
    // MARK: - Properties
    
    var user: User
    
    var fullName: String {
        return user.fullName
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var uid: String {
        return user.uid
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        if let isFollowed = user.isFollowed {
            return isFollowed ? "Following" : "Follow"
        }
        return "Loading"
    }
    
    var followButtonBackgroundColor: UIColor {
        if user.isFollowed != nil && user.stats != nil {
            return user.isCurrentUser ? UIColor(named: "background") ?? .systemBackground : UIColor.systemBlue
        }
        return UIColor(named: "background") ?? .systemBackground
    }
    
    var followButtonTitleColor: UIColor {
        if user.isFollowed != nil && user.stats != nil {
            return user.isCurrentUser ? .label : .white
        }
        return .label
    }
    
    var numberOfFollowers: String {
        if let followers = user.stats?.followers {
            return String(describing: followers)
        }
        return ""
    }
    
    var numberOfFollowing: String {
        if let following = user.stats?.following {
            return String(describing: following)
        }
        return ""
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
    }
    
    // MARK: - Helpers
    
    func followUser(withUid uid: String, completion: @escaping FirebaseCompletion) {
        UserService.followUser(uid: uid, completion: completion)
    }
    
    func unfollowUser(withUid uid: String, completion: @escaping FirebaseCompletion) {
        UserService.unfollowUser(uid: uid, completion: completion)
    }
}
