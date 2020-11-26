//
//  RegistrationController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 22/11/20.
//

import UIKit
import Photos
import JGProgressHUD

enum ImageSource {
    case photoLibrary
    case camera
}

enum SignUpError: Error {
    case noInternetConnection
    case invalidEmail
    case invalidPassword
    case invalidFullName
    case invalidUsername
    case invalidProfilePicture
    case incompleteForm
}

extension Error {
    func mapError(error: Error)-> String {
        var errorMessage = ""
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
            default:
                errorMessage = "Unkown error."
        }
        return errorMessage
    }
}

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
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNotificationObservers()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // We need to set the border color here as cgColor doesn't automatically adopt to Dark Mode changes.
        self.addProfilePhotoButton.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    // MARK: - Helpers
    
    func configureView() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemIndigo.cgColor, UIColor.systemPurple.cgColor, UIColor.systemRed.cgColor]
        gradient.locations = [0, 0.4, 0.8]
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
        logInButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 12)
        logInButton.centerX(inView: view)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func getPhotoPermissionAndSelectImage(for source: ImageSource) {
        if source == .camera {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { success in
                if success {
                    self.selectImageFrom(.camera)
                } else {
                    self.showAlert(title: "Camera", message: "Camera access is absolutely necessary to use this app", firstActionTitle: "OK", firstActionHandler:  { (_) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                }
            }
        } else if source == .photoLibrary {
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized {
                        self.selectImageFrom(.photoLibrary)
                    } else {
                        self.showAlert(title: "Photo library", message: "Photo library access is absolutely necessary to use this app.", firstActionTitle: "OK", firstActionHandler:  { (_) in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        })
                    }
                })
            } else if photos == .authorized {
                self.selectImageFrom(.photoLibrary)
            } else {
                self.showAlert(title: "Photo library", message: "Photo library access is absolutely necessary to use this app.", firstActionTitle: "OK", firstActionHandler:  { (_) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
            }
        }
    }
    
    func selectImageFrom(_ source: ImageSource){
        DispatchQueue.main.async {
            switch source {
                case .camera:
                    self.imagePicker.sourceType = .camera
                case .photoLibrary:
                    self.imagePicker.sourceType = .photoLibrary
            }
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @objc func didTapAddProfilePhoto() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Choose source", message: "Choose the source for taking your profile picture.", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
                self.getPhotoPermissionAndSelectImage(for: .camera)
                
            }
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
                
                self.getPhotoPermissionAndSelectImage(for: .photoLibrary)
            }
            
            alert.addAction(cameraAction)
            alert.addAction(photoLibraryAction)
            
            if let popoverController = alert.popoverPresentationController {
              popoverController.sourceView = self.view
              popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
              popoverController.permittedArrowDirections = []
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func didTapLogIn() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func didTapSignUp() {
        let activityIndicator = self.showActivityIndicator()
        
        viewModel.signUp { (result) in
            switch result {
                case .success(_):
                    self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: "Your user has been created successfully. Please confirm your email address to continue.")
                    activityIndicator.perform {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                case .failure(let error):
                    self.showFinalizedActivityIndicator(for: activityIndicator, withMessage: error.localizedDescription)
            }
        }
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

// MARK: - UIImagePickerControllerDelegate

extension RegistrationController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            self.imagePicker.dismiss(animated: true, completion: nil)
            
            if let selectedImage = info[.editedImage] as? UIImage {
                self.addProfilePhotoButton.layer.cornerRadius = self.addProfilePhotoButton.frame.width / 2
                self.addProfilePhotoButton.layer.masksToBounds = true
                self.addProfilePhotoButton.layer.borderColor = UIColor.systemBackground.cgColor
                self.addProfilePhotoButton.layer.borderWidth = 2
                self.addProfilePhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
                self.viewModel.profilePicture = selectedImage
                
                self.updateForm()
            } else {
                self.showAlert(title: "Error", message: "There is an issue while selecting image, please try again later.")
            }
            
            
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}
