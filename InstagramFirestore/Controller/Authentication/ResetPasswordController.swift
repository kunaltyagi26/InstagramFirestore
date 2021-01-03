//
//  ResetPasswordController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 02/01/21.
//

import UIKit

class ResetPasswordController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = ResetPasswordViewModel()
    
    private var iconImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white").withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.systemBackground.withAlphaComponent(0.4), for: .normal)
        button.backgroundColor = UIColor(named: "loginButtonDisabledColor")
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(didTapResetPassword), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        configureView()
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    
    func configureView() {
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .systemBackground
        self.configureGradientLayer()
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, resetPasswordButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 32
        
        view.addSubview(stackView)
        stackView.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
        stackView.center(inView: self.view)
    }
    
    // MARK: - Actions
    
    @objc func didTapResetPassword() {
        let activityIndicator = self.showActivityIndicator()
        viewModel.resetPassword { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let completed):
                    if completed {
                        self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: "An email has been sent to your registered email id for resetting password.")
                        activityIndicator.perform {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                case .failure(let error):
                    self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: error.localizedDescription)
                }
            }
        }
    }
    
    @objc func textDidChange(sender: UITextField) {
        viewModel.email = sender.text
        updateForm()
    }
}

// MARK: - FormViewModel

extension ResetPasswordController: FormViewModel {
    func updateForm() {
        resetPasswordButton.backgroundColor = viewModel.buttonBackgroundColor
        resetPasswordButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        resetPasswordButton.isUserInteractionEnabled = viewModel.isFormValid
    }
}
