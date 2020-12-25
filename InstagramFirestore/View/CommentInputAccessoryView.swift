//
//  CommentInputAccessoryView.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 20/12/20.
//

import UIKit

protocol CommentInputAccessoryViewDelegate: AnyObject {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String)
}

class CommentInputAccessoryView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: CommentInputAccessoryViewDelegate?
    
    private let bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    let commentTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Enter Comment", textColor: .label)
        tf.font = UIFont.systemFont(ofSize: 15)
        return tf
    }()
    
    let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.label.withAlphaComponent(0.4), for: .normal)
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helpers
    
    func setupView() {
        autoresizingMask = .flexibleHeight
        self.backgroundColor = UIColor(named: "background")
        
        let divider = UIView()
        divider.backgroundColor = .systemGray
        addSubview(divider)
        divider.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
        addSubview(commentTextField)
        commentTextField.anchor(top: divider.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: 12, paddingBottom: 12)
        commentTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.80).isActive = true
        
        addSubview(postButton)
        postButton.anchor(left: commentTextField.rightAnchor, right: rightAnchor, paddingLeft: 0, paddingRight: 12)
        postButton.centerY(inView: commentTextField)
    }
    
    func clearCommentText() {
        commentTextField.text = nil
    }
    
    // MARK: - Actions
    
    @objc func didTapPost() {
        guard let text = commentTextField.text else { return }
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText != "" {
            delegate?.inputView(self, wantsToUploadComment: trimmedText)
        }
    }
}


