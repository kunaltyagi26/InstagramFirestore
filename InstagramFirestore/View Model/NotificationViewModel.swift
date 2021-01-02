//
//  NotificationViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/12/20.
//

import UIKit

struct NotificationViewModel {
    var notification: Notification
    
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
    
    var ownerId: String {
        return notification.uid
    }
    
    var timestamp: String {
        let timeInSeconds = abs(Int(notification.timestamp.dateValue().timeIntervalSinceNow))
        if timeInSeconds != 1 {
            if timeInSeconds <= 59 {
                return "\(timeInSeconds)s"
            } else {
                let timeInMinutes = abs(Int(notification.timestamp.dateValue().timeIntervalSinceNow / 60))
                if timeInMinutes != 1 {
                    if timeInMinutes <= 59 {
                        return "\(timeInMinutes)m"
                    } else {
                        let timeInHours = abs(Int(notification.timestamp.dateValue().timeIntervalSinceNow / 3600))
                        if timeInHours != 1 {
                            if timeInHours <= 23 {
                                return "\(timeInHours)h"
                            } else {
                                let timeInDays = abs(Int(notification.timestamp.dateValue().timeIntervalSinceNow / 3600 / 24))
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
    
    var isUserFollowed: Bool? {
        get {
            return notification.isUserFollowed
        }
        set {
            self.notification.isUserFollowed = newValue
        }
    }
    
    func notificationLabelText()-> NSAttributedString {
        let username = self.username
        let message = self.message
        let timestamp = self.timestamp
        let cellText = username + " " + message + " " + timestamp
        let url = URL(string: "\(self.notification.uid)")!
        
        if let range: Range<String.Index> = cellText.range(of: username) {
            let index: Int = cellText.distance(from: cellText.startIndex, to: range.lowerBound)
            let commentAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.label.withAlphaComponent(0.8),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)
            ]
            let timestampAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
            ]
            let attributedString = NSMutableAttributedString(string: username, attributes: nil)
            attributedString.setAttributes([.foregroundColor: UIColor.label, .font : UIFont.boldSystemFont(ofSize: 16), .link: url], range: NSMakeRange(index, username.count))
            let commentString = NSAttributedString(string: message, attributes: commentAttributes)
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
