//
//  Post.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 12/12/20.
//

import Foundation
import Firebase

struct Post: Hashable {
    let id: String
    let imageUrl: String
    let caption: String
    var likes: Int
    let ownerId: String
    let timestamp: Timestamp
    let ownerProfilePicture: String
    let ownerFullName: String
    var didLike: Bool = false
    
    init(postId: String, dictionary: [String:Any]) {
        self.id = postId
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.ownerId = dictionary["ownerId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.ownerProfilePicture = dictionary["ownerProfilePicture"] as? String ?? ""
        self.ownerFullName = dictionary["ownerFullName"] as? String ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: Post, rhs: Post) -> Bool {
      lhs.id == rhs.id
    }
}
