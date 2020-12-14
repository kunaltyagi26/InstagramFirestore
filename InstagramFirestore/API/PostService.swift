//
//  PostService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 09/12/20.
//

import UIKit
import Firebase

struct PostService {
    static func uploadPost(user: User, image: UIImage, caption: String, completion: @escaping(FirebaseCompletion)) {
        ImageUploader.uploadImage(image: image) { (downloadUrl, error) in
            if let error = error {
                completion(error)
            } else if let downloadUrl = downloadUrl {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let postId = UUID().uuidString
                let data: [String: Any] = ["id": postId,
                                           "imageUrl": downloadUrl,
                                           "caption": caption,
                                           "ownerId": uid,
                                           "timestamp": Timestamp(date: Date()),
                                           "likes": 0,
                                           "ownerProfilePicture": user.profileImageUrl,
                                           "ownerFullName": user.fullName
                                          ]
                postsCollection.document(postId).setData(data)
                completion(nil)
            }
        }
    }
    
    static func fetchFeedPosts(completion: @escaping(Result<[Post], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.getFollowers(uid: uid) { (followers, error)  in
            if let followers = followers {
                var posts: [Post] = []
                if followers.count > 0 {
                    postsCollection.order(by: "timestamp", descending: true).whereField("ownerId", in: followers).getDocuments { (snapshot, error) in
                        if let snapshot = snapshot {
                            posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                            completion(.success(posts))
                        } else if let error = error {
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.success(posts))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    static func fetchProfilePosts(completion: @escaping(Result<[Post], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        postsCollection.order(by: "timestamp", descending: true).whereField("ownerId", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                completion(.success(posts))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
