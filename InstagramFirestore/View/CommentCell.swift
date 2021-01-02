//
//  CommentCell.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 17/12/20.
//

import UIKit

class CommentCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: CommentViewModel? {
        didSet {
            populateComment()
        }
    }
    
    private let outerProfileImageView: UIView = {
        let outerView = UIView()
        outerView.applyshadowWithCorner(cornerRadius: 30 / 2, shadowRadius: 3, shadowOffset: CGSize(width: 3.0, height: 3.0), shadowOpacity: 1.0)
        return outerView
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray2
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 30 / 2
        return iv
    }()
    
    let commentTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        return textView
    }()
    
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
        contentView.addSubview(commentTextView)
        commentTextView.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 4, paddingBottom: 4, paddingRight: 12)
        commentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
        contentView.addSubview(outerProfileImageView)
        outerProfileImageView.centerY(inView: commentTextView)
        outerProfileImageView.anchor(left: contentView.leftAnchor, right: commentTextView.leftAnchor, paddingLeft: 12, paddingRight: 8, width: 30, height: 30)
        
        outerProfileImageView.addSubview(profileImageView)
        profileImageView.anchor(top: outerProfileImageView.topAnchor, left: outerProfileImageView.leftAnchor, bottom: outerProfileImageView.bottomAnchor, right: outerProfileImageView.rightAnchor)
    }
    
    func populateComment() {
        guard let viewModel = viewModel else { return }
        self.profileImageView.sd_setImage(with: viewModel.profileImageURL, completed: nil)
        
        commentTextView.font = UIFont.systemFont(ofSize: 18)
        commentTextView.attributedText = viewModel.commentLabelText()
        
        self.commentTextView.linkTextAttributes = [
            .foregroundColor: UIColor.label
        ]
    }
}
