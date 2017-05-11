//
//  MovieDetailsScreen.swift
//  HelloWorld
//
//  Created by MacPro on 18/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage
import Foundation

class MovieDetailsScreen : UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView       : UICollectionView!
    @IBOutlet weak var backgroundView       : UIImageView!
    @IBOutlet weak var genreAndRatingLbl    : UILabel!
    @IBOutlet weak var movieTitleLbl        : UILabel!
    @IBOutlet weak var directorAndStarringLbl: UILabel!
    @IBOutlet weak var movieDescriptionLbl  : UILabel!
    @IBOutlet weak var movieEndingTimeLbl   : UILabel!
    @IBOutlet weak var movieRunTimeLbl      : UILabel!
    @IBOutlet weak var imdbRatingsLbl       : UILabel!
    @IBOutlet weak var moviePoster          : UIImageView!
    
    //MARK: - Variables
    var movieId : String = ""
    private var movieID = Int()
    private static let minimumEdgePadding = CGFloat(90.0)
    
    //MARK: - ViewController LifeCycle
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    override func viewDidLoad()                  {
        super.viewDidLoad()
				
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // Make sure their is sufficient padding above and below the content.
        guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        self.collectionView.contentInset.top = MovieDetailsScreen.minimumEdgePadding - layout.sectionInset.top
        self.collectionView.contentInset.bottom = MovieDetailsScreen.minimumEdgePadding - layout.sectionInset.bottom
        self.collectionView.contentInset.left = MovieDetailsScreen.minimumEdgePadding - layout.sectionInset.left
        self.collectionView.contentInset.right = MovieDetailsScreen.minimumEdgePadding - layout.sectionInset.right
        Alamofire.request(.GET, getMovieDetailsURL()).responseObject {
            (response: Response<MovieDetailsModel, NSError>) in
            let downlaoder : SDWebImageDownloader = SDWebImageDownloader .sharedDownloader()
            let apiResponce = response.result.value
            if ( apiResponce?.id != nil ){
                var completeString : String = String()
                completeString += (apiResponce?.rating)!
                completeString += " | "
                var genreString = String()
                for i in 0..<apiResponce!.genres!.count {
                    genreString += (apiResponce?.genres![i].title)!
                    if ( i < ((apiResponce!.genres!.count) - 1) ){
                        genreString += ", "
                    }
                }
                completeString += genreString
                completeString += " | "
                completeString += (apiResponce?.release_date)!
                self.genreAndRatingLbl.text = completeString
                self.movieTitleLbl.text = apiResponce?.title
                var directorAndStartingString : String = String()
                for i in 0..<apiResponce!.genres!.count {
                    directorAndStartingString += (apiResponce?.genres![i].title)!
                    if ( i < ((apiResponce!.genres!.count) - 1) ){
                        directorAndStartingString += "/"
                    }
                }
                directorAndStartingString += " from "
                for director in (apiResponce?.directors)! {
                    directorAndStartingString += director.name!
                    break
                }
                directorAndStartingString += " starring "
                for i in 0...2 {
                    directorAndStartingString += (apiResponce?.cast![i].name)!
                    if ( i < 2 ){
                        directorAndStartingString += ", "
                    }
                }
                self.directorAndStarringLbl.text = directorAndStartingString
                self.movieDescriptionLbl.text = apiResponce?.overview
                if let imgUrl = apiResponce?.poster {
                    downlaoder.downloadImageWithURL(
                        NSURL(string: imgUrl),
                        options: SDWebImageDownloaderOptions.UseNSURLCache,
                        progress: nil,
                        completed: { (image, data, error, bool) -> Void in
                            if image != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.moviePoster.image = image
                                    self.backgroundView.image = image// backgroundColor = UIColor(patternImage: image)
                                    //only apply the blur if the user hasn't disabled transparency effects
                                    if !UIAccessibilityIsReduceTransparencyEnabled() {
                                        self.view.backgroundColor = UIColor .clearColor()
                                        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle .Light)
                                        let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                        //always fill the view
                                        blurEffectView.frame = self.view.bounds
                                        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                        self.backgroundView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
                                    } else {
                                        self.backgroundView.backgroundColor = UIColor .blueColor()
                                    }
                                })
                            }
                    })
                }
                //self.movieRunTimeLbl.text = self.getRunTime((apiResponce?.duration)!)
                //self.movieEndingTimeLbl.text = self.getEspectedFinishTime((apiResponce?.duration)!)
                self.getIMDBrating((apiResponce?.imdb)!)
                //print((apiResponce?.id)!)
                self.movieID = (apiResponce?.id)!
                collectionView.reloadData()
            }else if ( apiResponce?.error != "" ){
            }else {
                //print(apiResponce?.toJSONString())
            }
        }
        let dateString = "2014-07-15" // change to your date format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "dd MMM yyyy"
        //print(dateFormatter.stringFromDate(date!))
        }
    
    // MARK: - UICollectionViewDataSource and Delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int                                {
        // Our collection view displays 1 section per group of items.
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int             {
        // Each section contains a single `CollectionViewContainerCell`.
        //print(section)
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath) as! CollectionViewContainerCell
        cell.activityIndicator.startAnimating()
        cell.parentViewController = self
        cell.cellType = "Movies"
        return cell
    }
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    //MARK: - Others
    func getEspectedFinishTime (durationInSeconds : Int) -> String {
        var today = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let nowToday = dateFormatter.stringFromDate(today)
        today = dateFormatter.dateFromString(nowToday)!
        let espectedTimeToFinishMovie = NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Second,
                value: durationInSeconds,
                toDate: today,
                options: []
        )
        return dateFormatter.stringFromDate(espectedTimeToFinishMovie!)
    }
    func getRunTime (durationInSeconds : Int) -> String            {
        let tempString : String = String((durationInSeconds / 3600)) + "hr " + String((durationInSeconds % 3600) / 60) + "min"
        return tempString
    }
    func getMovieDetailsURL() -> String                            {
        //print(APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.MOVIE_DETAILS_URL + "\(movieId)")
        return (APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.MOVIE_DETAILS_URL + movieId)
    }
    func getIMDBrating(imdbID:String)                              {
        let urlString = "http://www.omdbapi.com/?i=" + imdbID + "&plot=full&r=json"
        Alamofire.request(.GET, urlString)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print(JSON.objectForKey("imdbRating"))
                    self.imdbRatingsLbl.text = JSON.objectForKey("imdbRating") as? String
                }
        }
    }
    
    
}
