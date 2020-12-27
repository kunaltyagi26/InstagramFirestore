//
//  UserService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 29/11/20.
//

import Foundation
import Firebase

typealias FirebaseCompletion = (Error?)-> Void

struct UserService {
    static func fetchUser(uid: String, completion: @escaping(Result<User, Error>)-> Void) {
        usersCollection.document(uid).getDocument { (snapshot, error) in
            if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                let user = User(dictionary: data)
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    static func fetchUsers(completion: @escaping(Result<[User], Error>)-> Void) {
        usersCollection.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let users = snapshot.documents.map { User(dictionary: $0.data()) }
                completion(.success(users))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    static func followUser(uid: String, completion: @escaping FirebaseCompletion) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        followersCollection.document(uid).collection("user-followers").document(currentUserId).setData([:]) { (error) in
            if let error = error {
                completion(error)
            } else {
                followingCollection.document(currentUserId).collection("user-following").document(uid).setData([:], completion: completion)
            }
        }
    }
    
    static func unfollowUser(uid: String, completion: @escaping FirebaseCompletion) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        followersCollection.document(uid).collection("user-followers").document(currentUserId).delete { (error) in
            if let error = error {
                completion(error)
            } else {
                followingCollection.document(currentUserId).collection("user-following").document(uid).delete(completion: completion)
            }
        }
    }
    
    static func checkIfUserIsFollowed(uid: String?, completion: @escaping (Bool)-> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid, let uid = uid else { return }
        followingCollection.document(currentUid).collection("user-following").document(uid).getDocument { (document, error) in
            guard let isFollowed = document?.exists else { return }
            completion(isFollowed)
        }
    }
    
    static func getStats(uid: String?, completion: @escaping (Result<UserStats, Error>)-> Void) {
        guard let uid = uid else { return }
        followersCollection.document(uid).collection("user-followers").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let followers = snapshot.count
                followingCollection.document(uid).collection("user-following").getDocuments { (snapshot, error) in
                    if let snapshot = snapshot {
                        let following = snapshot.count
                        postsCollection.whereField("ownerId", isEqualTo: uid).getDocuments { (snapshot, error) in
                            if let snapshot = snapshot {
                                let posts = snapshot.count
                                completion(.success(UserStats(followers: followers, following: following, posts: posts)))
                            } else if let error = error {
                                completion(.failure(error))
                            }
                        }
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    static func getFollowers(uid: String, completion: @escaping([String]?, Error?)-> Void) {
        followingCollection.document(uid).collection("user-following").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                let followers = snapshot.documents.reduce([], { (result, snapshot) in
                    result + [snapshot.documentID]
                })
                completion(followers, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
