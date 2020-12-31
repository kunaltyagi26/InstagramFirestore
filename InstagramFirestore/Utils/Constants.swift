//
//  Constants.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 30/11/20.
//

import Firebase

let usersCollection = Firestore.firestore().collection("users")
let followersCollection = Firestore.firestore().collection("followers")
let followingCollection = Firestore.firestore().collection("following")
let postsCollection = Firestore.firestore().collection("posts")
let notificationsCollection = Firestore.firestore().collection("notifications")
