//
//  UIButton + Extensions.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 22/11/20.
//

import UIKit

extension UIButton {
    func attributedTitle(firstPart: String, secondPart: String) {
        let attributedString: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBackground.withAlphaComponent(0.87), .font: UIFont.systemFont(ofSize: 17)]
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: attributedString)
        
        let boldAttributedString: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBackground.withAlphaComponent(0.87), .font: UIFont.boldSystemFont(ofSize: 18)]
        let boldAttributedTitle = NSMutableAttributedString(string: secondPart, attributes: boldAttributedString)
        
        attributedTitle.append(boldAttributedTitle)
        setAttributedTitle(attributedTitle, for: .normal)
    }
}
