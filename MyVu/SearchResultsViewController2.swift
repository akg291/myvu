/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A `UICollectionViewController` subclass that is used to show `DataItem` search results for the `UISearchController` shown by `SearchViewController`.
*/

import UIKit

protocol SearchResultsViewControllerDelegate2 {
    func reassureShowingList() -> Void
    func reassureShowing() -> Void
}

class SearchResultsViewController2: UICollectionViewController, UISearchResultsUpdating {
    
    var delegate: SearchResultsViewControllerDelegate2?
    
    // MARK: Properties
    static let storyboardIdentifier = "SearchResultsViewController2"

    private let cellComposer = DataItemCellComposer()

    private let allDataItems = DataItem.sampleItems
    
    private var filteredDataItems = DataItem.sampleItems
    
    var filterString = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }

            // Apply the filter or show all items if the filter string is empty.
            if filterString.isEmpty {
                filteredDataItems = allDataItems
            }
            else {
                filteredDataItems = allDataItems.filter { $0.title.localizedStandardContainsString(filterString) }
            }
            
            // Reload the collection view to reflect the changes.
            collectionView?.reloadData()
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filterString = searchController.searchBar.text ?? ""
        
        let query = searchController.searchBar.text!.trim()
        if !query.isEmpty {
            self.delegate?.reassureShowingList()
        }else {
            (searchController.searchResultsController as! UICollectionViewController).collectionView?.hidden = true
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataItems.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        return collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? DataItemCollectionViewCell2 else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
        let item = filteredDataItems[indexPath.row]
        
        // Configure the cell.
        cellComposer.composeCell(cell, withDataItem: item)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UISearchResultsUpdating
    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        
//    }
}