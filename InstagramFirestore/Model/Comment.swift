//
//  Comment.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 26/12/20.
//

import Foundation
import Firebase

struct Comment: Hashable {
    let uid: String
    let comment: String
    let timestamp: Timestamp
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String:Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.comment = dictionary["comment"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(uid)
    }

    static func == (lhs: Comment, rhs: Comment) -> Bool {
      lhs.uid == rhs.uid
    }
}
