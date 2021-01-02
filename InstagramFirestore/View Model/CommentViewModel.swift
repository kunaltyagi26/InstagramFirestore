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
    
    var timestamp: String {
        let timeInSeconds = abs(Int(comment.timestamp.dateValue().timeIntervalSinceNow))
        if timeInSeconds != 1 {
            if timeInSeconds <= 59 {
                return "\(timeInSeconds)s"
            } else {
                let timeInMinutes = abs(Int(comment.timestamp.dateValue().timeIntervalSinceNow / 60))
                if timeInMinutes != 1 {
                    if timeInMinutes <= 59 {
                        return "\(timeInMinutes)m"
                    } else {
                        let timeInHours = abs(Int(comment.timestamp.dateValue().timeIntervalSinceNow / 3600))
                        if timeInHours != 1 {
                            if timeInHours <= 23 {
                                return "\(timeInHours)h"
                            } else {
                                let timeInDays = abs(Int(comment.timestamp.dateValue().timeIntervalSinceNow / 3600 / 24))
                                if timeInDays != 1 {
                                    return "\(timeInDays)d"
                                } else  {
                                    return "\(timeInDays)d"
                                }
                            }
                        } else  {
                            return "\(timeInHours)h"
                        }
                    }
                } else  {
                    return "\(timeInMinutes)m"
                }
            }
        } else  {
            return "\(timeInSeconds)s"
        }
    }
    
    // MARK: - Lifecycle
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    // MARK: - Helpers
    
    func commentLabelText()-> NSAttributedString {
        let username = self.username
        let comment = commentText
        let timestamp = self.timestamp
        let cellText = username + " " + comment + " " + timestamp
        let url = URL(string: "\(self.comment.uid)")!
        
        if let range: Range<String.Index> = cellText.range(of: username) {
            let index: Int = cellText.distance(from: cellText.startIndex, to: range.lowerBound)
            let commentAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.label.withAlphaComponent(0.8),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)
            ]
            let timestampAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
            ]
            let attributedString = NSMutableAttributedString(string: username, attributes: nil)
            attributedString.setAttributes([.foregroundColor: UIColor.label, .font : UIFont.boldSystemFont(ofSize: 15), .link: url], range: NSMakeRange(index, username.count))
            
            let commentString = NSAttributedString(string: comment, attributes: commentAttributes)
            let timestampString = NSAttributedString(string: timestamp, attributes: timestampAttributes)
            
            attributedString.append(NSAttributedString(string: "  "))
            attributedString.append(commentString)
            attributedString.append(NSAttributedString(string: "  "))
            attributedString.append(timestampString)
            return attributedString
        } else {
            print("substring not found")
            return NSAttributedString(string: "")
        }
    }
}
