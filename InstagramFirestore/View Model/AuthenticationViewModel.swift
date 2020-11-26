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
                AuthService().signIn(withEmail: emailValue, andPassword: passwordValue) { (credentials) in
                    
                }
            }
        }
    }
}

struct RegistrationViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    var fullName: String?
    var userName: String?
    var profilePicture: UIImage?
    
    var isFormValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false && fullName?.isEmpty == false && userName?.isEmpty == false && profilePicture != nil
    }
    
    var buttonBackgroundColor: UIColor {
        return isFormValid ? (UIColor(named: "loginButtonColor") ?? UIColor.systemBackground) : (UIColor(named: "loginButtonDisabledColor") ?? UIColor.systemBackground)
    }
    
    var buttonTitleColor: UIColor {
        return isFormValid ? UIColor.systemBackground.withAlphaComponent(0.7) : UIColor.systemBackground.withAlphaComponent(0.4)
    }
    
    func signUp(completion: @escaping (Result<Bool, Error>)-> Void) {
        if let email = email, let password = password, let fullName = fullName, let userName = userName, let profilePicture = profilePicture {
            let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordValue = password.trimmingCharacters(in: .whitespacesAndNewlines)
            let fullNameValue = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
            let usernameValue = userName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if Reachability.isConnectedToNetwork(){
                if emailValue == "" {
                    completion(.failure(SignUpError.invalidEmail))
                } else if passwordValue == "" {
                    completion(.failure(SignUpError.invalidPassword))
                } else if fullNameValue == "" {
                    completion(.failure(SignUpError.invalidFullName))
                } else if usernameValue == "" {
                    completion(.failure(SignUpError.invalidUsername))
                } else {
                    AuthService().register(withCredential: AuthCredentails(email: emailValue, password: passwordValue, fullName: fullNameValue, userName: usernameValue, profileImage: profilePicture)) { (result) in
                        switch result {
                            case .success(let success):
                                completion(.success(success))
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                }
            }else{
                completion(.failure(SignUpError.noInternetConnection))
            }
        } else {
            completion(.failure(SignUpError.incompleteForm))
        }
    }
}
