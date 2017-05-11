//
//  ViewController.swift
//  HelloWorld
//
//  Created by MacPro on 22/07/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    // MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewA: UICollectionView!
    
    let moviesContentUrl = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/movies/all/0/25/all/all"
    let showsContentUrl = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/shows/all/0/25/all/all"
    
    enum Group: String {
        case Movies
        case Shows
        static let allGroups: [Group] = [.Movies, .Shows]
    }
    
    private static let minimumEdgePadding = CGFloat(90.0)
    private var dataItemsByGroup_ : [[Result]] = [[Result]]()
    private var dataItemsByGroup__ : [[Result]] = [[Result]]()
    
    private let dataItemsByGroup: [[DataItem]] = {
        return DataItem.Group.allGroups.map { group in
            return DataItem.sampleItems.filter { $0.group == group }
        }
    }()
    
    private var resultMovieItems  = [Result]()
    var moviesRequest: Alamofire.Request?
    
    private var resultShowsItems  = [Result]()
    var shpowsRequest: Alamofire.Request?
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "search-bg.png")!)
        
        moviesRequest = Alamofire.request(.GET,moviesContentUrl).responseObject {
            
            (response: Response<MoviesSearchResultModel, NSError>) in
            
            let apiResponce = response.result.value
            if ( apiResponce?.results?.count > 0 ){
                
                self.resultMovieItems = [Result]()
                for result in (apiResponce?.results)! {
                    result.group = "Movies"
                    self.resultMovieItems.append(result)
                }
                self.dataItemsByGroup_.append(self.resultMovieItems)
                self.collectionView!.reloadData()

                
            }else if ( apiResponce?.results?.count < 0 ){
                
            }else {
                print(apiResponce?.toJSONString())
            }
        }
        
        //self.shpowsRequest?.cancel()
        shpowsRequest = Alamofire.request(.GET,showsContentUrl).responseObject {
            
            (response: Response<MoviesSearchResultModel, NSError>) in
            
            let apiResponce = response.result.value
            if ( apiResponce?.results?.count > 0 ){
                
                //self.resultShowsItems = [Result]()
                
                for result in (apiResponce?.results)! {
                    result.group = "Shows"
                    self.resultShowsItems.append(result)
                }
                self.dataItemsByGroup__.append(self.resultShowsItems)
                self.collectionViewA!.reloadData()
                
    
            }else if ( apiResponce?.results?.count < 0 ){
                
            }else {
                print(apiResponce?.toJSONString())
            }
        }
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionViewA.delegate = self
        collectionViewA.dataSource = self

    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Our collection view displays 1 section per group of items.
        print(dataItemsByGroup_.count)
        
        if (collectionView == collectionViewA ){
            return dataItemsByGroup__.count
        }else {
            return dataItemsByGroup_.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        print(section)
        if (collectionView == collectionViewA ){
            return 1
        }else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CollectionViewContainerCell else { fatalError("Expected to display a `CollectionViewContainerCell`.") }
        
        // Configure the cell.
        var sectionDataItems = []
        if (collectionView == collectionViewA ){
            sectionDataItems = dataItemsByGroup__[indexPath.section]
        }else {
            sectionDataItems = dataItemsByGroup_[indexPath.section]
        }
        
        //**cell.configureWithDataItems(sectionDataItems as! [Result],section: indexPath.section)
    }
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
         Return `false` because we don't want this `collectionView`'s cells to
         become focused. Instead the `UICollectionView` contained in the cell
         should become focused.
         */
        return false
    }
}

