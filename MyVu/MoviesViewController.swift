//
//  Movies.swift
//  Video App
//
//  Created by Brian Coleman on 2015-10-10.
//  Copyright © 2015 Brian Coleman. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class MoviesViewController: UIViewController, UISearchResultsUpdating , UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var collectionView1 : UICollectionView!
    @IBOutlet var collectionView2 : UICollectionView!
    @IBOutlet var collectionView3 : UICollectionView!
    @IBOutlet var collectionView4 : UICollectionView!
    let reuseIdentifierFeatured = "FeaturedCell"
    let reuseIdentifierStandard = "StandardCell"
    
    
    var movie:NSArray = NSArray()
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
    
    var filterString = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }
            filterString = filterString.stringByReplacingOccurrencesOfString(" ", withString: "")
            // Apply the filter or show all items if the filter string is empty.
            if filterString.isEmpty {
                //filteredDataItems = allDataItems
                self.moviesRequest?.cancel()
                self.shpowsRequest?.cancel()
                dataItemsByGroup_ = [[Result]]()
                self.collectionView1!.reloadData()
            }
            else {
                self.moviesRequest?.cancel()
                self.shpowsRequest?.cancel()
                dataItemsByGroup_ = [[Result]]()
                self.collectionView2!.reloadData()
                let searchUrl = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/search/movie/title/" + self.filterString

                
                print("\n \n \n URL \(searchUrl) \n \n \n")
                
                print("\n \n \n Movie Request \(moviesRequest) \n \n \n")
                
                
                moviesRequest = Alamofire.request(.GET,searchUrl).responseObject {
                    (response: Response<MoviesSearchResultModel, NSError>) in
                    
                    let apiResponce = response.result.value
                    
                    if ( apiResponce?.results?.count > 0 ){
                        
                        self.resultMovieItems = [Result]()
                        for result in (apiResponce?.results)! {
                            result.group = "Movies"
                            self.resultMovieItems.append(result)
                        }
                        
                        self.collectionView1.reloadData()
                        
                    }
                }
                
                let searchUrl_ = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/search/title/" + self.filterString
                self.shpowsRequest = Alamofire.request(.GET,searchUrl_).responseObject {
                    (response: Response<MoviesSearchResultModel, NSError>) in
                    let apiResponce = response.result.value
                    if ( apiResponce?.results?.count > 0 ){
                        for result in (apiResponce?.results)! {
                            result.group = "Shows"
                            self.resultShowsItems.append(result)
                        }
                        
                        self.collectionView2.reloadData()
                    }
                }
                
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView1.delegate = self
        collectionView2.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView!.contentSize = CGSizeMake(1920, 2200)
    }

    // Collection View Methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0.0, left: 50.0, bottom: 0.0, right: 50.0)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if (collectionView == self.collectionView1)
        {
            return resultMovieItems.count
        }
        else
        {
            return resultShowsItems.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath)
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CollectionViewContainerCell else { fatalError("Expected to display a `CollectionViewContainerCell`.") }
        // Configure the cell.
        let sectionDataItems = dataItemsByGroup_[indexPath.section]
        cell.APIrequestType = "Search"
        cell.parentViewController = self
        cell.configureWithDataItems(sectionDataItems,section: indexPath.section)
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filterString = searchController.searchBar.text ?? ""
        
        print(searchController.searchBar.text)
        
        let query = searchController.searchBar.text!.trim()
        if !query.isEmpty {
            //self.delegate?.show1()
        }else {
            //self.delegate?.show2()
        }
        
        
    }
    
}
