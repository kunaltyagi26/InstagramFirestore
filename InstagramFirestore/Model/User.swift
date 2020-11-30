//
//  User.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/11/20.
//

import Foundation

struct User: Codable {
    let uid: String
    let email: String
    let username: String
    let fullName: String
    let profileImageUrl: String
    
    init(dictionary: [String:Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
