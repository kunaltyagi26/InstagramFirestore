//
//  LoginViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 22/11/20.
//

import UIKit

protocol AuthenticationViewModel {
    var isFormValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}

protocol FormViewModel {
    func updateForm()
}

struct LoginViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    
    var isFormValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return isFormValid ? (UIColor(named: "loginButtonColor") ?? UIColor.systemBackground) : (UIColor(named: "loginButtonDisabledColor") ?? UIColor.systemBackground)
    }
    
    var buttonTitleColor: UIColor {
        return isFormValid ? UIColor.systemBackground.withAlphaComponent(0.7) : UIColor.systemBackground.withAlphaComponent(0.4)
    }
    
    func login() {
        if let email = email, let password = password {
            let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordValue = password.trimmingCharacters(in: .whitespacesAndNewlines)
            if emailValue != "" && passwordValue != "" {
                
            }
        }
    }
}

struct RegistrationViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    var fullName: String?
    var userName: String?
    
    var isFormValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false && fullName?.isEmpty == false && userName?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return isFormValid ? (UIColor(named: "loginButtonColor") ?? UIColor.systemBackground) : (UIColor(named: "loginButtonDisabledColor") ?? UIColor.systemBackground)
    }
    
    var buttonTitleColor: UIColor {
        return isFormValid ? UIColor.systemBackground.withAlphaComponent(0.7) : UIColor.systemBackground.withAlphaComponent(0.4)
    }
    
    func signUp() {
        if let email = email, let password = password {
            let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordValue = password.trimmingCharacters(in: .whitespacesAndNewlines)
            if emailValue != "" && passwordValue != "" {
                
            }
        }
    }
}
