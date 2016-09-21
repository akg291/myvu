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
    
    //MARK: - Variables
    var showID : String = ""
    var showDetailsView = ShowDetailFeilds()
    var totalSeasons = Int()
    private var sectionsLoaded : [Int] = []
    
    //MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // Make sure their is sufficient padding above and below the content.
        guard let collectionView = collectionView, _ = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let showDetailFeildsView = ShowDetailFeilds.instanceFromNib()
        showDetailsView = showDetailFeildsView as! ShowDetailFeilds
        Alamofire.request(.GET, getShowDetailsURL()).responseObject {
            (response: Response<ShowDetailsModel, NSError>) in
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
                completeString += self.getFormatedDate ((apiResponce?.first_aired)!)
                self.showDetailsView.genreAndRatingLbl.text = completeString
                self.showDetailsView.showTitleLbl.text = apiResponce?.title
                var genreAndNumberofSeasonsLbl : String = String()
                for i in 0..<1 {
                    genreAndNumberofSeasonsLbl += (apiResponce?.genres![i].title)!
                }
                self.showDetailsView.genreAndNumberofSeasonsLbl.text = genreAndNumberofSeasonsLbl
                self.showDetailsView.showDescriptionLbl.text = apiResponce?.overview
                self.getIMDBrating((apiResponce?.imdb_id)!)
                if let imgUrl = apiResponce?.artwork {
                    downlaoder.downloadImageWithURL(
                        NSURL(string: imgUrl),
                        options: SDWebImageDownloaderOptions.UseNSURLCache,
                        progress: nil,
                        completed: { (image, data, error, bool) -> Void in
                            if image != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.showDetailsView.showPoster.image = image
                                    self.showDetailsView.background.image = image// backgroundColor = UIColor(patternImage: image)
                                    //only apply the blur if the user hasn't disabled transparency effects
                                    if !UIAccessibilityIsReduceTransparencyEnabled() {
                                        self.view.backgroundColor = UIColor .clearColor()
                                        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle .Dark)
                                        let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                        //always fill the view
                                        blurEffectView.frame = self.showDetailsView.bounds
                                        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                        self.showDetailsView.background.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
                                        let blurEffect_ = UIBlurEffect(style: UIBlurEffectStyle .Dark)
                                        let blurEffectView_ = UIVisualEffectView(effect: blurEffect_)
                                        blurEffectView_.frame = self.collectionView.bounds
                                        blurEffectView_.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                        self.collectionView.backgroundView = blurEffectView_
                                    } else {
                                        self.showDetailsView.background.backgroundColor = UIColor .blueColor()
                                    }
                                })
                                self.loader.stopAnimating()
                            }
                    })
                }
                let getNumberOfSeasonsURL = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/show/" + self.showID + "/seasons"
                Alamofire.request(.GET,getNumberOfSeasonsURL).responseObject {
                    (response: Response<AllSeasonsModel, NSError>) in
                    let apiResponce = response.result.value
                    if ( apiResponce?.results?.count > 0 ){
                        print((apiResponce?.total_results)!)
                        self.totalSeasons = (apiResponce?.total_results)!
                        self.showDetailsView.genreAndNumberofSeasonsLbl.text = self.showDetailsView.genreAndNumberofSeasonsLbl.text! + ", " + String(self.totalSeasons) + " Seasons"
                        self.collectionView.reloadData()
                    }else if ( apiResponce?.results?.count < 0 ){
                    }else {
                        print(apiResponce?.toJSONString())
                    }
                }
                self.view.addSubview(showDetailFeildsView)
            }else if ( apiResponce?.error != "" ){
            }else {
                print(apiResponce?.toJSONString())
            }
        }
    }

    //MARK: - UICollectionViewDelegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int                                               {
        // Our collection view displays 1 section per group of items.
        //print(totalSeasons)
        return totalSeasons
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int                            {
        // Each section contains a single `CollectionViewContainerCell`.
        //print(section)
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath) as! CollectionViewContainerCell
        cell.activityIndicator.startAnimating()
        cell.parentViewController = self
        cell.cellType = "Shows"
        //cell.requestCellData()
        cell.collectionType = "Episodes"
        if ( sectionsLoaded.contains(indexPath.section + 1) ){
            //print("this section already loaded")
        }else {
            cell.requestCellData(Int(showID)!,seasonNumber: (indexPath.section + 1))
            sectionsLoaded.append(indexPath.section + 1)
        }
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
            headerView.title.text = "Season " + String(indexPath.section + 1)
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return view
    }
    
    //MARK: - Others
    func getShowDetailsURL () -> String  {
        print(APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.SHOW_DETAILS_URL + showID)
        return (APP_CONSTANTS.API_CONSTANTS.BASE_URL + APP_CONSTANTS.API_CONSTANTS.API_TOKKEN + APP_CONSTANTS.API_CONSTANTS.SHOW_DETAILS_URL + showID)
    }
    func getIMDBrating(imdbID:String)    {
        let urlString = "http://www.omdbapi.com/?i=" + imdbID + "&plot=full&r=json"
        Alamofire.request(.GET, urlString)
            .responseJSON { response in
                if let JSON = response.result.value {
                    //print(JSON.objectForKey("imdbRating"))
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
