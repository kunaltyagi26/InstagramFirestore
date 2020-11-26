//
//  ImageUploader.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 24/11/20.
//

import FirebaseStorage

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String?, Error?)-> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let fileName = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
        ref.putData(imageData, metadata: nil) { (metadata, error) in
            if error == nil {
                ref.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString, error == nil {
                        completion(downloadURL, nil)
                    } else {
                        completion(nil, error)
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
}
