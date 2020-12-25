//
//  CommentService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 25/12/20.
//

import Foundation
import Firebase

struct CommentService {
    static func uploadComment(comment: String, postId: String, user: User, completion: @escaping(FirebaseCompletion)) {
        let data: [String: Any] = ["uid": user.uid,
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "username": user.username,
                                   "profileImageUrl": user.profileImageUrl
                                  ]
        postsCollection.document(postId).collection("comments").addDocument(data: data, completion: completion)
    }
    
    static func fetchComment() {
        
    }
}
