//
//  LoginManager.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 25/12/20.
//

import Foundation

struct LoginManager {
    static let shared = LoginManager()
    
    func saveUserDetails(for user: User) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(user.email, forKey: "email")
        userDefaults.setValue(user.fullName, forKey: "fullName")
        userDefaults.setValue(user.profileImageUrl, forKey: "profileImageUrl")
        userDefaults.setValue(user.uid, forKey: "uid")
        userDefaults.setValue(user.username, forKey: "username")
    }
    
    var email: String {
        guard let emailValue = UserDefaults.standard.value(forKey: "email") as? String else { return "" }
        return emailValue
    }
    
    var fullName: String {
        guard let emailValue = UserDefaults.standard.value(forKey: "fullName") as? String else { return "" }
        return emailValue
    }
    
    var profileImageUrl: String {
        guard let emailValue = UserDefaults.standard.value(forKey: "profileImageUrl") as? String else { return "" }
        return emailValue
    }
    
    var uid: String {
        guard let emailValue = UserDefaults.standard.value(forKey: "uid") as? String else { return "" }
        return emailValue
    }
    
    var username: String {
        guard let emailValue = UserDefaults.standard.value(forKey: "username") as? String else { return "" }
        return emailValue
    }
}
