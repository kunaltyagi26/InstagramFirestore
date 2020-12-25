//
//  CommentCell.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 17/12/20.
//

import UIKit

class CommentCell: UITableViewCell {
    
    // MARK: - Properties
    
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
        iv.image = #imageLiteral(resourceName: "venom-7")
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
        self.addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingBottom: 8, paddingRight: 12)
        commentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        self.addSubview(outerProfileImageView)
        outerProfileImageView.centerY(inView: commentTextView)
        outerProfileImageView.anchor(left: leftAnchor, right: commentTextView.leftAnchor, paddingLeft: 12, paddingRight: 12, width: 40, height: 40)
        
        outerProfileImageView.addSubview(profileImageView)
        profileImageView.anchor(top: outerProfileImageView.topAnchor, left: outerProfileImageView.leftAnchor, bottom: outerProfileImageView.bottomAnchor, right: outerProfileImageView.rightAnchor)
        
        //commentTextView.delegate = self
        
        let username = "Venom"
        let comment = "By the Joker By the Joker By the Joker By the Joker By the Joker By the Joker By the Joker By the Joker By the Joker By the Joker By the Joker"
        let cellText = username + " " + comment
        commentTextView.text = cellText
        commentTextView.font = UIFont.systemFont(ofSize: 18)
        let url = URL(string: "https://www.apple.com")!
        
        if let range: Range<String.Index> = cellText.range(of: username) {
            let index: Int = cellText.distance(from: cellText.startIndex, to: range.lowerBound)
            
            let nameAttributes: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.foregroundColor: UIColor.label,
                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                        NSAttributedString.Key.link: url
            ]
            let commentAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.label.withAlphaComponent(0.8),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)
            ]
            let attributedString = NSMutableAttributedString(string: username, attributes: nameAttributes)
            attributedString.setAttributes([.foregroundColor: UIColor.label, .font : UIFont.boldSystemFont(ofSize: 15), .link: url], range: NSMakeRange(index, username.count))
            
            let commentString = NSAttributedString(string: comment, attributes: commentAttributes)
            attributedString.append(NSAttributedString(string: "  "))
            attributedString.append(commentString)
            commentTextView.attributedText = attributedString
            
            self.commentTextView.linkTextAttributes = [
                .foregroundColor: UIColor.label
            ]
        } else {
            print("substring not found")
        }
    }
}

extension CommentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("came in this method.")
        if (URL.absoluteString == "https://www.apple.com") {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        return false
    }
}


extension NSMutableAttributedString {
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(
            .font,
            in: NSRange(location: 0, length: self.length)
        ) { (value, range, stop) in

            if let f = value as? UIFont,
              let newFontDescriptor = f.fontDescriptor
                .withFamily(font.familyName)
                .withSymbolicTraits(f.fontDescriptor.symbolicTraits) {

                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: font.pointSize
                )
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(
                        .foregroundColor,
                        range: range
                    )
                    addAttribute(
                        .foregroundColor,
                        value: color,
                        range: range
                    )
                }
            }
        }
        endEditing()
    }
}
