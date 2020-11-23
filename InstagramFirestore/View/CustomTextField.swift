//
//  CustomTextField.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 22/11/20.
//

import UIKit

class CustomTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        
        borderStyle = .none
        textColor = .systemBackground
        keyboardType = .emailAddress
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.1)
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.systemBackground.withAlphaComponent(0.7)])
        layer.cornerRadius = 10
        
        setHeight(50)
        setLeftPaddingPoints(15)
        setRightPaddingPoints(15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
