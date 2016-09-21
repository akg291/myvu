//
//  PartitionedMovieDetailVC.swift
//  HelloWorld
//
//  Created by MacPro on 24/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import Foundation
import SDWebImage

class PartitionedMovieDetailVC : UIViewController,UIScrollViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var laoder: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Variables
    var containerView = UIView()
    var movieId : String = ""
    var movieDetailFeildsView  = MovieDetailFeildsClass()
    var relatedMovies = RelatedMoviesViewClass()
    var playBackSources = PlaybackSourcesViewClass()
    
    //MARK: - ViewController LifeCycle and Focus
    override func viewDidLoad()           {
        super.viewDidLoad()
        self.definesPresentationContext = true
        laoder.startAnimating()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PartitionedMovieDetailVC.refreshList(_:)), name:"refresh", object: nil)
        let relatedMovies = RelatedMoviesViewClass.instanceFromNib()
        let movieDetailFeilds = MovieDetailFeildsClass.instanceFromNib()
        movieDetailFeildsView = movieDetailFeilds as! MovieDetailFeildsClass
        let playBackSources = PlaybackSourcesViewClass.instanceFromNib()
        Alamofire.request(.GET, getMovieDetailsURL()).responseObject {
            (response: Response<MovieDetailsModel, NSError>) in
            print(response.result.value?.toJSONString())
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
                completeString += self.getFormatedDate((apiResponce?.release_date)!)
                self.movieDetailFeildsView.genreAndRatingLbl.text = completeString
                self.movieDetailFeildsView.movieTitleLbl.text = apiResponce?.title
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
                if (apiResponce?.cast?.count > 3){
                    for i in 0...2 {
                        directorAndStartingString += (apiResponce?.cast![i].name)!
                        if ( i < 2 ){
                            directorAndStartingString += ", "
                        }
                    }
                }else {
                    for i in 0..<apiResponce!.cast!.count {
                        directorAndStartingString += (apiResponce?.cast![i].name)!
                        if ( i < 2 ){
                            directorAndStartingString += ", "
                        }
                    }
                }
                self.movieDetailFeildsView.directorAndStarringLbl.text = directorAndStartingString
                self.movieDetailFeildsView.movieDescriptionLbl.text = apiResponce?.overview
                if let imgUrl = apiResponce?.poster {
                    downlaoder.downloadImageWithURL(
                        NSURL(string: imgUrl),
                        options: SDWebImageDownloaderOptions.UseNSURLCache,
                        progress: nil,
                        completed: { (image, data, error, bool) -> Void in
                            if image != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.movieDetailFeildsView.moviePoster.image = image
                                    self.movieDetailFeildsView.background.image = image// backgroundColor = UIColor(patternImage: image)
                                    //only apply the blur if the user hasn't disabled transparency effects
                                    if !UIAccessibilityIsReduceTransparencyEnabled() {
                                        self.view.backgroundColor = UIColor .clearColor()
                                        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle .Dark)
                                        let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                        //always fill the view
                                        blurEffectView.frame = self.movieDetailFeildsView.bounds
                                        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                        self.movieDetailFeildsView.background.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
                                    } else {
                                        self.movieDetailFeildsView.background.backgroundColor = UIColor .blueColor()
                                    }
                                })
                            }
                    })
                }
                self.movieDetailFeildsView.movieRunTimeLbl.text = self.getRunTime((apiResponce?.duration)!)
                self.movieDetailFeildsView.movieEndingTimeLbl.text = self.getEspectedFinishTime((apiResponce?.duration)!)
                self.getIMDBrating((apiResponce?.imdb)!)
                self.relatedMovies = relatedMovies as! RelatedMoviesViewClass
                self.relatedMovies.setupCollectionView((apiResponce?.id)!)
                self.playBackSources = playBackSources as! PlaybackSourcesViewClass
                self.playBackSources.setupCollectionView((apiResponce?.purchase_ios_sources)!)
                movieDetailFeilds.frame = CGRectMake(movieDetailFeilds.frame.origin.x, movieDetailFeilds.frame.origin.y, (self.scrollView.frame.size.width - 500), movieDetailFeilds.frame.size.height)
                self.containerView.addSubview(movieDetailFeilds)
                self.relatedMovies.parentVC = self
                let blurEffect_ = UIBlurEffect(style: UIBlurEffectStyle .Dark)
                let blurEffectView_ = UIVisualEffectView(effect: blurEffect_)
                blurEffectView_.frame = self.playBackSources.bounds
                blurEffectView_.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.playBackSources.bgView.addSubview(blurEffectView_)
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle .Dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.relatedMovies.bounds
                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.relatedMovies.bgView.addSubview(blurEffectView)
                if ( apiResponce?.purchase_ios_sources?.count > 0 ){
                    playBackSources.frame = CGRectMake(playBackSources.frame.origin.x, playBackSources.frame.origin.y + 700, playBackSources.frame.size.width, playBackSources.frame.size.height)
                    self.containerView.addSubview(playBackSources)
                    relatedMovies.frame = CGRectMake(relatedMovies.frame.origin.x, relatedMovies.frame.origin.y + 1050, relatedMovies.frame.size.width, relatedMovies.frame.size.height)
                    self.containerView.addSubview(relatedMovies)
                }else {
                    relatedMovies.frame = CGRectMake(relatedMovies.frame.origin.x, relatedMovies.frame.origin.y + 700, relatedMovies.frame.size.width, relatedMovies.frame.size.height)
                    self.containerView.addSubview(relatedMovies)
                }
                self.laoder.stopAnimating()
                self.scrollView.delegate = self
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.contentSize.height + 1800)
                self.scrollView.addSubview(self.containerView)
            }else if ( apiResponce?.error != "" ){
            }else {
                //print(apiResponce?.toJSONString())
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(containerView.frame )
        containerView.frame = CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height)
    }
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.view.layer.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.2).CGColor
                }, completion: nil)
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.view.layer.backgroundColor = UIColor.clearColor().CGColor
                }, completion: nil)
        }
        
    }
    
    //MARK: - Others
    func refreshList(notification: NSNotification)                 {
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    func getMovieDetailsURL() -> String                            {
        //print(APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.MOVIE_DETAILS_URL + "\(movieId)")
        return (APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.MOVIE_DETAILS_URL + movieId)
    }
    func getRunTime (durationInSeconds : Int) -> String            {
        let tempString : String = String((durationInSeconds / 3600)) + "hr " + String((durationInSeconds % 3600) / 60) + "min"
        return tempString
    }
    func getFormatedDate (dateString:String) -> String             {
        var formatedDateString = String ()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        let temp = dateFormatter.dateFromString(dateString)
        print(temp)
        // convert to required string
        dateFormatter.dateFormat = "dd MMM YYYY"
        formatedDateString = dateFormatter.stringFromDate(temp!)
        return formatedDateString
    }
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
    func getIMDBrating(imdbID:String)                              {
        let urlString = "http://www.omdbapi.com/?i=" + imdbID + "&plot=full&r=json"
        Alamofire.request(.GET, urlString)
            .responseJSON { response in
                if let JSON = response.result.value {
                    //print(JSON.objectForKey("imdbRating"))
                    self.movieDetailFeildsView.imdbRatingsLbl.text = JSON.objectForKey("imdbRating") as? String
                }
        }
    }
    
}