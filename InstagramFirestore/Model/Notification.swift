//
//  Notification.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/12/20.
//

import Foundation
import Firebase

enum NotificationType: Int {
    case like
    case follow
    case comment
    
    var notificationMessage: String {
        switch self {
        case .like:
            return "liked your post."
        case .follow:
            return "started following you."
        case .comment:
            return "commented on your post."
        }
    }
}

struct Notification {
    let id: String
    let uid: String
    var postImageUrl: String?
    var postId: String?
    let timestamp: Timestamp
    let type: NotificationType
    let ownerProfilePicture: String
    let ownerUsername: String
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.postId = dictionary["postId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .like
        self.ownerProfilePicture = dictionary["ownerProfilePicture"] as? String ?? ""
        self.ownerUsername = dictionary["ownerUsername"] as? String ?? ""
    }
}
