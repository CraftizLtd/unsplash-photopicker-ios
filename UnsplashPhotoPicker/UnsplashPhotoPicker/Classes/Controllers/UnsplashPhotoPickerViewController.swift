//
//  UnsplashPhotoPickerViewController.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-09.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit

public protocol UnsplashPhotoPickerViewControllerDelegate: class {
    func unsplashPhotoPickerViewController(_ viewController: UnsplashPhotoPickerViewController, didSelect unsplashPhotoWithThumbnail: UnsplashPhotoWithThumbnail)
    func unsplashPhotoPickerViewController(_ viewController: UnsplashPhotoPickerViewController, didRequestAttribution user: UnsplashUser)
}

public class UnsplashPhotoPickerViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.placeholder = "Search Photos"
        searchBar.isTranslucent = false
        searchBar.tintAdjustmentMode = .normal
        searchBar.tintColor = UIColor.black
        return searchBar
    }()
    
    private lazy var searchBarContainerView: UIView = {
        let searchBarContainerView = UIView()
        searchBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchBarContainerView.backgroundColor = .clear
        return searchBarContainerView
    }()
    
    private lazy var layout = WaterfallLayout(with: self)
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.register(PagingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PagingView.reuseIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        collectionView.backgroundColor = .clear//UIColor.photoPicker.background
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var dataSource: PagedDataSource {
        didSet {
            oldValue.cancelFetch()
            dataSource.delegate = self
        }
    }
    
    private let editorialDataSource = PhotosDataSourceFactory.collection(identifier: Configuration.shared.editorialCollectionId).dataSource
    
    private var previewingContext: UIViewControllerPreviewing?
    private var searchText: String?
    
    public weak var delegate: UnsplashPhotoPickerViewControllerDelegate?
    
    // MARK: - Lifetime
    public init(configuration: UnsplashPhotoPickerConfiguration) {
        Configuration.shared = configuration
        self.dataSource = editorialDataSource
        super.init(nibName: nil, bundle: nil)
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Configuration.shared.backgroundColor
        setupNotifications()
        setupSearchBar()
        setupCollectionView()
        setupSpinner()
        setupPeekAndPop()
        
        setSearchText(nil)
        refresh()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupSearchBar() {
        
        let searchTextField: UITextField

        
        let placeholderColor = UIColor(displayP3Red: 149/255, green: 153/255, blue: 158/255, alpha: 1)
        let textColor = UIColor(displayP3Red: 62/255, green: 66/255, blue: 71/255, alpha: 1)
        let font =  UIFont.systemFont(ofSize: 14)
        
        let defaultPlaceholderTextAttributes = [
                       NSAttributedString.Key.font: font,
                       NSAttributedString.Key.foregroundColor:  placeholderColor
                    ]
        let defaultPlaceholderText = "Search Photos"
        let defualtPlaceholderAttributedText = NSAttributedString(string: defaultPlaceholderText, attributes: defaultPlaceholderTextAttributes)
    
        
        if #available(iOS 13, *) {
            searchTextField = searchBar.searchTextField
        } else {
            searchTextField = (searchBar.value(forKey: "searchField") as? UITextField) ?? UITextField()
        }
        
        searchTextField.attributedPlaceholder = defualtPlaceholderAttributedText
        
        searchTextField.textColor = textColor
        searchTextField.font = font
        searchTextField.borderStyle = .none
        let leftView = (searchTextField.leftView as? UIImageView)
        leftView?.image = UIImage(named: "search")
        leftView?.image = leftView?.image?.withRenderingMode(.alwaysTemplate)
        leftView?.tintColor = placeholderColor

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(defaultPlaceholderTextAttributes, for: .normal)
        searchTextField.tintColor = placeholderColor
        searchTextField.layer.cornerRadius = 6
        searchTextField.clipsToBounds = true
        
        searchBarContainerView.addSubview(searchBar)

        view.addSubview(searchBarContainerView)
        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: searchBarContainerView.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: searchBarContainerView.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: searchBarContainerView.topAnchor),
            searchBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            searchBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            searchBarContainerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        searchBarContainerView.clipsToBounds = false
        searchBarContainerView.backgroundColor = Configuration.shared.basketBackgroundColor
        
        if let searchBarTextFieldBackgroundColor = Configuration.shared.searchBarTextFieldBackgroundColor?.withAlphaComponent(0.8) {
            searchTextField.backgroundColor = searchBarTextFieldBackgroundColor
            searchTextField.layer.backgroundColor = searchBarTextFieldBackgroundColor.cgColor
            searchBarContainerView.backgroundColor = searchBarTextFieldBackgroundColor
        }

    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor, constant: 0),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func setupSpinner() {
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
    
    private func setupPeekAndPop() {
        previewingContext = registerForPreviewing(with: self, sourceView: collectionView)
    }
    
    private func showEmptyView(with state: EmptyViewState) {
        emptyView.state = state
        
        guard emptyView.superview == nil else { return }
        
        spinner.stopAnimating()
        
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor),
            emptyView.leftAnchor.constraint(equalTo: view.leftAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func hideEmptyView() {
        emptyView.removeFromSuperview()
    }
    
    
    private func scrollToTop() {
        let contentOffset = CGPoint(x: 0, y: -collectionView.safeAreaInsets.top)
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    
    // MARK: - Data
    
    private func setSearchText(_ text: String?) {
        if let text = text, text.isEmpty == false {
            dataSource = PhotosDataSourceFactory.search(query: text).dataSource
            searchText = text
        } else {
            dataSource = editorialDataSource
            searchText = nil
        }
    }
    
    @objc func refresh() {
        guard dataSource.items.isEmpty else { return }
        
        if dataSource.isFetching == false && dataSource.items.count == 0 {
            dataSource.reset()
            reloadData()
            fetchNextItems()
        }
    }
    
    public func update(isSubscribed: Bool) {
        Configuration.shared.isSubscribed = isSubscribed
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    func fetchNextItems() {
        dataSource.fetchNextPage()
    }
    
    private func fetchNextItemsIfNeeded() {
        if dataSource.items.count == 0 {
            fetchNextItems()
        }
    }
    
    // MARK: - Notifications
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return
        }
        
        let bottomInset = keyboardSize.height - view.safeAreaInsets.bottom
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.collectionView.contentInset = contentInsets
            self?.collectionView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.collectionView.contentInset = .zero
            self?.collectionView.scrollIndicatorInsets = .zero
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension UnsplashPhotoPickerViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        setSearchText(text)
        refresh()
        scrollToTop()
        hideEmptyView()
        view.endEditing(true)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.searchText != nil && searchText.isEmpty else { return }
        setSearchText(nil)
        refresh()
        reloadData()
        scrollToTop()
        hideEmptyView()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        setSearchText(nil)
        refresh()
        reloadData()
        scrollToTop()
        hideEmptyView()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension UnsplashPhotoPickerViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - PagedDataSourceDelegate
extension UnsplashPhotoPickerViewController: PagedDataSourceDelegate {
    func dataSourceWillStartFetching(_ dataSource: PagedDataSource) {
        if dataSource.items.count == 0 {
            spinner.startAnimating()
        }
    }
    
    func dataSource(_ dataSource: PagedDataSource, didFetch items: [UnsplashPhoto]) {
        guard dataSource.items.count > 0 else {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.showEmptyView(with: .noResults)
            }
            
            return
        }
        
        let newPhotosCount = items.count
        let startIndex = self.dataSource.items.count - newPhotosCount
        let endIndex = startIndex + newPhotosCount
        var newIndexPaths = [IndexPath]()
        for index in startIndex..<endIndex {
            newIndexPaths.append(IndexPath(item: index, section: 0))
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.spinner.stopAnimating()
            self.hideEmptyView()
            
            let hasWindow = self.collectionView.window != nil
            let collectionViewItemCount = self.collectionView.numberOfItems(inSection: 0)
            if hasWindow && collectionViewItemCount < dataSource.items.count {
                self.collectionView.insertItems(at: newIndexPaths)
            } else {
                self.reloadData()
            }
        }
    }
    
    func dataSource(_ dataSource: PagedDataSource, fetchDidFailWithError error: Error) {
        let state: EmptyViewState = (error as NSError).isNoInternetConnectionError() ? .noInternetConnection : .serverError
        
        DispatchQueue.main.async {
            self.showEmptyView(with: state)
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension UnsplashPhotoPickerViewController: UIViewControllerPreviewingDelegate {
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: location),
            let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell,
            let image = cell.photoView.imageView.image else {
                return nil
        }
        previewingContext.sourceRect = cellAttributes.frame
        return UnsplashPhotoPickerPreviewViewController(image: image)
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }
}

