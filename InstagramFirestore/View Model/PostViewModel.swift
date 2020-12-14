//
//  PostViewModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 12/12/20.
//

import Foundation

struct PostViewModel {
    private let post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var imageUrl: URL? {
        return URL(string: post.imageUrl)
    }
    
    var caption: String {
        return post.caption
    }
    
    var userProfilePicture: URL? {
        return URL(string: post.ownerProfilePicture)
    }
    
    var userFullName: String {
        return post.ownerFullName
    }
    
    var likes: String {
        if post.likes != 1 {
            return "\(post.likes) likes"
        } else {
            return "\(post.likes) like"
        }
    }
    
    var timestamp: String {
        let timeInSeconds = abs(Int(post.timestamp.dateValue().timeIntervalSinceNow))
        if timeInSeconds != 1 {
            if timeInSeconds <= 59 {
                return "\(timeInSeconds) seconds ago"
            } else {
                let timeInMinutes = abs(Int(post.timestamp.dateValue().timeIntervalSinceNow / 60))
                if timeInMinutes != 1 {
                    if timeInMinutes <= 59 {
                        return "\(timeInMinutes) minutes ago"
                    } else {
                        let timeInHours = abs(Int(post.timestamp.dateValue().timeIntervalSinceNow / 3600))
                        if timeInHours != 1 {
                            if timeInHours <= 23 {
                                return "\(timeInHours) hours ago"
                            } else {
                                let timeInDays = abs(Int(post.timestamp.dateValue().timeIntervalSinceNow / 3600 / 24))
                                if timeInDays != 1 {
                                    return "\(timeInDays) days ago"
                                } else  {
                                    return "\(timeInDays) day ago"
                                }
                            }
                        } else  {
                            return "\(timeInHours) hour ago"
                        }
                    }
                } else  {
                    return "\(timeInMinutes) minute ago"
                }
            }
        } else  {
            return "\(timeInSeconds) second ago"
        }
    }
}
