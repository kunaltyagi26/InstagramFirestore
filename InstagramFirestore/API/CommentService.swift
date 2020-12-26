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
        postsCollection.document(postId).collection("comments").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let comments = snapshot.documents.map { Comment(dictionary: $0.data()) }
                completion(.success(comments))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
