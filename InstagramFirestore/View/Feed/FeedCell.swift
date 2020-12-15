//
//  FeedCell.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func handleUsernameClicked(viewModel: PostViewModel?)
}

class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            self.configureView()
        }
    }
    
    weak var delegate: FeedCellDelegate?
    
    private let outerProfileImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 40 / 2, shadowRadius: 3, shadowOffset: CGSize(width: 3.0, height: 3.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 40 / 2
        return iv
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapUsername), for: .touchUpInside)
        return button
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private let outerPostImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 20, shadowRadius: 10, shadowOffset: CGSize(width: 5.0, height: 5.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        return button
    }()
    
    private var stackView = UIStackView()
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "2 days ago"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func didTapUsername() {
        delegate?.handleUsernameClicked(viewModel: viewModel)
    }
    
    @objc func didTapLike() {
        
    }
    
    @objc func didTapComment() {
        
    }
    
    @objc func didTapShare() {
        
    }
    
    @objc func didTapBookmark() {
        
    }
    
    // MARK: - Helpers
    
    func setupView() {
        backgroundColor = UIColor(named: "background")
        layer.cornerRadius = 30
        self.applyshadowWithCorner(cornerRadius: 30, shadowRadius: 5, shadowOffset: CGSize(width: 5.0, height: 5.0), shadowOpacity: 0.5)
        
        addSubview(outerProfileImageView)
        outerProfileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12, width: 40, height: 40)
        
        outerProfileImageView.addSubview(profileImageView)
        profileImageView.anchor(top: outerProfileImageView.topAnchor, left: outerProfileImageView.leftAnchor, bottom: outerProfileImageView.bottomAnchor, right: outerProfileImageView.rightAnchor)
        
        addSubview(usernameButton)
        usernameButton.centerY(inView: outerProfileImageView, leftAnchor: outerProfileImageView.rightAnchor, paddingLeft: 8)
        
        addSubview(optionsButton)
        optionsButton.centerY(inView: outerProfileImageView)
        optionsButton.anchor(right: rightAnchor, paddingRight: 12)
        
        addSubview(outerPostImageView)
        outerPostImageView.anchor(top: outerProfileImageView.bottomAnchor, left: leftAnchor
                             , right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 12)
        outerPostImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        outerPostImageView.addSubview(postImageView)
        postImageView.anchor(top: outerPostImageView.topAnchor, left: outerPostImageView.leftAnchor, bottom: outerPostImageView.bottomAnchor, right: outerPostImageView.rightAnchor)
        
        configureActionButtons()
        
        addSubview(bookmarkButton)
        bookmarkButton.centerY(inView: stackView)
        bookmarkButton.anchor(right: rightAnchor, paddingRight: 12)
        
        addSubview(likesLabel)
        likesLabel.anchor(top: stackView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 12)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
    }
    
    func configureActionButtons() {
        stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        addSubview(stackView)
        stackView.anchor(top: outerPostImageView.bottomAnchor, left: leftAnchor, paddingTop: 24, paddingLeft: 12)
    }
    
    func configureView() {
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else { return }
            self.postImageView.sd_setImage(with: viewModel.imageUrl, completed: nil)
            self.captionLabel.text = viewModel.caption
            self.profileImageView.sd_setImage(with: viewModel.userProfilePicture, completed: nil)
            self.usernameButton.setTitle(viewModel.userFullName, for: .normal)
            self.likesLabel.text = "\(viewModel.likes)"
            self.postTimeLabel.text = "\(viewModel.timestamp)"
        }
    }
}
