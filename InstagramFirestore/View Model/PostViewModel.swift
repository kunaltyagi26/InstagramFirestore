//
//  PostViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 12/12/20.
//

import Foundation

struct PostViewModel {
    private let post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var imageUrl: URL? {
        return URL(string: post.imageUrl)
    }
    
    var caption: String {
        return post.caption
    }
    
    func  fetchUsername(completion: @escaping(Result<String, Error>)-> Void) {
        UserService.fetchUser(uid: post.owner) { (result) in
            switch result {
            case .success(let user):
                completion(.success(user.fullName))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
