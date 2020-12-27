//
//  CommentViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 27/12/20.
//

import UIKit

struct CommentViewModel {
    
    // MARK: - Properties
    
    private let comment: Comment
    
    var profileImageURL: URL? {
        return URL(string: comment.profileImageUrl )
    }
    
    var username: String {
        return comment.username
    }
    
    var commentText: String {
        return comment.comment
    }
    
    // MARK: - Lifecycle
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    // MARK: - Helpers
    
    func commentLabelText()-> NSAttributedString {
        let username = self.username
        let comment = commentText
        let cellText = username + " " + comment
        let url = URL(string: "https://www.apple.com")!
        
        if let range: Range<String.Index> = cellText.range(of: username) {
            let index: Int = cellText.distance(from: cellText.startIndex, to: range.lowerBound)
            let commentAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.label.withAlphaComponent(0.8),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)
            ]
            let attributedString = NSMutableAttributedString(string: username, attributes: nil)
            attributedString.setAttributes([.foregroundColor: UIColor.label, .font : UIFont.boldSystemFont(ofSize: 15), .link: url], range: NSMakeRange(index, username.count))
            
            let commentString = NSAttributedString(string: comment, attributes: commentAttributes)
            attributedString.append(NSAttributedString(string: "  "))
            attributedString.append(commentString)
            return attributedString
        } else {
            print("substring not found")
            return NSAttributedString(string: "")
        }
    }
}
