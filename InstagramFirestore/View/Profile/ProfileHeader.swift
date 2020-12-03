//
//  ProfileHeader.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 28/11/20.
//

import UIKit
import SDWebImage
import FirebaseAuth

protocol ProfileHeaderDelegate: class {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var viewModel: ProfileHeaderViewModel? {
        didSet {
            configureData()
        }
    }
    
    private let outerProfileImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 70 / 2, shadowRadius: 3, shadowOffset: CGSize(width: 3.0, height: 3.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray2
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 70 / 2
        return iv
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private let postsLabel: UILabel = {
        let label = UILabel()
        label.text = "8"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    private let postsStringLabel: UILabel = {
        let label = UILabel()
        label.text = "Posts"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    private let followersStringLabel: UILabel = {
        let label = UILabel()
        label.text = "Followers"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray
        return label
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    private let followingStringLabel: UILabel = {
        let label = UILabel()
        label.text = "Following"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray
        return label
    }()
    
    private var stackView = UIStackView()
    private var postsStackView = UIStackView()
    private var followersStackView = UIStackView()
    private var followingStackView = UIStackView()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.backgroundColor = UIColor(named: "background")
        button.tintColor = .label
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.label.withAlphaComponent(0.3).cgColor
        button.applyshadowWithCorner(cornerRadius: 8, shadowRadius: 3, shadowOffset: CGSize(width: 0.0, height: 0.0), shadowOpacity: 0.5)
        button.addTarget(self, action: #selector(didTapEditProfile), for: .touchUpInside)
        return button
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.label.withAlphaComponent(0.3)
        return view
    }()
    
    private var actionStackView = UIStackView()
    
    private lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.grid.4x3.fill"), for: .normal)
        button.tintColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(didTapGrid), for: .touchUpInside)
        return button
    }()
    
    private lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = UIColor.label.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(didTapList), for: .touchUpInside)
        return button
    }()
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = UIColor.label.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: ProfileHeaderDelegate?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // We need to set the border color here as cgColor doesn't automatically adopt to Dark Mode changes.
        self.editProfileButton.layer.borderColor = UIColor.label.withAlphaComponent(0.7).cgColor
    }
    
    // MARK: - Helpers
    
    func setupView() {
        self.backgroundColor = UIColor(named: "background")
        self.addSubview(outerProfileImageView)
        outerProfileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12, width: 70, height: 70)
        
        outerProfileImageView.addSubview(profileImageView)
        profileImageView.anchor(top: outerProfileImageView.topAnchor, left: outerProfileImageView.leftAnchor, bottom: outerProfileImageView.bottomAnchor, right: outerProfileImageView.rightAnchor)
        
        addSubview(fullNameLabel)
        fullNameLabel.anchor(top: outerProfileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 14)
        
        configureStackView()
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: fullNameLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 16, paddingRight: 16)
        
        addSubview(divider)
        divider.anchor(top: editProfileButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 18)
        divider.setHeight(1)
        
        configureActionStackView()
    }
    
    func configureStackView() {
        postsStackView = UIStackView(arrangedSubviews: [postsLabel, postsStringLabel])
        postsStackView.axis = .vertical
        postsStackView.distribution = .fillEqually
        postsStackView.spacing = 8
        
        followersStackView = UIStackView(arrangedSubviews: [followersLabel, followersStringLabel])
        followersStackView.axis = .vertical
        followersStackView.distribution = .fillEqually
        followersStackView.spacing = 8
        
        followingStackView = UIStackView(arrangedSubviews: [followingLabel, followingStringLabel])
        followingStackView.axis = .vertical
        followingStackView.distribution = .fillEqually
        followingStackView.spacing = 8
        
        stackView = UIStackView(arrangedSubviews: [postsStackView, followersStackView, followingStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        
        addSubview(stackView)
        stackView.centerY(inView: outerProfileImageView)
        stackView.anchor(left: outerProfileImageView.rightAnchor,right: rightAnchor, paddingLeft: 12, paddingRight: 12)
    }
    
    func configureActionStackView() {
        actionStackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        actionStackView.axis = .horizontal
        actionStackView.distribution = .fillEqually
        
        addSubview(actionStackView)
        actionStackView.anchor(top: divider.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12)
    }
    
    func configureData() {
        if let viewModel = viewModel {
            self.fullNameLabel.text = viewModel.fullName
            self.profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
            editProfileButton.setTitle(viewModel.followButtonText, for: .normal)
            editProfileButton.backgroundColor = viewModel.followButtonBackgroundColor
            editProfileButton.setTitleColor(viewModel.followButtonTitleColor, for: .normal)
            followersLabel.text = viewModel.numberOfFollowers
            followingLabel.text = viewModel.numberOfFollowing
        }
    }
    
    func updateUIForEditProFileButton() {
        if let isFollowed = viewModel?.user.isFollowed {
            viewModel?.user.isFollowed = !isFollowed
            configureData()
        }
    }
    
    func highlightButton(selectedButton: UIButton) {
        let buttons = [gridButton, listButton, bookmarkButton]
        for button in buttons {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    button.tintColor = (button == selectedButton) ? UIColor.systemBlue : UIColor.label.withAlphaComponent(0.3)
                }
            }
        }
    }
    
    func getHeight()-> CGFloat {
        let profileTop: CGFloat = 12.0
        let profileHeight = outerProfileImageView.frame.height
        let usernameTop: CGFloat = 12.0
        let usernameHeight = fullNameLabel.frame.height
        let editTop: CGFloat = 12.0
        let editHeight = editProfileButton.frame.height
        let dividerTop: CGFloat = 18.0
        let dividerHeight: CGFloat = 1.0
        let actionTop: CGFloat = 12.0
        let actionHeight = actionStackView.frame.height
        let actionBottom: CGFloat = 12.0
        
        let profile = profileTop + profileHeight
        let username = usernameTop + usernameHeight
        let edit = editTop + editHeight
        let divider = dividerTop + dividerHeight
        let action = actionTop + actionHeight + actionBottom
        
        return profile + username + edit + divider + action
    }
    
    // MARK: - Actions
    
    @objc func didTapEditProfile() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapActionButtonFor: viewModel.user)
    }
    
    @objc func didTapGrid(sender: UIButton) {
        highlightButton(selectedButton: sender)
    }
    
    @objc func didTapList(sender: UIButton) {
        highlightButton(selectedButton: sender)
    }
    
    @objc func didTapBookmark(sender: UIButton) {
        highlightButton(selectedButton: sender)
    }
}
