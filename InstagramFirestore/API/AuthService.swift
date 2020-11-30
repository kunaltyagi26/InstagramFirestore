//
//  AuthService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 24/11/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct AuthCredentails {
    let email: String
    let password: String
    let fullName: String?
    let userName: String?
    let profileImage: UIImage?
}

struct AuthService {
    func signIn(withEmail email: String, andPassword password: String, completion: @escaping(Result<Bool, Error>)-> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func register(withCredential credentials: AuthCredentails, completion: @escaping (Result<Bool, Error>)-> Void) {
        guard let profileImage = credentials.profileImage else {
            completion(.failure(SignUpError.invalidProfilePicture))
            return
        }
        ImageUploader.uploadImage(image: profileImage, completion: { (downloadUrl, error) in
            if let error = error {
                completion(.failure(error))
                return
            } else {
                guard let downloadUrl = downloadUrl, let fullName = credentials.fullName, let userName = credentials.userName else {
                    completion(.failure(SignUpError.incompleteForm))
                    return
                }
                
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { authResult, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let uid = authResult?.user.uid else { return }
                    
                    let data: [String: Any] = ["email": credentials.email,
                                               "fullName": fullName,
                                               "profileImageUrl": downloadUrl,
                                               "uid": uid,
                                               "username": userName]
                    
                    usersCollection.document(uid).setData(data)
            
                    Auth.auth().useAppLanguage()
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        } else {
                            signOut { (result) in
                                switch result {
                                    case .success(let success):
                                        completion(.success(success))
                                    case .failure(let error):
                                        completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func signOut(completion: @escaping (Result<Bool, Error>)-> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
}
