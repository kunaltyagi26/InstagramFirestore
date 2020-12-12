//
//  PostService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 09/12/20.
//

import UIKit
import Firebase

struct PostService {
    static func uploadPost(image: UIImage, caption: String, completion: @escaping(FirebaseCompletion)) {
        ImageUploader.uploadImage(image: image) { (downloadUrl, error) in
            if let error = error {
                completion(error)
            } else if let downloadUrl = downloadUrl {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let data: [String: Any] = ["imageUrl": downloadUrl,
                                           "caption": caption,
                                           "owner": uid,
                                           "timestamp": Timestamp(date: Date()),
                                           "likes": 0
                                          ]
                postsCollection.addDocument(data: data)
                completion(nil)
            }
        }
    }
    
    static func fetchPosts(completion: @escaping(Result<[Post], Error>) -> Void) {
        postsCollection.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                completion(.success(posts))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
