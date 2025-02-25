//
//  PhotoCell.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-07-26.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit

protocol PhotoCellDelegate: class {
    func photoCellDidRequestAttribution(_ sender: PhotoCell, photo: UnsplashPhoto)
}

class PhotoCell: UICollectionViewCell {

    // MARK: - Properties

    weak var delegate: PhotoCellDelegate?

    static let reuseIdentifier = "PhotoCell"

    let photoView: PhotoView = {
        // swiftlint:disable force_cast
        let photoView = (PhotoView.nib.instantiate(withOwner: nil, options: nil).first as! PhotoView)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        return photoView
    }()
    
    let badgeImageView: UIImageView = {
        let badgeImageView = UIImageView()
        badgeImageView.image = Configuration.shared.premiumBadge
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        return badgeImageView
    }()

    override var isHighlighted: Bool {
        didSet {
            let scale: CGFloat = isHighlighted ? 0.95 : 1.0
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    // MARK: - Lifetime

    override init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    private func postInit() {
        setupPhotoView()
        setupPremiumBadge()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.prepareForReuse()
    }

    // Override to bypass some expensive layout calculations.
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return .zero
    }

    // MARK: - Setup

    func configure(with photo: UnsplashPhoto) {
        photoView.delegate = self
        photoView.configure(with: photo)
        badgeImageView.isHidden = Configuration.shared.isSubscribed || photo.isFree
    }

    private func setupPhotoView() {
        contentView.preservesSuperviewLayoutMargins = true
        contentView.addSubview(photoView)
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupPremiumBadge() {
        contentView.preservesSuperviewLayoutMargins = true
        contentView.addSubview(badgeImageView)
        NSLayoutConstraint.activate([
            badgeImageView.centerXAnchor.constraint(equalTo: contentView.trailingAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: contentView.topAnchor),
        ])
    }

}

extension PhotoCell: PhotoViewDelegate {
    func photoViewDidRequestAttribution(_ sender: PhotoView) {
        guard let photo = sender.photo else {
            return
        }

        delegate?.photoCellDidRequestAttribution(self, photo: photo)
    }
}
