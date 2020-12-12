//
//  UserCell.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/11/20.
//

import UIKit

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let outerProfileImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 50 / 2, shadowRadius: 3, shadowOffset: CGSize(width: 3.0, height: 3.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray2
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 50 / 2
        return iv
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemGray
        label.text = "Loading"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Loading"
        return label
    }()
    
    private var stackView = UIStackView()
    
    var user: UserCellViewModel? {
        didSet {
            configureData()
        }
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func setupView() {
        configureStackView()
        
        self.addSubview(outerProfileImageView)
        outerProfileImageView.centerY(inView: stackView)
        outerProfileImageView.anchor(left: leftAnchor, right: stackView.leftAnchor, paddingLeft: 12, paddingRight: 12, width: 50, height: 50)
        
        outerProfileImageView.addSubview(profileImageView)
        profileImageView.anchor(top: outerProfileImageView.topAnchor, left: outerProfileImageView.leftAnchor, bottom: outerProfileImageView.bottomAnchor, right: outerProfileImageView.rightAnchor)
    }
    
    func configureStackView() {
        stackView = UIStackView(arrangedSubviews: [usernameLabel, fullNameLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingBottom: 12, paddingRight: 12)
    }
    
    func configureData() {
        DispatchQueue.main.async {
            guard let user = self.user else { return }
            self.profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
            self.usernameLabel.text = user.username
            self.fullNameLabel.text = user.fullName
        }
    }
}
