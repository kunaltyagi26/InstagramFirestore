//
//  NotificationViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/12/20.
//

import UIKit

struct NotificationViewModel {
    let notification: Notification
    
    var username: String {
        return notification.ownerUsername
    }
    
    var message: String {
        return notification.type.notificationMessage
    }
    
    var ownerProfilePicture: URL? {
        return URL(string: notification.ownerProfilePicture)
    }
    
    var postImageUrl: URL? {
        return URL(string: notification.postImageUrl ?? "")
    }
    
    func notificationLabelText()-> NSAttributedString {
        let username = self.username
        let message = self.message
        let cellText = username + " " + message
        let url = URL(string: "https://www.apple.com")!
        
        if let range: Range<String.Index> = cellText.range(of: username) {
            let index: Int = cellText.distance(from: cellText.startIndex, to: range.lowerBound)
            let commentAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.label.withAlphaComponent(0.8),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)
            ]
            let attributedString = NSMutableAttributedString(string: username, attributes: nil)
            attributedString.setAttributes([.foregroundColor: UIColor.label, .font : UIFont.boldSystemFont(ofSize: 16), .link: url], range: NSMakeRange(index, username.count))
            
            let commentString = NSAttributedString(string: message, attributes: commentAttributes)
            attributedString.append(NSAttributedString(string: "  "))
            attributedString.append(commentString)
            return attributedString
        } else {
            print("substring not found")
            return NSAttributedString(string: "")
        }
    }
}
