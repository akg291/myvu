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

protocol ContentLoadMoreProtocol {
    func loadMoreMoviesData()
    func loadMoreShowsData()
}

class CollectionViewContainerCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var moviesImageCache = [String:UIImage]()
    var showsImageCache = [String:UIImage]()
    
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var alamofireManager : Alamofire.Manager?
    var parentViewController : UIViewController!
    var showsAPILowerIndex = 0
    var cellType : String = ""
    var APIrequestType : String = ""
    var moviesAPILowerIndex = 0
    var itemCount = 10
    
    var collectionType : String = ""
    // MARK: Properties
    static let reuseIdentifier = "CollectionViewContainerCell"
    @IBOutlet var collectionView: UICollectionView!
    
    private var dataItems = [DataItem]()
    private var dataItems_ = [Result]()
    private var episodesDataModels = [EpisodeModel]()
    private let cellComposer = DataItemCellComposer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func requestCellData(showID:Int,seasonNumber:Int){
    
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 90)
        layout.minimumInteritemSpacing = 0
        
        layout.itemSize = CGSize(width: 400 , height: 260)
        layout.minimumLineSpacing = 100
        self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 1200)
        self.collectionView.collectionViewLayout = layout
        apiRequest(showID,seasonNumber: seasonNumber)
    }
    
    func requestCellData(){
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 90)
        layout.minimumInteritemSpacing = 0
        
        if ( cellType == "Movies" ){
            layout.sectionInset = UIEdgeInsets(top: -50, left: 90, bottom: 0, right: 90)
            layout.itemSize = CGSize(width: 240 , height:390)
            layout.minimumLineSpacing = 100
            self.collectionView.collectionViewLayout = layout
            self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 390)
            apiRequestForMovies()
        }else if ( cellType == "Shows" ){
            layout.sectionInset = UIEdgeInsets(top: -100, left: 90, bottom: 50, right: 90)
            layout.itemSize = CGSize(width: 448 , height: 290)
            layout.minimumLineSpacing = 100
            self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 290)
            self.collectionView.collectionViewLayout = layout
            apiRequestForShows()
        }
    }
    
    func makeMoviesRequestURL(lowerLimit : Int,itemCount : Int) -> String {
        
        //                print(APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.MOVIES_CONTENT_URL +
        //                    String(lowerLimit) + "/" + String(upperLimit) + "/" + APP_CONSTANTS.API_CONSTANTS.SOURCES + "/" + APP_CONSTANTS.API_CONSTANTS.PLATFORMS)
        
        return APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.MOVIES_CONTENT_URL +
            String(lowerLimit) + "/" + String(itemCount) + "/" + APP_CONSTANTS.API_CONSTANTS.SOURCES + "/" + APP_CONSTANTS.API_CONSTANTS.PLATFORMS
    }
    
    func makeShowsWithSeasonNumberRequestURL(showID:Int,seasonNumber:Int)  -> String {
    
        var temp = APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN
        temp += "/show/"
        temp += String(showID)
        temp += "/episodes/"
        temp += String(seasonNumber)
        temp += "/0/100/all/all"
    
        print(temp)
        
        return temp
        
    }
    
    func makeShowsRequestURL(lowerLimit : Int,itemCount : Int) -> String {
        
        //        print( APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.SHOWS_CONTENT_URL +
        //            String(lowerLimit) + "/" + String(itemCount) + "/" + APP_CONSTANTS.API_CONSTANTS.SOURCES + "/" + APP_CONSTANTS.API_CONSTANTS.PLATFORMS)
        
        return APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.SHOWS_CONTENT_URL +
            String(lowerLimit) + "/" + String(itemCount) + "/" + APP_CONSTANTS.API_CONSTANTS.SOURCES + "/" + APP_CONSTANTS.API_CONSTANTS.PLATFORMS
    }
    
    func apiRequest(showID:Int,seasonNumber:Int){
        
        if (Reachibility.isConnectedToNetwork()){
        //self.shpowsRequest?.cancel()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        //configuration.timeoutIntervalForResource = 2 // seconds
        self.alamofireManager = Alamofire.Manager(configuration: configuration)
        self.alamofireManager!.request(.GET, makeShowsWithSeasonNumberRequestURL(showID,seasonNumber: seasonNumber)).responseObject {
            (response: Response<SeasonModel, NSError>) in
            
            let apiResponce = response.result.value
            if ( apiResponce?.results?.count > 0 ){
                
                for result in (apiResponce?.results)! {
                    //result.group = "Shows"
                    self.episodesDataModels.append(result)
                }
                var indexes = [NSIndexPath]()
                for index in 0..<self.episodesDataModels.count {
                    indexes.append(NSIndexPath(forRow: index, inSection: 0))
                }
                self.loadingLabel.hidden = true
                self.activityIndicator.stopAnimating()
                self.collectionView.insertItemsAtIndexPaths(indexes)
                //self.showsAPILowerIndex = self.dataItems_.count
                
            }else if ( apiResponce?.results?.count < 0 ){
                
            }else {
                print(apiResponce?.toJSONString())
            }
        }
        }else {
            let alert = UIAlertController(title: "Error", message: "You are not Connected to Internet!" , preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                switch action.style{
                case .Default:
                    print("default")
                    exit(0);
                case .Cancel:
                    print("cancel")
                case .Destructive:
                    print("destructive")
                }
            }))
            self.parentViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func apiRequestForShows (){
        
        if (Reachibility.isConnectedToNetwork()){
        //self.shpowsRequest?.cancel()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        //configuration.timeoutIntervalForResource = 2 // seconds
        self.alamofireManager = Alamofire.Manager(configuration: configuration)
        self.alamofireManager!.request(.GET, makeShowsRequestURL(showsAPILowerIndex,itemCount: itemCount)).responseObject {
            (response: Response<MoviesSearchResultModel, NSError>) in
            
            let apiResponce = response.result.value
            if ( apiResponce?.results?.count > 0 ){
                
                for result in (apiResponce?.results)! {
                    result.group = "Shows"
                    self.dataItems_.append(result)
                }
                var indexes = [NSIndexPath]()
                for index in self.showsAPILowerIndex..<self.dataItems_.count {
                    indexes.append(NSIndexPath(forRow: index, inSection: 0))
                }
                self.loadingLabel.hidden = true
                self.activityIndicator.stopAnimating()
                self.showsAPILowerIndex = self.dataItems_.count
                self.collectionView.insertItemsAtIndexPaths(indexes)
                
            }else if ( apiResponce?.results?.count < 0 ){
                
            }else {
                print(apiResponce?.toJSONString())
            }
        }
        }else {
            let alert = UIAlertController(title: "Error", message: "You are not Connected to Internet!" , preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                switch action.style{
                case .Default:
                    print("default")
                    exit(0);
                case .Cancel:
                    print("cancel")
                case .Destructive:
                    print("destructive")
                }
            }))
            self.parentViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func apiRequestForMovies (){
        
        if (Reachibility.isConnectedToNetwork()){
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            self.alamofireManager = Alamofire.Manager(configuration: configuration)
            self.alamofireManager!.request(.GET, makeMoviesRequestURL(moviesAPILowerIndex,itemCount: itemCount)).responseObject {
                (response: Response<MoviesSearchResultModel, NSError>) in
                
                let apiResponce = response.result.value
                if ( apiResponce?.results?.count > 0 ){
                    
                    for result in (apiResponce?.results)! {
                        result.group = "Movies"
                        self.dataItems_.append(result)
                    }
                    var indexes = [NSIndexPath]()
                    for index in self.moviesAPILowerIndex..<self.dataItems_.count {
                        indexes.append(NSIndexPath(forRow: index, inSection: 0))
                    }
                    self.loadingLabel.hidden = true
                    self.activityIndicator.stopAnimating()
                    self.moviesAPILowerIndex = self.dataItems_.count
                    self.collectionView.insertItemsAtIndexPaths(indexes)
                    
                }else if ( apiResponce?.results?.count < 0 ){
                    
                }else {
                    print(apiResponce?.toJSONString())
                }
            }
        }else {
            let alert = UIAlertController(title: "Error", message: "You are not Connected to Internet!" , preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                switch action.style{
                case .Default:
                    print("default")
                    exit(0);
                case .Cancel:
                    print("cancel")
                case .Destructive:
                    print("destructive")
                }
            }))
            self.parentViewController.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    override var preferredFocusedView: UIView? {
        return collectionView
    }
    
    // MARK: Configuration
    func configureWithDataItems(dataItems: [Result],section:Int) {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 90)
        layout.minimumInteritemSpacing = 0
                
        if ( section == 0 ){
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 90)
            layout.itemSize = CGSize(width: 240 , height:390)
            layout.minimumLineSpacing = 100
            self.collectionView.collectionViewLayout = layout
            self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 390)
            
        }else if ( section == 1 ){
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 90)
            layout.itemSize = CGSize(width: 448 , height: 290)
            layout.minimumLineSpacing = 100
            self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 290)
            self.collectionView.collectionViewLayout = layout
            
        }
        
        self.dataItems_ = dataItems
        collectionView.reloadData()
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
        
        if ( collectionType == "Episodes" ){
            return episodesDataModels.count
        }else {
            return dataItems_.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if ( collectionType == "Episodes" ){
            return collectionView.dequeueReusableCellWithReuseIdentifier(SeasonEpisodeViewCell.reuseIdentifier, forIndexPath: indexPath)
        }else {
            if (dataItems_[indexPath.row].group == "Movies"){
                return collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
            }else {
                return collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell_.reuseIdentifier, forIndexPath: indexPath)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if ( collectionType == "Episodes" ){
            //return episodesDataModels.count
        }else {
            if (dataItems_[indexPath.row].group == "Movies"){
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("PartitionedMovieDetailVC") as? PartitionedMovieDetailVC else {
                    fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
                }
                detailScreen.movieId = String(dataItems_[indexPath.row].id!)
                print(detailScreen.movieId)
                parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
                
                if ( APIrequestType == "Search" ){
                    parentViewController.presentingViewController?.navigationController?.pushViewController(detailScreen, animated: true)
                }
            
            }else {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ShowDetailsVC") as? ShowDetailsVC else {
                    fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
                }
                detailScreen.showID = String(dataItems_[indexPath.row].id!)
                parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
                
                if ( APIrequestType == "Search" ){
                    parentViewController.presentingViewController?.navigationController?.pushViewController(detailScreen, animated: true)
                }
            }
        }
    }
    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if ( collectionType == "Episodes" ){
            guard let cell = cell as? SeasonEpisodeViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
            let item = episodesDataModels[indexPath.row]
            // Configure the cell.
            cellComposer.composeCell(cell, withDataItem: item)
            
        }else {
            if (dataItems_[indexPath.row].group == "Movies"){
                guard let cell = cell as? DataItemCollectionViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
                let item = dataItems_[indexPath.row]
                // Configure the cell.
                cell.label.text = item.title
                cell.imageView.image = UIImage(named: "movie-placeholder.png")
                let urlString = item.previewImage
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
                    apiRequestForMovies()
                }
                
            }else {
                guard let cell = cell as? DataItemCollectionViewCell_ else { fatalError("Expected to display a DataItemCollectionViewCell") }
                let item = dataItems_[indexPath.row]
                // Configure the cell.
                cell.label.text = item.title
                cell.imageView.image = UIImage(named: "tv-series-placeholder.png")
                let urlString = item.artWork
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
                    apiRequestForShows()
                }
                
            }
        }
    }
}
