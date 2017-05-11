//
//  CollectionViewContainerCell_Old.swift
//  MyVu
//
//  Created by MacPro on 29/09/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A `UICollectionViewCell` subclass that contains a `UICollectionView`. This class demonstrates how to ensure the focus is passed to the contained collection view.
 */

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage



class CollectionViewContainerCellOld: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var moviesImageCache = [String:UIImage]()
    var showsImageCache = [String:UIImage]()
    
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var alamofireManager : Alamofire.Manager?
    var apiLoadMore     : Alamofire.Request?
    
    var parentViewController : UIViewController!
    var cellType : String = ""
    var APIrequestType : String = ""
    var internalReload = false
    var nextUrl:String = "" {
        didSet{
            guard nextUrl != oldValue && !(nextUrl.isEmpty) else {
                return
            }
        }
    }

    var collectionType : String = ""
    // MARK: Properties
    static let reuseIdentifier = "CollectionViewContainerCellOld"
    @IBOutlet var collectionView: UICollectionView!
    
    private var dataItems = [DataItem]()
    private var dataItems_ = [ItemModel]()
    private var episodesDataModels = [EpisodeModel]()
    private let cellComposer = DataItemCellComposer()
    private var layout: UICollectionViewFlowLayout!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal

        layout.sectionInset = UIEdgeInsets(top: 0, left: 90, bottom: 50, right: 90)
        layout.itemSize = CGSize(width: 400 , height:290)
        layout.minimumLineSpacing = 100
        self.collectionView.collectionViewLayout = layout
        self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 390)
        
    }
    
    func requestCellData(data:[EpisodeModel]){
        episodesDataModels = data
        self.collectionView.reloadData()
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

    }
    
    // MARK: Configuration
    
    func configureWithDataItems(dataItems:[ItemModel], section:Int) {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        //layout.sectionInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 90)
        //layout.minimumInteritemSpacing = 0
        
        print(section)
        
        if ( section == 0 ){
            self.cellType = "movies"
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 90)
            layout.itemSize = CGSize(width: 240 , height:390)
            layout.minimumLineSpacing = 100
            self.collectionView.collectionViewLayout = layout
            self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 390)
			
        } else if ( section == 1 ){
			
			
			self.cellType = "shows"
			layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 90)
			layout.itemSize = CGSize(width: 448 , height: 290)
			layout.minimumLineSpacing = 100
			self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 290)
			self.collectionView.collectionViewLayout = layout
			
        } else {
            self.cellType = "episode"
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 90)
            layout.itemSize = CGSize(width: 448 , height: 290)
            layout.minimumLineSpacing = 100
            self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 290)
            self.collectionView.collectionViewLayout = layout
        }

        self.dataItems_ = dataItems
        
        if !internalReload{
            collectionView.reloadData()
        }

        self.loadingLabel.hidden = true
        self.activityIndicator.stopAnimating()
        
    }
    
    func configureWithDataItems(dataItems: [DataItem]) {
        self.dataItems = dataItems
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if ( cellType == "episode" ){
			print(episodesDataModels.count)
            return episodesDataModels.count
        }else {
            return dataItems_.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        switch self.cellType {
        case "movies":
            let temp = collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
            cell = temp
		break
            
        case "shows":
            let temp = collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell_.reuseIdentifier, forIndexPath: indexPath)
            cell = temp
		break
			
		case "episode":
			let temp = collectionView.dequeueReusableCellWithReuseIdentifier(SeasonEpisodeViewCell.reuseIdentifier, forIndexPath: indexPath)
			cell = temp
		break
			
        default: break
            
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		
		//print(dataItems_[indexPath.row].type)
		
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if ( cellType == "episode" ){
            //return episodesDataModels.count
            
            guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ShowDetailsVC") as? ShowDetailsVC else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
            }
            
            detailScreen.showID = String(self.episodesDataModels[indexPath.row].id!)
            detailScreen.cellType = "episodes"
            parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
            
            if ( APIrequestType == "Search" ){
                parentViewController.presentingViewController?.navigationController?.pushViewController(detailScreen, animated: true)
            }

        } else {
            if ( cellType == "movies"){
                
                guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("PartitionedMovieDetailVC") as? PartitionedMovieDetailVC else {
                    fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
                }
                detailScreen.movieId = String(dataItems_[indexPath.row].id!)
                detailScreen.cellType = "movies"
                print(detailScreen.movieId)
                parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
                
                if ( APIrequestType == "Search" ){
                    parentViewController.presentingViewController?.navigationController?.pushViewController(detailScreen, animated: true)
                }
                
            } else {
                
                guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ShowDetailsVC") as? ShowDetailsVC else {
                    fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
                }
                
                dataItems_[indexPath.row].display()
                
                detailScreen.showID = String(dataItems_[indexPath.row].id!)
                detailScreen.cellType = "shows"
                parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
                
                if ( APIrequestType == "Search" ){
                    parentViewController.presentingViewController?.navigationController?.pushViewController(detailScreen, animated: true)
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        
        if !internalReload {
            return NSIndexPath(forRow: 0, inSection: 0)
        } else {
            return nil
        }
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if ( cellType == "episode" ){
            guard let cell = cell as? SeasonEpisodeViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
            let item = episodesDataModels[indexPath.row]
			
			// Configure the cell.
            cellComposer.composeCell(cell, withDataItem: item)
			
        } else {
            if ( cellType == "movies")
			{
                guard let cell = cell as? DataItemCollectionViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
                let item = dataItems_[indexPath.row]
                // Configure the cell.
                cell.label.text = item.name
                cell.imageView.image = UIImage(named: "movie-placeholder.png")
                let urlString = item.image
                if let img = moviesImageCache[urlString!] {
                    cell.imageView?.image = img
                }
                else {
                    // The image isn't cached, download the img data
                    // We should perform this in a background thread
                    let session = NSURLSession.sharedSession()
                    let url		= NSURL(string: urlString!)
                    let request = NSURLRequest(URL: url!)
                    let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                        
                        if (error == nil ){
                            let image = UIImage(data: data!)
                            // Store the image in to our cache
                            self.moviesImageCache[urlString!] = image
                            // Update the cell
                            dispatch_async(dispatch_get_main_queue(), {
                                if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? DataItemCollectionViewCell {
                                    cellToUpdate.imageView.image = image
                                }
                            })
                        }else {
                            print("done, error: \(error)")
                        }
                        
                    }
                    dataTask.resume()
                }
                if indexPath.row == (dataItems_.count - 10) && APIrequestType != "Search" {
                    //loadMore Movies Data
                    print("loading more movies")
                    //**apiRequestForMovies()
                }
                
            }
			else
			{
				let item = dataItems_[indexPath.row]

				guard let cell = cell as? DataItemCollectionViewCell_ else { fatalError("Expected to display a DataItemCollectionViewCell") }
                //let item = dataItems_[indexPath.row]
                // Configure the cell.
                cell.label.text = item.name
                cell.imageView.image = UIImage(named: "tv-series-placeholder.png")
                let urlString = item.image
                if let img = moviesImageCache[urlString!] {
                    cell.imageView?.image = img
                }
                else {
                    // The image isn't cached, download the img data
                    // We should perform this in a background thread
                    let session = NSURLSession.sharedSession()
                    let url = NSURL(string: urlString!)
                    let request = NSURLRequest(URL: url!)
                    let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                        
                        if (error == nil ){
                            let image = UIImage(data: data!)
                            // Store the image in to our cache
                            self.showsImageCache[urlString!] = image
                            // Update the cell
                            dispatch_async(dispatch_get_main_queue(), {
                                if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? DataItemCollectionViewCell_ {
                                    cellToUpdate.imageView.image = image
                                }
                            })
                        }else {
                            print("done, error: \(error)")
                        }
                        
                    }
                    dataTask.resume()
                }
                
                if indexPath.row == (dataItems_.count - 10) && APIrequestType != "Search" {
                    //loadMore Movies Data
                    print("loading more shows")
                    //**apiRequestForShows()
                }

            }
        }
        
        
        if(indexPath.row == dataItems_.count - 1 ){
            print("LOADING>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            if self.nextUrl != "" {
            
                self.loadMore(self.nextUrl)
            }
        }
        
    }
    

    func queryParams(urlStr:String, paramName:String) -> String {
        let url = urlStr
        let urlComponents = NSURLComponents(string: url)
        let queryItems = urlComponents?.queryItems
        let params = queryItems?.filter({$0.name == "page"}).first
        return (params?.value)!
    }
    
    func loadMore(nextUrl:String = "") {
        
        print(cellType)
        print(nextUrl)
        apiLoadMore?.cancel()
        apiLoadMore = Alamofire.request(.POST,nextUrl).responseObject { (response: Response<SearchModel, NSError>) in
            
            let apiResponce = response.result.value
            
            if self.cellType == "movies" {
                
                for item in (apiResponce?.movies?.data)! {
                    self.dataItems_.append(item)
                }
                self.nextUrl = (apiResponce?.movies?.nextPageUrl != nil ) ? (apiResponce?.movies?.nextPageUrl)! : ""
                
            } else if self.cellType == "episode" {
                
                for item in (apiResponce?.episodes?.data)! {
                    self.dataItems_.append(item)
                }
                self.nextUrl = (apiResponce?.movies?.nextPageUrl != nil ) ? (apiResponce?.episodes?.nextPageUrl)! : ""
                
                
            } else {
                for item in (apiResponce?.shows?.data)! {
                    self.dataItems_.append(item)
                }
                self.nextUrl = (apiResponce?.movies?.nextPageUrl != nil ) ? (apiResponce?.shows?.nextPageUrl)! : ""
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                
                var indexPathsToReload = [NSIndexPath]()
                for i in 0 ... self.dataItems_.count - 1 {
                    indexPathsToReload.append(NSIndexPath(forItem: i, inSection: 0))
                }

                self.internalReload = true
                self.collectionView.reloadData()
            })
        }
    }
	
}
