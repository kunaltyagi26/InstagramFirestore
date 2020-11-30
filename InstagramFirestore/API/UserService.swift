//
//  UserService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 29/11/20.
//

import Foundation
import Firebase

struct UserService {
    static func fetchUser(uid: String, completion: @escaping(Result<User, Error>)-> Void) {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
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
}
