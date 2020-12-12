//
//  Post.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 12/12/20.
//

import Foundation
import Firebase

struct Post {
    let imageUrl: String
    let caption: String
    let likes: Int
    let owner: String
    let timestamp: Timestamp
    
    init(postId: String, dictionary: [String:Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.owner = dictionary["owner"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        print(timestamp.dateValue().timeIntervalSinceNow / 576 / 24)
    }
}
