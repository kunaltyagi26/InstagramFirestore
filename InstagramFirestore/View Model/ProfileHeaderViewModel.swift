//
//  ProfileHeaderViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/11/20.
//

import Foundation

struct ProfileHeaderViewModel {
    
    // MARK: - Properties
    
    let user: User
    
    var fullName: String {
        return user.fullName
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var uid: String {
        return user.uid
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
    }
}
