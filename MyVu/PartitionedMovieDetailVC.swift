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
	@IBOutlet weak var imgViewbg:UIImageView!
	
    
    //MARK: - Variables
    var containerView = UIView()
    var movieId     : String!
    var cellType    : String!
    var movieDetailFeildsView  = MovieDetailFeildsClass()
    var relatedMovies = RelatedMoviesViewClass()
    var playBackSources = PlaybackSourcesViewClass()
    
    //MARK: - ViewController LifeCycle and Focus
    override func viewDidLoad(){
        super.viewDidLoad()
		self.view.tintColor = UIColor.blackColor()
		
        if cellType == nil{
            cellType = "movies"
        }
        
        self.definesPresentationContext = true
        laoder.startAnimating()
		
		
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PartitionedMovieDetailVC.refreshList(_:)), name:"refresh", object: nil)
        let relatedMovies = RelatedMoviesViewClass.instanceFromNib()
        let movieDetailFeilds = MovieDetailFeildsClass.instanceFromNib()
        movieDetailFeildsView = movieDetailFeilds as! MovieDetailFeildsClass
        let playBackSources = PlaybackSourcesViewClass.instanceFromNib()
		
		let filterStr =  FilterPreference.getString()!
		let filter = ( filterStr == "" ) ? "" : "?sources=\(filterStr)"
		
        let movieUrlStr = "http://demoz.online/tvios/public/api/get_item/\(movieId)/\(cellType)\(filter)"
        print(movieUrlStr)
        Alamofire.request(.GET, movieUrlStr ).responseObject {
            (response: Response<MovieDataModel, NSError>) in
			
            let apiResponce = response.result.value?.data
            if ( apiResponce?.id != nil ){
                var completeString : String = String()
                
                //Rating
                if let rating = apiResponce?.rating {
                    completeString += (apiResponce?.mpaa!)!
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
                }
                
                //Release Date
                if let release = apiResponce?.release_date {
                    completeString += self.localizedDateTime(release) //self.getFormatedDate((release))
                    self.movieDetailFeildsView.genreAndRatingLbl.text = completeString
                } else {
                    self.movieDetailFeildsView.genreAndRatingLbl.hidden = true
                }
                
                self.movieDetailFeildsView.movieTitleLbl.text = apiResponce?.title
                var directorAndStartingString : String = String()
                
                //Genre
                if let genre = apiResponce?.genres {
                    for i in 0..<genre.count {
                        directorAndStartingString += (genre[i].title)!
                        if ( i < ((genre.count) - 1) ){
                            directorAndStartingString += "/"
                        }
                    }
                }                 
                //Director
                directorAndStartingString += " from "
				
                for director in (apiResponce?.directors)! {
                    directorAndStartingString += director.name!
                    break
                }
                
                // Cast
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
				
				if let duration = apiResponce?.duration {
					self.movieDetailFeildsView.labelRuntime.text = "Runtime: " + duration
				}
				
				if let imgURL = apiResponce?.poster {
					self.movieDetailFeildsView.moviePoster.sd_setImageWithURL(NSURL(string: imgURL))
					
					//^^self.movieDetailFeildsView.background.sd_setImageWithURL(NSURL(string: imgURL))
					self.imgViewbg.sd_setImageWithURL(NSURL(string: imgURL))
					
					
					self.view.backgroundColor = UIColor .clearColor()
					let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
					let blurEffectView = UIVisualEffectView(effect: blurEffect)
					//always fill the view
					blurEffectView.frame = self.movieDetailFeildsView.frame
					
					print(blurEffectView)
					
					
					
					blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
					self.movieDetailFeildsView.background.addSubview(blurEffectView)
					//self.imgViewbg.addSubview(blurEffectView)
				}

				if let rating = apiResponce?.rating {
					self.movieDetailFeildsView.imdbRatingsLbl.text = rating
				}
				
                self.relatedMovies = relatedMovies as! RelatedMoviesViewClass
				if let relatedData = apiResponce?.related?.results {
					for movie in relatedData {
						movie.group = "Movies"
					}
					self.relatedMovies.configureCollectionView(relatedData)
				}
				
                self.playBackSources = playBackSources as! PlaybackSourcesViewClass
                self.playBackSources.title = (apiResponce?.title)!
				
                /*
				movieDetailFeilds.frame = CGRectMake(	movieDetailFeilds.frame.origin.x,
														movieDetailFeilds.frame.origin.y,
														(self.scrollView.frame.size.width - 500),
														movieDetailFeilds.frame.size.height)
				*/
				
				let blurEffect123 = UIBlurEffect(style: UIBlurEffectStyle.Dark)
				let blurEffectView123 = UIVisualEffectView(effect: blurEffect123)
				blurEffectView123.frame = self.relatedMovies.bounds
				blurEffectView123.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
				
				self.containerView.addSubview(blurEffectView123)
                self.containerView.addSubview(movieDetailFeilds)
				
                self.relatedMovies.parentVC = self
                let blurEffect_ = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                let blurEffectView_ = UIVisualEffectView(effect: blurEffect_)
                blurEffectView_.frame = self.playBackSources.bounds
                blurEffectView_.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
				
                //self.playBackSources.bgView.addSubview(blurEffectView_)
				
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.relatedMovies.bounds
                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
				
                //self.relatedMovies.bgView.addSubview(blurEffectView)
			
				playBackSources.frame = CGRectMake(playBackSources.frame.origin.x,
										playBackSources.frame.origin.y + 650,
										playBackSources.frame.size.width,
										playBackSources.frame.size.height)
				
				self.containerView.addSubview(playBackSources)
				self.playBackSources.parentVC = self
				
				relatedMovies.frame = CGRectMake(
					relatedMovies.frame.origin.x,
					relatedMovies.frame.origin.y + 925,
					relatedMovies.frame.size.width,
					relatedMovies.frame.size.height)
				
				self.containerView.addSubview(relatedMovies)
			
				if let sources = apiResponce!.sources {
					self.playBackSources.setupCollectionView(sources)
				} else {
					self.playBackSources.setupCollectionView([])
				}
				
				self.laoder.stopAnimating()
				self.scrollView.delegate = self
				self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.contentSize.height + 1600)
				self.scrollView.addSubview(self.containerView)
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
	
    func getMovieDetailsURL() -> String                            {
        print(APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.MOVIE_DETAILS_URL + "\(movieId)")
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
	
	func localizedDateTime(dateString:String) -> String {
		
		print(dateString)
		
        let localeTemplate = NSLocale(localeIdentifier: NSLocale.preferredLanguages().first!)
		let strDate = self.getFormatedDate(dateString)
		let strDateFormatter = NSDateFormatter()
		strDateFormatter.dateFormat = "dd MMM YYYY"
		
		let date = strDateFormatter.dateFromString(strDate)
		print(date)
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.timeStyle = .NoStyle
		dateFormatter.dateStyle = .ShortStyle
		
		let locale = NSLocale.preferredLanguages().first
		dateFormatter.locale = NSLocale(localeIdentifier: locale!)
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("ddMMMyyyy", options: 0, locale: localeTemplate)
		print(dateFormatter.stringFromDate(date!))
		
		return dateFormatter.stringFromDate(date!)
	}
	

	
}
