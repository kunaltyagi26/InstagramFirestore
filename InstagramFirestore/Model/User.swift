//
//  User.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/11/20.
//

import Foundation
import FirebaseAuth

struct User: Codable {
    let uid: String
    let email: String
    let username: String
    let fullName: String
    let profileImageUrl: String
    
    var stats: UserStats?
    
    var isFollowed: Bool?
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init() {
        self.uid = ""
        self.email = ""
        self.username = ""
        self.fullName = ""
        self.profileImageUrl = ""
    }
    
    init(uid: String, email: String, username: String, fullName: String, profileImageUrl: String) {
        self.uid = uid
        self.email = email
        self.username = username
        self.fullName = fullName
        self.profileImageUrl = profileImageUrl
    }
    
    init(dictionary: [String:Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}

struct UserStats: Codable {
    let followers: Int
    let following: Int
    let posts: Int
}
