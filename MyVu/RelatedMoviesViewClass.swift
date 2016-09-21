//
//  RelatedMoviesViewClass.swift
//  HelloWorld
//
//  Created by MacPro on 24/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire

class RelatedMoviesViewClass : UIView,UICollectionViewDelegate,UICollectionViewDataSource{
    
    //MARK: - Outlets
    @IBOutlet var bgView: UIImageView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var headerLabel: UILabel!
    
    //MARK: - Variables
    var parentVC = UIViewController()
    var moviesImageCache = [String:UIImage]()
    var requestType : String = ""
    var cellType : String = ""
    private let cellComposer = DataItemCellComposer()
    private var dataItems_ = [Result]()
    
    //MARK: - Initializer
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "RelatedMoviesView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int                    {
        // Our collection view displays 1 section per group of items.
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        //print(dataItems_.count)
        return dataItems_.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (dataItems_[indexPath.row].group == "Movies"){
            return collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
        }else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell_.reuseIdentifier, forIndexPath: indexPath)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)                                       {
        if (dataItems_[indexPath.row].group == "Movies"){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("PartitionedMovieDetailVC") as? PartitionedMovieDetailVC else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
            }
            detailScreen.movieId = String(dataItems_[indexPath.row].id!)
            parentVC.navigationController?.pushViewController(detailScreen, animated: true)
        }else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ShowDetailsVC") as? ShowDetailsVC else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
            }
            detailScreen.showID = String(dataItems_[indexPath.row].id!)
            parentVC.navigationController?.pushViewController(detailScreen, animated: true)
        }
    }
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if (dataItems_[indexPath.row].group == "Movies"){
            guard let cell = cell as? DataItemCollectionViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
            let item = dataItems_[indexPath.row]
            // Configure the cell.
            //cellComposer.composeCell(cell, withDataItem: item)
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
            let swipeUPforDeselectBtn:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(RelatedMoviesViewClass.swipedUP(_:)))
            swipeUPforDeselectBtn.direction = .Up
            cell.addGestureRecognizer(swipeUPforDeselectBtn)
        }
    }
    func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = UICollectionReusableView()
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HeaderView
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return view
    }

    //MARK: - Others
    func swipedUP(sender:UISwipeGestureRecognizer){
        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
    }
    func requestRelatedMoviesData(movieID:Int)    {
        requestType = "relatedMovies"
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 90)
        layout.itemSize = CGSize(width: 240 , height:390)
        layout.minimumLineSpacing = 100
        self.collectionView.collectionViewLayout = layout
        self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 390)
        getRelatedMovies(movieID)
    }
    func relatedMoviesURL (movieID:Int) -> String {
        //print(APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + "/movie/" + String (movieID) + "/related")
        return APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + "/movie/" + String (movieID) + "/related"
    }
    func getRelatedMovies(movieID:Int)            {
        Alamofire.request(.GET, relatedMoviesURL(movieID)).responseObject {
            (response: Response<MoviesSearchResultModel, NSError>) in
            let apiResponce = response.result.value
            if ( apiResponce?.results?.count > 0 ){
                for movie in (apiResponce?.results)! {
                    movie.group = "Movies"
                    self.dataItems_.append(movie)
                }
                var indexes = [NSIndexPath]()
                for index in 0..<self.dataItems_.count {
                    indexes.append(NSIndexPath(forRow: index, inSection: 0))
                }
                self.collectionView.insertItemsAtIndexPaths(indexes)
            }else if ( apiResponce?.results?.count < 0 ){
                
            }else {
                print(apiResponce?.toJSONString())
                self.headerLabel.hidden = true
            }
        }
    }
    func setupCollectionView (movieID:Int)        {
        let nibName = UINib(nibName: "DataItemCell", bundle:nil)
        self.collectionView.registerNib(nibName, forCellWithReuseIdentifier: "DataItemCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        requestRelatedMoviesData(movieID)
    }
}