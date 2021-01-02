//
//  NotificationService.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/12/20.
//

import Foundation
import Firebase

struct NotificationService {
    static func uploadNotification(toUid uid: String, type: NotificationType, post: Post? = nil) {
        let currentUserId = LoginManager.shared.uid
        guard uid != currentUserId else { return }
        let notificationId = UUID().uuidString
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": currentUserId,
                                   "type": type.rawValue,
                                   "id": notificationId,
                                   "ownerUsername": LoginManager.shared.username,
                                   "ownerProfilePicture": LoginManager.shared.profileImageUrl
                                  ]
        
        if let post = post {
            data["postId"] = post.id
            data["postImageUrl"] = post.imageUrl
        }
        
        notificationsCollection.document(uid).collection("user-notifications").document(notificationId).setData(data)
    }
    
    static func fetchNotifications(completion: @escaping(Result<[Notification], Error>)-> Void) {
        let currentUser = LoginManager.shared.uid
        var notifications: [Notification] = []
        let query = notificationsCollection.document(currentUser).collection("user-notifications").order(by: "timestamp", descending: false)
        query.addSnapshotListener { (snapshot, error) in
            if let snapshot = snapshot {
                snapshot.documentChanges.forEach({ (change) in
                    if change.type == .added {
                        let data = change.document.data()
                        let notification = Notification(dictionary: data)
                        notifications.append(notification)
                    }
                })
                completion(.success(notifications))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
