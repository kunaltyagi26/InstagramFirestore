//
//  UIViewController + Extensions.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 26/11/20.
//

import UIKit
import JGProgressHUD
import Firebase

extension UIViewController {
    func showAlert(title: String, message: String, firstActionTitle: String = "OK", secondActionTitle: String? = "", firstActionHandler: ((UIAlertAction) -> Void)? = nil, secondActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: firstActionTitle, style: .default, handler: firstActionHandler))
        if let secondActionTitle = secondActionTitle, secondActionTitle != "" {
            alertController.addAction(UIAlertAction(title: secondActionTitle, style: .default, handler: secondActionHandler))
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showActivityIndicator()-> JGProgressHUD {
        let hud = JGProgressHUD(automaticStyle: ())
        hud.textLabel.text = "Loading"
        hud.shadow = JGProgressHUDShadow(color: .label, offset: .zero, radius: 10.0, opacity: 0.2)
        hud.animation = JGProgressHUDFadeZoomAnimation()
        hud.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        hud.show(in: self.tabBarController?.view ?? self.view)
        return hud
    }
    
    func showFinalizedActivityIndicator(for indicator: JGProgressHUD, withMessage message: String? = "", withError error: String? = "", andTime time: TimeInterval = 5.0) {
        if let message = message, message != "" {
            indicator.indicatorView = JGProgressHUDSuccessIndicatorView()
            indicator.textLabel.text = message
        } else if let error = error, error != "" {
            indicator.indicatorView = JGProgressHUDSuccessIndicatorView()
            indicator.textLabel.text = error
        }
        indicator.dismiss(afterDelay: time, animated: true)
    }
    
    func showLogoutButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    func showMessageButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(didTapMessageButton))
    }
    
    @objc func handleLogout() {
        let activityIndicator = self.showActivityIndicator()
        
        AuthService().signOut { (result) in
            switch result {
            case .success(_):
                self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: "Success", andTime: 0.5)
                activityIndicator.perform {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: error.localizedDescription)
            }
        }
    }
    
    @objc func didTapMessageButton() {
        self.navigationController?.pushViewController(LoginController(), animated: true)
    }
    
    func mapError(_ error: Error)-> String {
        var errorMessage = ""
        if error is SignUpError {
            switch error {
            case SignUpError.noInternetConnection:
                errorMessage = "The request cannot be processed as internet connection is not available."
            case SignUpError.invalidEmail:
                errorMessage = "Please enter a valid email address."
            case SignUpError.invalidPassword:
                errorMessage = "Please enter a valid password."
            case SignUpError.invalidFullName:
                errorMessage = "Please enter a valid full name."
            case SignUpError.invalidUsername:
                errorMessage = "Please enter a valid email address."
            case SignUpError.invalidProfilePicture:
                errorMessage = "Please select a valid profile picture."
            case SignUpError.incompleteForm:
                errorMessage = "Please fill all your details"
            default:
                errorMessage = "Unkown error. Please try again."
            }
        } else if error is LoginError {
            switch error {
                case LoginError.noInternetConnection:
                    errorMessage = "The request cannot be processed as internet connection is not available."
                case LoginError.invalidEmail:
                    errorMessage = "Please enter a valid email address."
                case LoginError.invalidPassword:
                    errorMessage = "Please enter a valid password."
                default:
                    errorMessage = "Unkown error. Please try again."
            }
        } else {
            if let errorCode = AuthErrorCode(rawValue: error._code) {
                // now you can use the .errorMessage var to get your custom error message
                print(errorCode.errorMessage)
                errorMessage = errorCode.errorMessage
            }
        }
        
        return errorMessage
    }
}
