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
    
    static func fetchComment(postId: String, completion: @escaping(Result<[Comment], Error>)-> Void) {
        var comments: [Comment] = []
        let query = postsCollection.document(postId).collection("comments").order(by: "timestamp", descending: false)
        query.addSnapshotListener { (snapshot, error) in
            if let snapshot = snapshot {
                snapshot.documentChanges.forEach({ (change) in
                    if change.type == .added {
                        let data = change.document.data()
                        let comment = Comment(dictionary: data)
                        comments.append(comment)
                    }
                })
                completion(.success(comments))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
