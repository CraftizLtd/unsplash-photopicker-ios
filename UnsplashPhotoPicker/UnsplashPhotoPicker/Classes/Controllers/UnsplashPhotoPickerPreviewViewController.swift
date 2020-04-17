//
//  UnsplashPhotoPickerPreviewViewController.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-11-04.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit
import AVFoundation

class UnsplashPhotoPickerPreviewViewController: UIViewController {

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let image: UIImage
    private let ratio: CGSize
    
    init(image: UIImage) {
        self.image = image
        ratio = .init(width: image.size.width / image.size.height, height: 1)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(photoImageView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxFitFrame = AVMakeRect(aspectRatio: ratio, insideRect: view.bounds)
        preferredContentSize = maxFitFrame.size
        photoImageView.frame = maxFitFrame
    }

}
