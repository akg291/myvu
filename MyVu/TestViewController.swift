//
//  TestViewController.swift
//  MyVu
//
//  Created by MacPro on 21/09/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire

class TestViewController: UIViewController, UISearchResultsUpdating, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView:UICollectionView!
    
    private static let minimumEdgePadding = CGFloat(90.0)
    private var dataItemsByGroup_ : [[Result]] = [[Result]]()
    private var resultMovieItems  = [Result]()
    var moviesRequest: Alamofire.Request?
    private var resultShowsItems  = [Result]()
    var shpowsRequest: Alamofire.Request?
    private let dataItemsByGroup: [[DataItem]] = {
        return DataItem.Group.allGroups.map { group in
            return DataItem.sampleItems.filter { $0.group == group }
        }
    }()
    

    
    override func viewDidLoad() {
        
        
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let filterString = searchController.searchBar.text ?? ""
        print(searchController.active)
        
        if !filterString.isEmpty {
            
            let searchUrl = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/search/movie/title/Akira"
            
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 4 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                
                Alamofire.request(.GET,searchUrl).responseObject {
                    (response: Response<MoviesSearchResultModel, NSError>) in
                    
                    
                }
                
            }
            
        }
        
    }
    

    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Our collection view displays 1 section per group of items.
        //print(dataItemsByGroup_.count)
        return dataItemsByGroup_.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        //print(section)
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CollectionViewContainerCell else { fatalError("Expected to display a `CollectionViewContainerCell`.") }
        // Configure the cell.
        let sectionDataItems = dataItemsByGroup_[indexPath.section]
        cell.APIrequestType = "Search"
        cell.parentViewController = self
        cell.configureWithDataItems(sectionDataItems,section: indexPath.section)
    }
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
         Return `false` because we don't want this `collectionView`'s cells to
         become focused. Instead the `UICollectionView` contained in the cell
         should become focused.
         */
        return false
    }
    func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = UICollectionReusableView()
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,withReuseIdentifier: "FlickrPhotoHeaderView",forIndexPath: indexPath) as! FlickerPhotoHeaderView
            if ( indexPath.row == 0 && indexPath.section == 0 ){
                headerView.label.text = "Movies"
            }else if ( indexPath.row == 0 && indexPath.section == 1 ){
                headerView.label.text = "Shows"
            }
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return view
    }

}
