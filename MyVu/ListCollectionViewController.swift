//
//  ListCollectionViewController.swift
//  MyVu
//
//  Created by MacPro on 27/10/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

private let reuseIdentifier = "Cell"

class ListCollectionViewController: UICollectionViewController {

    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    private let minimumEdgePadding = CGFloat(90.0)
    private var dataItem:[ItemModel] = [ItemModel]()
    
    
    var headerTitle         : String    = ""
    var cellType            : String    = ""
    var collectionType      : String    = ""
    var isFilter            : Bool      = false
    var pageUrl             : String!
    var _page               : Int       = 0
    var id                  : String!
    var cellRequest         : Alamofire.Request?
    var layout              : UICollectionViewFlowLayout!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "search-bg.png")!)
        
        guard var collectionView = collectionView, var layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        collectionView.contentInset.top     = self.minimumEdgePadding - layout.sectionInset.top
        collectionView.contentInset.bottom  = self.minimumEdgePadding - layout.sectionInset.bottom
        collectionView.contentInset.left    = self.minimumEdgePadding - layout.sectionInset.left
        collectionView.contentInset.right   = self.minimumEdgePadding - layout.sectionInset.right
        
        /*
        self.dataList = data
        self.indexPath = indexPath
        self.cellRequest?.cancel()
        self.loadingLabel.hidden = true
        self.activityIndicator.stopAnimating()
        self.cellType = dataList.category!
        */

        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        
        switch ListType(rawValue: cellType )! {
        case .Movies:
            layout.itemSize = CGSize(width: 240 , height:390)
            layout.minimumLineSpacing = 100
            layout.minimumInteritemSpacing = 100
            self.collectionView!.collectionViewLayout = layout
        break
            
        case .Seasons, .Episode:
            layout.itemSize = CGSize(width: 448 , height: 290)
            layout.minimumLineSpacing = 50
            self.collectionView!.collectionViewLayout = layout
        break
            
        default:
            print("No case match")
        break
            
        }
        
        self.collectionView!.reloadData()
        self.getItems()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataItem.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        switch ListType(rawValue: self.cellType )! {
        case .Episode:
            let tempCell = collectionView.dequeueReusableCellWithReuseIdentifier(SeasonEpisodeViewCell.reuseIdentifier, forIndexPath: indexPath)
            cell = tempCell
            break
            
        case .Movies:
            let tempCell = collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
            cell = tempCell
            break
            
        case .Seasons:
            let tempCell = collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell_.reuseIdentifier, forIndexPath: indexPath)
            cell = tempCell
            break
            
        default:
            print("no case")
            break
            
        }
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let celldata = self.dataItem[indexPath.row]
        
        switch ListType(rawValue: self.cellType )! {
            
        case .Episode, .Seasons:
            
            guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ShowDetailsVC") as? ShowDetailsVC else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
            }
        
            detailScreen.showID = String(celldata.item_id!)
            detailScreen.cellType = cellType
            self.navigationController?.pushViewController(detailScreen, animated: true)

            
            break;
            
        case .Movies:
            
            guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("PartitionedMovieDetailVC") as? PartitionedMovieDetailVC else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
            }
            
            detailScreen.movieId = String(celldata.item_id!)
            detailScreen.cellType = cellType
            self.navigationController?.pushViewController(detailScreen, animated: true)
            break
            
        default:
            print("No case match")
            break
            
        }
        
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        let view = UICollectionReusableView()
        switch kind {
        case UICollectionElementKindSectionHeader:
            
            let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                      withReuseIdentifier: "FlickrPhotoHeaderView",
                                                                      forIndexPath: indexPath) as! FlickerPhotoHeaderView
            headerView.label.text = headerTitle
            headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, UIScreen.mainScreen().bounds.width, 100)
            headerView.label.hidden = false

            
            return headerView
            
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        
        return view
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.width,height: 100)
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let cellData = self.dataItem[indexPath.row]
        
        switch ListType(rawValue: self.cellType )! {
            
        case .Episode:
            guard let cell = cell as? SeasonEpisodeViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
            cell.configureCell( cellData )
            break
            
        case .Movies:
            guard let cell = cell as? DataItemCollectionViewCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
            cell.isFitler = isFilter
            cell.configureCell( cellData )
            break
            
        case .Seasons:
            guard let cell = cell as? DataItemCollectionViewCell_ else { fatalError("Expected to display a DataItemCollectionViewCell") }
            cell.isFilter = isFilter
            cell.configureCell( cellData )
            break
            
        default:
            break
            
        }
        
        return
    }

    
    func getItems(page:Int = 0){
        
        if (!Reachibility.isConnectedToNetwork()){
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
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        var params = Dictionary<String,AnyObject>()
        params["list_id"]   = id!
        params["page"]      = page
        params["sources"]   = FilterPreference.getString()!
		
		print(params)
        
        print(FilterPreference.getString())
   
        
        cellRequest = Alamofire.request(.POST, "http://demoz.online/tvios/public/api/get_list", parameters: params, encoding: ParameterEncoding.URL, headers: nil).responseObject{ (response:Response<itemPaginationModel, NSError>) in
                let apiResponse = response.result.value
    
                if( apiResponse?.items?.results!.count > 0 ) {
            
                    self.dataItem += (apiResponse?.items?.results)!
					
					if let nexturl = apiResponse!.items!.next_page_url {
						self.pageUrl = nexturl
					}
					
                    //self.loadingLabel.hidden = true
                    //self.activityIndicator.stopAnimating()
                    self.cellRequest?.cancel()
                    self.collectionView!.remembersLastFocusedIndexPath = true
                    self.collectionView!.reloadData()

                }
        }
    }
    
    //MARK:- Collection Scroll Delegate
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if ( ((scrollView.contentOffset.y + scrollView.frame.size.height) - 80 ) >= scrollView.contentSize.height)
        {
            let url = self.pageUrl
            if url != nil {
                let page = Int(self.queryParams(url!, paramName: "page"))
                if _page != page {
                    _page = page!
                    self.getItems(_page)
                }
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

}
