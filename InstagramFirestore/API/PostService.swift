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
    
    static func fetchProfilePosts(for uid: String, completion: @escaping(Result<[Post], Error>) -> Void) {
        postsCollection.order(by: "timestamp", descending: true).whereField("ownerId", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                completion(.success(posts))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirebaseCompletion)) {
        postsCollection.document(post.id).updateData(["likes" : post.likes + 1]) { (error) in
            if let error = error {
                completion(error)
            } else {
                let uid = LoginManager.shared.uid
                postsCollection.document(post.id).collection("likes").document(uid).setData([:], completion: completion)
            }
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirebaseCompletion)) {
        guard post.likes > 0 else { return }
        postsCollection.document(post.id).updateData(["likes" : post.likes - 1]) { (error) in
            if let error = error {
                completion(error)
            } else {
                let uid = LoginManager.shared.uid
                postsCollection.document(post.id).collection("likes").document(uid).delete(completion: completion)
            }
        }
    }
    
    static func checkIfUserLikedThePost(postId: String, completion: @escaping (Bool)-> Void) {
        let uid = LoginManager.shared.uid
        postsCollection.document(postId).collection("likes").document(uid).getDocument { (document, error) in
            guard let isLiked = document?.exists else { return }
            completion(isLiked)
        }
    }
    
    static func fetchSelectedPost(postId: String, completion: @escaping(Result<Post, Error>) -> Void) {
        postsCollection.document(postId).getDocument { (snapshot, error) in
            if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                let post = Post(postId: snapshot.documentID, dictionary: data)
                completion(.success(post))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
