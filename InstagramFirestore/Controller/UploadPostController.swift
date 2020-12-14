//
//  UploadPostController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 08/12/20.
//

import UIKit
import JGProgressHUD

protocol UploadPostDelegate: AnyObject {
    func updateFeed()
}

class UploadPostController: UIViewController {
    
    // MARK: - Properties
    
    var user: User?

    private let outerPostImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 10, shadowRadius: 10, shadowOffset: CGSize(width: 5.0, height: 5.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let captionTextView: CustomTextView = {
        let tv = CustomTextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.placeholderText = "Enter caption..."
        return tv
    }()
    
    private let charactersCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.text = "0/100"
        return label
    }()
    
    var selectedImage = UIImage()
    
    var charactersEntered: Int = 0
    let totalCharacters: Int = 100
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        configureView()
        configureData()
    }
    
    // MARK: - Helpers
    
    func configureView() {
        self.navigationItem.title = "Upload Post"
        self.view.backgroundColor = UIColor(named: "background")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(shareTapped))
        
        self.view.addSubview(outerPostImageView)
        outerPostImageView.anchor(top: self.view.topAnchor, paddingTop: 12)
        outerPostImageView.centerX(inView: self.view)
        outerPostImageView.setWidth(UIScreen.main.bounds.width / 2)
        outerPostImageView.heightAnchor.constraint(equalTo: self.outerPostImageView.widthAnchor, multiplier: 1).isActive = true
        
        outerPostImageView.addSubview(postImageView)
        postImageView.anchor(top: outerPostImageView.topAnchor, left: outerPostImageView.leftAnchor, bottom: outerPostImageView.bottomAnchor, right: outerPostImageView.rightAnchor)
        
        self.view.addSubview(captionTextView)
        captionTextView.anchor(top: outerPostImageView.bottomAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingRight: 12, height: 72)
        
        self.view.addSubview(charactersCountLabel)
        charactersCountLabel.anchor(top: captionTextView.bottomAnchor, right: self.view.rightAnchor, paddingTop: 12, paddingRight: 12)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleTapGesture))
        self.view.addGestureRecognizer(tapGesture)
        
        captionTextView.delegate = self
    }
    
    func configureData() {
        postImageView.image = selectedImage
    }
    
    // MARK: - Actions
    
    @objc func cancelTapped() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @objc func shareTapped() {
        UploadPostController.activityIndicator = self.showActivityIndicator()
        guard let user = user else { return }
        PostService.uploadPost(user: user, image: selectedImage, caption: captionTextView.text) { (error) in
            if let error = error {
                self.showFinalizedActivityIndicator(for: UploadPostController.activityIndicator, withMessage: error.localizedDescription)
            } else {
                self.showFinalizedActivityIndicator(for: UploadPostController.activityIndicator, withMessage: "Success", andTime: 0.5)
                UploadPostController.activityIndicator.perform {
                    (self.tabBarController as? MainTabController)?.set(selectedIndex: 0)
                }
            }
        }
    }
    
    @objc func handleTapGesture() {
        self.captionTextView.resignFirstResponder()
    }
}

// MARK: - Extensions

extension UploadPostController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        charactersEntered = numberOfChars
        charactersCountLabel.text = "\(charactersEntered)/\(totalCharacters)"
        return charactersEntered < totalCharacters
    }
}
