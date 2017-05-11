//
//  ShowDetailsVC.swift
//  HelloWorld
//
//  Created by MacPro on 26/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import Foundation
import SDWebImage

class ShowDetailsVC : UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
	@IBOutlet weak var imgViewbg:UIImageView!
    
    //MARK: - Variables
    var showID : String!
    var showDetailsView = ShowDetailFeilds()
    //var totalSeasons = Int()
    var dataSeasons = [SeasonModel]()
    var cellType:String!
    var playBackSources = PlaybackSourcesViewClass()
    private var sectionsLoaded : [Int] = []
	
	
	override var preferredFocusedView: UIView?{
		return self.showDetailsView.showTitleLbl
	}
	
    //MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if cellType == nil {
            fatalError()
        }

        print(showID)
		loader.hidesWhenStopped = true
        loader.startAnimating()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // Make sure their is sufficient padding above and below the content.
        guard let collectionView = collectionView, let _ = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let showDetailFeildsView = ShowDetailFeilds.instanceFromNib()
        let playBackSources = PlaybackSourcesViewClass.instanceFromNib()
        showDetailsView = showDetailFeildsView as! ShowDetailFeilds
		
		let filterStr =  FilterPreference.getString()!
		let filter = ( filterStr == "" ) ? "" : "?sources=\(filterStr)"
		
        let showURL = "http://demoz.online/tvios/public/api/get_item/\(showID)/\(cellType)\(filter)"
        print(showURL)
        Alamofire.request(.GET, showURL ).responseObject { (response: Response<ShowDataModel, NSError>) in
			
			self.loader.stopAnimating()
            let apiResponce = response.result.value?.data

            if ( apiResponce?.id != nil ){
                var completeString : String = String()
                
                //Rating
                if let mpaa = apiResponce?.mpaa {
                    completeString += mpaa
                    completeString += " | "
                    var genreString = String()
					if let genreArr:[Genre] = apiResponce?.genres {
						for i in 0 ..< genreArr.count {
							genreString += (apiResponce?.genres![i].title)!
							if ( i < ((apiResponce!.genres!.count) - 1) ){
								genreString += ", "
							}
						}
					}
					completeString += genreString
                }
                
                //Aired
                if let firstAired = apiResponce?.first_aired{
                    completeString += self.getFormatedDate ((firstAired))
                }
                
                self.showDetailsView.genreAndRatingLbl.text = completeString
                self.showDetailsView.showTitleLbl.text = apiResponce?.title
                var genreAndNumberofSeasonsLbl : String = String()
                if let genre = apiResponce?.genres{
                    for i in 0..<1 {
                        genreAndNumberofSeasonsLbl += (genre[i].title)!
                    }
                }
				self.showDetailsView.genreAndNumberofSeasonsLbl.text = genreAndNumberofSeasonsLbl
				
				if self.cellType == "episodes"{
					self.showDetailsView.genreAndNumberofSeasonsLbl.text = apiResponce?.showName
				}
				
				if let imdbrating = apiResponce?.rating {
					self.showDetailsView.imdbRatingsLbl.text = imdbrating
				}
				
                self.showDetailsView.showDescriptionLbl.text = apiResponce?.overview
				
				if let runtime = apiResponce?.duration {
					self.showDetailsView.labelRuntime.text = "Runtime: \(runtime)"
				} else {
					self.showDetailsView.labelRuntime.hidden = true
				}
				

                if let imgUrl = apiResponce?.artwork {
					
					self.showDetailsView.showPoster.sd_setImageWithURL(NSURL(string: imgUrl))
					//self.showDetailsView.background.sd_setImageWithURL(NSURL(string: imgUrl))
	
					self.imgViewbg.sd_setImageWithURL(NSURL(string: imgUrl))
					self.view.backgroundColor	= UIColor.clearColor()
					
					
					
					let blurEffect				= UIBlurEffect(style: UIBlurEffectStyle .Dark)
					let blurEffectView			= UIVisualEffectView(effect: blurEffect)
					blurEffectView.frame		= self.showDetailsView.frame
					blurEffectView.autoresizingMask = [	.FlexibleWidth, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin ]
					self.showDetailsView.background.addSubview(blurEffectView)
					
                }
                
                if self.cellType != "shows" {
				self.playBackSources = playBackSources as! PlaybackSourcesViewClass
				self.playBackSources.title = (apiResponce?.title)!
				
				
				if let sources = apiResponce!.sources {
					self.playBackSources.setupCollectionView(sources)
				} else {
					self.playBackSources.setupCollectionView([])
				}
			
//				let blurEffect_ = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//				let blurEffectView_ = UIVisualEffectView(effect: blurEffect_)
//				blurEffectView_.frame = self.playBackSources.bounds
//				blurEffectView_.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//				self.playBackSources.bgView.addSubview(blurEffectView_)

				self.playBackSources.frame = CGRectMake(0, 0 + 50, self.playBackSources.frame.width, self.playBackSources.frame.height)
				self.playBackSources.parentVC = self
				self.collectionView.addSubview(playBackSources)
                }
				
				
				
				let blurEffectNew				= UIBlurEffect(style: UIBlurEffectStyle .Dark)
				let blurEffectViewNew			= UIVisualEffectView(effect: blurEffectNew)
				blurEffectViewNew.layer.zPosition = 0
				blurEffectViewNew.frame		= self.view.frame
				blurEffectViewNew.autoresizingMask = [	.FlexibleWidth, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin ]
				self.imgViewbg.addSubview(blurEffectViewNew)
				
				
				
                if apiResponce?.seasons?.count > 0 {
                    print((apiResponce?.seasons?.count)!)
                    self.dataSeasons = (apiResponce?.seasons)!
                    self.collectionView.reloadData()
                }
                
                self.view.addSubview(showDetailFeildsView)
            }
        }
    }

    //MARK: - UICollectionViewDelegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int                                               {
        print(dataSeasons.count)
        return dataSeasons.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int                            {
        // Each section contains a single `CollectionViewContainerCell`.
        //print(section)
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCellOld.reuseIdentifier, forIndexPath: indexPath) as! CollectionViewContainerCellOld
		
        cell.activityIndicator.stopAnimating()
        cell.loadingLabel.hidden = true
        cell.parentViewController = self
        cell.cellType = "episode"
        cell.collectionType = "episode"
		

		cell.requestCellData(dataSeasons[indexPath.section].results!)
		sectionsLoaded.append(indexPath.section)
		
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool                {
		/*
		Return `false` because we don't want this `collectionView`'s cells to
		become focused. Instead the `UICollectionView` contained in the cell
		should become focused.
		*/
        return false
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		
		let view = UICollectionReusableView()
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,withReuseIdentifier: "SeasonsHeaderView",forIndexPath: indexPath) as! SeasonsHeaderView
			
			
			
            headerView.title.text = "Season \(dataSeasons.count - indexPath.section)"
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return view
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    //MARK: - Others
    func getShowDetailsURL () -> String  {
        print(APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.SHOW_DETAILS_URL + showID)
        return (APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.SHOW_DETAILS_URL + showID)
    }
    func getIMDBrating(imdbID:String)    {
        let urlString = "http://www.omdbapi.com/?i=" + imdbID + "&plot=full&r=json"
        
        print(urlString)
        
        Alamofire.request(.GET, urlString)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print(JSON.objectForKey("imdbRating"))
                    self.showDetailsView.imdbRatingsLbl.text = JSON.objectForKey("imdbRating") as? String
                }
        }
    }
    func getFormatedDate (dateString:String) -> String{
        var formatedDateString = String ()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        let temp = dateFormatter.dateFromString(dateString)
        //print(temp)
        // convert to required string
        dateFormatter.dateFormat = "dd MMM YYYY"
        formatedDateString = dateFormatter.stringFromDate(temp!)
        return formatedDateString
    }

	
}
