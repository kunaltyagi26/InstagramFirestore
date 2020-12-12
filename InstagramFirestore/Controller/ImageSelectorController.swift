//
//  ImageSelectorController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 21/11/20.
//

import Foundation
import UIKit
import YPImagePicker

class ImageSelectorController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Select Image"
        self.view.backgroundColor = UIColor(named: "background")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentImagePicker()
    }
    
    // MARK: - Helpers
    
    func presentImagePicker() {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.shouldSaveNewPicturesToAlbum = true
        config.startOnScreen = .library
        config.screens = [.library]
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.library.maxNumberOfItems = 1
        
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
        didFinishPickingImage(picker)
    }
    
    func didFinishPickingImage(_ picker: YPImagePicker) {
        picker.didFinishPicking { [unowned picker] items, cancelled in
            DispatchQueue.main.async {
                if cancelled {
                    picker.dismiss(animated: true, completion: nil)
                    self.tabBarController?.selectedIndex = 0
                } else {
                    picker.dismiss(animated: true) {
                        guard let selectedImage = items.singlePhoto?.image else { return }
                        print("Selected image:", selectedImage)
                    }
                }
            }
        }
    }
}
