//
//  UserService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 29/11/20.
//

import Foundation
import Firebase

struct UserService {
    static func fetchUser(completion: @escaping(Result<User, Error>)-> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
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
        var users: [User] = []
        usersCollection.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let user = User(dictionary: document.data())
                    users.append(user)
                }
                completion(.success(users))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
