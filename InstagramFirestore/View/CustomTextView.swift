//
//  CustomTextView.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 08/12/20.
//

import UIKit

class CustomTextView: UITextView {
    
    // MARK: - Properties
    
    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 5.8, paddingLeft: 7)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidBeginEditing), name: UITextView.textDidBeginEditingNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidEndEditing), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func handleTextDidChange() {
        
    }
    
    @objc func handleTextDidBeginEditing() {
        placeholderLabel.isHidden = true
    }
    
    @objc func handleTextDidEndEditing() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
