//
//  UnsplashPhotoPickerViewController+UICollectionView.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-15.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension UnsplashPhotoPickerViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath)

        guard let photoCell = cell as? PhotoCell, let photo = dataSource.item(at: indexPath.item) else { return cell }

        photoCell.delegate = self
        photoCell.configure(with: photo)

        return photoCell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PagingView.reuseIdentifier, for: indexPath)

        guard let pagingView = view as? PagingView else { return view }

        pagingView.isLoading = dataSource.isFetching

        return pagingView
    }
}

// MARK: - UICollectionViewDelegate
extension UnsplashPhotoPickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let prefetchCount = 19
        if indexPath.item == dataSource.items.count - prefetchCount {
            fetchNextItems()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell,
              let thumbnail = cell.photoView.previewImage,
              let unsplashPhoto = dataSource.item(at: indexPath.item),
              collectionView.hasActiveDrag == false else {
                return
        }

        UIView.animate(withDuration: 0.2, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
            }
        })

        let unsplashPhotoWithThumbnail = UnsplashPhotoWithThumbnail(thumbnail: thumbnail, unsplashPhoto: unsplashPhoto)
        delegate?.unsplashPhotoPickerViewController(self, didSelect: unsplashPhotoWithThumbnail)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension UnsplashPhotoPickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = dataSource.item(at: indexPath.item) else { return .zero }

        let width = collectionView.frame.width
        let height = CGFloat(photo.height) * width / CGFloat(photo.width)
        return CGSize(width: width, height: height)
    }
}

// MARK: - WaterfallLayoutDelegate
extension UnsplashPhotoPickerViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = dataSource.item(at: indexPath.item) else { return .zero }

        return CGSize(width: photo.width, height: photo.height)
    }
}

// MARK: - PhotoCellDelegate

extension UnsplashPhotoPickerViewController: PhotoCellDelegate {
    func photoCellDidRequestAttribution(_ sender: PhotoCell, photo: UnsplashPhoto) {
        delegate?.unsplashPhotoPickerViewController(self, didRequestAttribution: photo.user)
    }
}
