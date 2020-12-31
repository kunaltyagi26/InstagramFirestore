//
//  NotificationCell.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/12/20.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: NotificationViewModel? {
        didSet {
            configureView()
        }
    }
    
    private let outerProfileImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 40 / 2, shadowRadius: 3, shadowOffset: CGSize(width: 3.0, height: 3.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray2
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 40 / 2
        return iv
    }()
    
    private let infoLabel: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        return textView
    }()
    
    private let postImageOuterView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 0, shadowRadius: 5, shadowOffset: CGSize.zero, shadowOpacity: 1.0)
        return outerView
    }()
    
    private let postImageView: UIImageView = {
        let postImageView = UIImageView()
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePostTapped)))
        return postImageView
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Follow", for: .normal)
        button.backgroundColor = UIColor(named: "background")
        button.tintColor = .label
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.label.withAlphaComponent(0.3).cgColor
        button.applyshadowWithCorner(cornerRadius: 6, shadowRadius: 3, shadowOffset: CGSize(width: 0.0, height: 0.0), shadowOpacity: 0.5)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside )
        return button 
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not been implemented.")
    }
    
    // MARK: - Helpers
    
    func setupView() {
        self.addSubview(infoLabel)
        infoLabel.anchor(top: topAnchor, bottom: bottomAnchor, paddingTop: 8, paddingBottom: 8)
        infoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
        self.addSubview(outerProfileImageView)
        outerProfileImageView.centerY(inView: infoLabel)
        outerProfileImageView.anchor(left: leftAnchor, right: infoLabel.leftAnchor, paddingLeft: 8, paddingRight: 12, width: 40, height: 40)
        
        outerProfileImageView.addSubview(profileImageView)
        profileImageView.anchor(top: outerProfileImageView.topAnchor, left: outerProfileImageView.leftAnchor, bottom: outerProfileImageView.bottomAnchor, right: outerProfileImageView.rightAnchor)
        
        addSubview(followButton)
        followButton.centerY(inView: infoLabel)
        followButton.anchor(left: infoLabel.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 12, width: 70, height: 24)
        
        addSubview(postImageOuterView)
        postImageOuterView.centerY(inView: infoLabel)
        postImageOuterView.anchor(left: infoLabel.rightAnchor, right: rightAnchor, paddingLeft: 12, paddingRight: 12, width: 40, height: 40)
        
        addSubview(postImageView)
        postImageOuterView.addSubview(postImageView)
        postImageView.anchor(top: postImageOuterView.topAnchor, left: postImageOuterView.leftAnchor, bottom: postImageOuterView.bottomAnchor, right: postImageOuterView.rightAnchor)
        
        followButton.isHidden = true
    }
    
    func configureView() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.ownerProfilePicture, completed: nil)
        infoLabel.attributedText = viewModel.notificationLabelText()
        self.infoLabel.linkTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        if let postImageUrl = viewModel.postImageUrl {
            postImageView.sd_setImage(with: postImageUrl, completed: nil)
        }
    }
    
    // MARK: - Actions
    
    @objc func handleFollowTapped() {
        
    }
    
    @objc func handlePostTapped() {
        
    }
}
