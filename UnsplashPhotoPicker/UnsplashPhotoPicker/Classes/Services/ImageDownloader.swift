//
//  ImageDownloader.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-15.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit

class ImageDownloader {

    private var imageDataTask: URLSessionDataTask?
    private let urlCache = ImageCache.urlCache

    private(set) var isCancelled = false

    func downloadPhoto(with url: URL, isCaching: Bool = false, completion: @escaping ((UIImage?, Bool) -> Void)) {
        guard imageDataTask == nil else { return }

        isCancelled = false

        if isCaching, let cachedImage = ImageCache.imageCache.object(forKey: url.lastPathComponent as NSString) {
            return completion(cachedImage, true)
        }

        if let cachedResponse = urlCache.cachedResponse(for: URLRequest(url: url)),
            let image = UIImage(data: cachedResponse.data) {
            completion(image, true)
            return
        }

        imageDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            strongSelf.imageDataTask = nil

            guard let data = data, let response = response, let image = UIImage(data: data), error == nil else { return }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            strongSelf.urlCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))

            if isCaching {
                ImageCache.imageCache.setObject(image, forKey: url.lastPathComponent as NSString)
            }

            DispatchQueue.main.async {
                completion(image, false)
            }
        }

        imageDataTask?.resume()
    }

    func cancel() {
        isCancelled = true
        imageDataTask?.cancel()
    }

}
