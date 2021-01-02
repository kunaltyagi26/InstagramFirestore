//
//  NotificationCell.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/12/20.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: NotificationCell, wantsToFollow uid: String)
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String)
    func cell(_ cell: NotificationCell, wantsToViewPost post: String)
    func cell(_ cell: NotificationCell, wantsToViewProfile uid: String)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: NotificationViewModel? {
        didSet {
            configureView()
        }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private let outerProfileImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 40 / 2, shadowRadius: 3, shadowOffset: CGSize(width: 3.0, height: 3.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray2
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 40 / 2
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped)))
        return iv
    }()
    
    let infoLabel: UITextView = {
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
    
    private lazy var postImageView: UIImageView = {
        let postImageView = UIImageView()
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePostTapped)))
        return postImageView
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.backgroundColor = UIColor(named: "background")
        button.tintColor = .label
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.label.withAlphaComponent(0.3).cgColor
        button.applyshadowWithCorner(cornerRadius: 6, shadowRadius: 3, shadowOffset: CGSize(width: 0.0, height: 0.0), shadowOpacity: 0.5)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
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
        contentView.addSubview(infoLabel)
        infoLabel.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, paddingTop: 4, paddingBottom: 0)
        infoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
        
        contentView.addSubview(outerProfileImageView)
        outerProfileImageView.centerY(inView: contentView)
        outerProfileImageView.anchor(left: contentView.leftAnchor, right: infoLabel.leftAnchor, paddingLeft: 8, paddingRight: 12, width: 40, height: 40)
        
        outerProfileImageView.addSubview(profileImageView)
        profileImageView.anchor(top: outerProfileImageView.topAnchor, left: outerProfileImageView.leftAnchor, bottom: outerProfileImageView.bottomAnchor, right: outerProfileImageView.rightAnchor)
    }
    
    func configureView() {
        selectionStyle = .none
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.ownerProfilePicture, completed: nil)
        infoLabel.attributedText = viewModel.notificationLabelText()
        self.infoLabel.linkTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        if let postImageUrl = viewModel.postImageUrl, postImageUrl.absoluteString != "" {
            contentView.addSubview(postImageOuterView)
            postImageOuterView.centerY(inView: contentView)
            postImageOuterView.anchor(left: infoLabel.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 12, width: 40, height: 40)
            
            postImageOuterView.addSubview(postImageView)
            postImageView.anchor(top: postImageOuterView.topAnchor, left: postImageOuterView.leftAnchor, bottom: postImageOuterView.bottomAnchor, right: postImageOuterView.rightAnchor)
            
            postImageView.isHidden = false
            postImageOuterView.isHidden = false
            followButton.isHidden = true
            postImageView.sd_setImage(with: postImageUrl, completed: nil)
        } else {
            contentView.addSubview(followButton)
            followButton.centerY(inView: infoLabel, constant: -4)
            followButton.anchor(left: infoLabel.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 12, height: 24)
            let followButtonWidthConstraint = followButton.widthAnchor.constraint(equalToConstant: 80)
            followButtonWidthConstraint.isActive = true
            
            followButton.isHidden = false
            postImageView.isHidden = true
            postImageOuterView.isHidden = true
            
            self.followButton.backgroundColor = .systemBlue
            self.followButton.setTitleColor(.systemBackground, for: .normal)
            
            if let isUserFollowed = viewModel.isUserFollowed {
                if isUserFollowed {
                    self.followButton.setTitle("Following", for: .normal)
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func handleFollowTapped() {
        guard let viewModel = viewModel, let isUserFollowed = viewModel.isUserFollowed else { return }
        if isUserFollowed {
            delegate?.cell(self, wantsToUnfollow: viewModel.ownerId)
        } else {
            delegate?.cell(self, wantsToFollow: viewModel.ownerId)
        }
    }
    
    @objc func handlePostTapped() {
        guard let postId = viewModel?.notification.postId else { return }
        delegate?.cell(self, wantsToViewPost: postId)
    }
    
    @objc func handleProfileImageTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToViewProfile: viewModel.ownerId)
    }
}
