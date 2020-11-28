//
//  LoginController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 22/11/20.
//

import UIKit

enum LoginError: Error {
    case noInternetConnection
    case invalidEmail
    case invalidPassword
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = LoginViewModel()
    
    private var iconImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white").withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        return tf
    }()
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.systemBackground.withAlphaComponent(0.4), for: .normal)
        button.backgroundColor = UIColor(named: "loginButtonDisabledColor")
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()
    
    private var stackView = UIStackView()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Forgot your password? ", secondPart: "Get help signing in.")
        button.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Don't have an account? ", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemIndigo.cgColor, UIColor.systemPurple.cgColor, UIColor.systemRed.cgColor]
        gradient.locations = [0, 0.4, 0.8]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        configureFields()
        
        view.addSubview(loginButton)
        loginButton.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 32, paddingRight: 32)
        loginButton.setHeight(50)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.centerX(inView: view)
        forgotPasswordButton.anchor(top: loginButton.bottomAnchor, paddingTop: 12)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 12)
        signUpButton.centerX(inView: view)
    }
    
    func configureFields() {
        stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc func didTapSignUp() {
        DispatchQueue.main.async {
            let registrationVC = RegistrationController()
            self.navigationController?.pushViewController(registrationVC, animated: true)
        }
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    @objc func didTapLogin() {
        let activityIndicator = self.showActivityIndicator()
        
        viewModel.login { (result) in
            switch result {
                case .success(_):
                    self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: "Success", andTime: 0.5)
                    activityIndicator.perform {
                        DispatchQueue.main.async {
                            let mainTabController = MainTabController()
                            mainTabController.modalPresentationStyle = .fullScreen
                            self.present(mainTabController, animated: true, completion: nil)
                        }
                    }
                    
                case .failure(let error):
                    let errorMessage = self.mapError(error)
                    self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: errorMessage)
            }
        }
    }
}

// MARK: - FormViewModel Extension

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isUserInteractionEnabled = viewModel.isFormValid
    }
}
