//
//  RegistrationController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 22/11/20.
//

import UIKit

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = RegistrationViewModel()
    
    private let addProfilePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .systemBackground
        button.addTarget(self, action: #selector(didTapAddProfilePhoto), for: .touchUpInside)
        return button
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
    
    private let fullNameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Fullname")
        return tf
    }()
    
    private let usernameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Username")
        return tf
    }()
    
    private var stackView = UIStackView()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.systemBackground.withAlphaComponent(0.4), for: .normal)
        button.backgroundColor = UIColor(named: "loginButtonDisabledColor")
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        return button
    }()
    
    private let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Already have an account? ", secondPart: "Log In")
        button.addTarget(self, action: #selector(didTapLogIn), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNotificationObservers()
    }
    
    // MARK: - Helpers
    
    func configureView() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradient.locations = [0, 0.5]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
        
        view.addSubview(addProfilePhotoButton)
        addProfilePhotoButton.centerX(inView: view)
        addProfilePhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        addProfilePhotoButton.setDimensions(height: 140, width: 140)
        
        configureFields()
        
        view.addSubview(signUpButton)
        
    }
    
    func configureFields() {
        stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, fullNameTextField, usernameTextField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: addProfilePhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 32, paddingRight: 32)
        signUpButton.setHeight(50)
        
        view.addSubview(logInButton)
        logInButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        logInButton.centerX(inView: view)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc func didTapAddProfilePhoto() {
        
    }
    
    @objc func didTapLogIn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSignUp() {
        
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == fullNameTextField {
            viewModel.fullName = sender.text
        } else if sender == usernameTextField {
            viewModel.userName = sender.text
        }
        
        updateForm()
    }
}

// MARK: - FormViewModel Extension

extension RegistrationController: FormViewModel {
    func updateForm() {
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isUserInteractionEnabled = viewModel.isFormValid
    }
}
