//
//  UnsplashPhotoPickerConfiguration.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-09.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates configuration information for the behavior of UnsplashPhotoPicker.
public struct UnsplashPhotoPickerConfiguration {

    /// Your application’s access key.
    public var accessKey = ""

    /// Your application’s secret key.
    public var secretKey = ""

    /// A search query. When set, hides the search bar and shows results instead of the editorial photos.
    public var query: String?

    public var premiumBadge: UIImage? = nil
    
    public var isSubscribed: Bool = false

    /// The memory capacity used by the cache.
    public var memoryCapacity = defaultMemoryCapacity

    /// The disk capacity used by the cache.
    public var diskCapacity = defaultDiskCapacity

    /// The default memory capacity used by the cache.
    public static let defaultMemoryCapacity: Int = ImageCache.memoryCapacity

    /// The default disk capacity used by the cache.
    public static let defaultDiskCapacity: Int = ImageCache.diskCapacity

    /// The Unsplash API url.
    let apiURL = "https://api.unsplash.com/"

    /// The Unsplash editorial collection id.
    let editorialCollectionId = "317099"

    var viewBackgroundColor: UIColor = .red
    var cotainerBackgroundColor: UIColor = .purple
    var textFieldBackgroundColor: UIColor?
    var textColor: UIColor = .black
    var textPlaceholderColor: UIColor = .lightGray

    /**
     Initializes an `UnsplashPhotoPickerConfiguration` object with optionally customizable behaviors.

     - parameter accessKey:               Your application’s access key.
     - parameter secretKey:               Your application’s secret key.
     - parameter query:                   A search query.
     - parameter allowsMultipleSelection: Controls whether the picker allows multiple or single selection.
     - parameter memoryCapacity:          The memory capacity used by the cache.
     - parameter diskCapacity:            The disk capacity used by the cache.
     */
    public init(accessKey: String,
                secretKey: String,
                query: String? = nil,
                isSubscribed: Bool,
                premiumBadge: UIImage? = nil,
                textFieldBackgroundColor: UIColor,
                memoryCapacity: Int = defaultMemoryCapacity,
                diskCapacity: Int = defaultDiskCapacity,
                viewBackgroundColor: UIColor,
                cotainerBackgroundColor: UIColor,
                textColor: UIColor,
                textPlaceholderColor: UIColor) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.query = query
        self.isSubscribed = isSubscribed
        self.premiumBadge = premiumBadge
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.viewBackgroundColor = viewBackgroundColor
        self.cotainerBackgroundColor = cotainerBackgroundColor
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textColor = textColor
        self.textPlaceholderColor = textPlaceholderColor
    }

    init() {}

}
