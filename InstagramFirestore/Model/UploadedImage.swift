//
//  ProfileModel.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 28/11/20.
//

import UIKit

class UploadedImage: Hashable {
    let id = UUID().uuidString
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: UploadedImage, rhs: UploadedImage) -> Bool {
      lhs.id == rhs.id
    }
}
