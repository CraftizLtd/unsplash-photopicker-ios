//
//  PhotoView.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-11-06.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit

protocol PhotoViewDelegate: class {
    func photoViewDidRequestAttribution(_ sender: PhotoView)
}

class PhotoView: UIView {

    static var nib: UINib { return UINib(nibName: "PhotoView", bundle: Bundle(for: PhotoView.self)) }

    private var imageDownloader = ImageDownloader()
    private var screenScale: CGFloat { return UIScreen.main.scale }

    private(set) var photo: UnsplashPhoto?
    weak var delegate: PhotoViewDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var overlayViews: [UIView]!
    @IBOutlet var attributionButton: UIButton!

    var previewImage: UIImage? {
        return imageView?.image
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        accessibilityIgnoresInvertColors = true
    }

    func prepareForReuse() {
        imageView.backgroundColor = .clear
        imageView.image = nil
        imageDownloader.cancel()
    }

    // MARK: - Setup

    func configure(with photo: UnsplashPhoto) {
        self.photo = photo

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = photo.color
        attributionButton.setTitle(photo.user.displayName, for: .normal)
        
        downloadImage(with: photo)
    }

    private func downloadImage(with photo: UnsplashPhoto) {
        guard let regularUrl = photo.urls[.regular] else { return }

        let url = sizedImageURL(from: regularUrl)

        imageDownloader.downloadPhoto(with: url, isCaching: true, completion: { [weak self] (image, isCached) in
            guard let strongSelf = self, strongSelf.imageDownloader.isCancelled == false else { return }

            if isCached {
                strongSelf.imageView.image = image
            } else {
                UIView.transition(with: strongSelf, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    strongSelf.imageView.image = image
                }, completion: nil)
            }
        })
    }

    private func sizedImageURL(from url: URL) -> URL {
        let width: CGFloat = frame.width * screenScale
        let height: CGFloat = frame.height * screenScale

        return url.appending(queryItems: [
            URLQueryItem(name: "max-w", value: "\(width)"),
            URLQueryItem(name: "max-h", value: "\(height)")
        ])
    }

    // MARK: - Actions

    @IBAction func attributionButtonPressed(_ sender: Any) {
        delegate?.photoViewDidRequestAttribution(self)
    }

    // MARK: - Utility

    class func view(with photo: UnsplashPhoto) -> PhotoView? {
        guard let photoView = nib.instantiate(withOwner: nil, options: nil).first as? PhotoView else {
            return nil
        }

        photoView.configure(with: photo)

        return photoView
    }

}
