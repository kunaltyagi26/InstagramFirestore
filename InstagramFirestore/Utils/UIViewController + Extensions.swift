//
//  UIViewController + Extensions.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 26/11/20.
//

import UIKit
import JGProgressHUD

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
        hud.show(in: self.view)
        return hud
    }
    
    func showFinalizedActivityIndicator(for indicator: JGProgressHUD, withMessage message: String? = "", withError error: String? = "") {
        if let message = message, message != "" {
            indicator.indicatorView = JGProgressHUDSuccessIndicatorView()
            indicator.textLabel.text = message
        } else if let error = error, error != "" {
            indicator.indicatorView = JGProgressHUDSuccessIndicatorView()
            indicator.textLabel.text = error
        }
        indicator.dismiss(afterDelay: 5.0, animated: true)
    }
}
