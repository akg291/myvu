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


protocol CollectionViewContainerCellDelegate {
    func CollectionViewContainerCellDelegate( data:[ItemModel]  , indexPath: NSIndexPath )
}

class CollectionViewContainerCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, CollectionCellReusableViewDelegate {
    
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var cellRequest : Alamofire.Request?
    var parentViewController : UIViewController!
    var cellType : String = ""
    var APIrequestType : String = ""

    
    var collectionType : String = ""
    // MARK: Properties
    static let reuseIdentifier = "CollectionViewContainerCell"
    @IBOutlet var collectionView: UICollectionView!
    
    //private var dataItems = [DataItem]()
    private var dataItems_ = [Result]()
    private var episodesDataModels = [EpisodeModel]()
    private let cellComposer = DataItemCellComposer()
    //
    private var dataList:ListModel!
    private var dataItems:[ItemModel] = [ItemModel]()
    private var indexPath:NSIndexPath!
    private var layout: UICollectionViewFlowLayout!
    private var _page:Int = 1
    //
    private var isLoaded : Bool = false
    /*
     * Homescreen Or Filterscreen
     */
    var isFilter      = false
    
    private var _delegate:CollectionViewContainerCellDelegate?
    var delegate:CollectionViewContainerCellDelegate {
        get{ return _delegate! }
        set{
            if( _delegate == nil ){
                _delegate = newValue
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        isLoaded = true

    }
    
    func configureCell( data:ListModel, indexPath:NSIndexPath ){
        
        print(data.items?.count)
        print(data.category)
        
        self.dataList = data
        self.indexPath = indexPath
        self.cellRequest?.cancel()
        self.loadingLabel.hidden = true
        self.activityIndicator.stopAnimating()
        
        
        self.cellType = dataList.category!
        
        let cellPadding = CGFloat(( indexPath.row == 0 ) ? 90.0 : 45.0 )
        layout.sectionInset = UIEdgeInsets(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        
        print(cellType)
        
        switch ListType(rawValue: cellType )! {
            
        case .Movies:
    
            layout.itemSize = CGSize(width: 240 , height:390)
            layout.minimumLineSpacing = 100
            self.collectionView.collectionViewLayout = layout
            //self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 390)
        
        break
        
        case .Seasons, .Episode:
            
            layout.itemSize = CGSize(width: 448 , height: 290)
            layout.minimumLineSpacing = 100
            //self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 290)
            self.collectionView.collectionViewLayout = layout
            
        break
            
        default:
            print("No case match")
        break
            
        }
        
        self.collectionView.reloadData()
        
    }
    
    override var preferredFocusedView: UIView? {
        return collectionView
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print(self.dataList.items)
        
        let count = (self.dataList.items?.count)!
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
        switch ListType(rawValue: self.cellType )! {
        
        case .Episode, .Seasons:
            
            guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ShowDetailsVC") as? ShowDetailsVC else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
            }
            
            detailScreen.showID = String(self.dataList.items![indexPath.row].item_id!)
            detailScreen.cellType = cellType
            parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
            
            if ( APIrequestType == "Search" ){
                parentViewController.presentingViewController?.navigationController?.pushViewController(detailScreen, animated: true)
            }
            
        break;
            
        case .Movies:
            
            guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("PartitionedMovieDetailVC") as? PartitionedMovieDetailVC else {
                fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
            }
            detailScreen.movieId = String(self.dataList.items![indexPath.row].item_id!)
            detailScreen.cellType = cellType
            parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
            
            if ( APIrequestType == "Search" ){
                parentViewController.presentingViewController?.navigationController?.pushViewController(detailScreen, animated: true)
            }
            
        break
        
        default:
            print("No case match")
        break
            
        }
    }
    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        
        if !isLoaded {
            return NSIndexPath(forRow: 0, inSection: 0)
        }
        
        return nil
    }
    
    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let cellData = self.dataList.items?[indexPath.row] else {
            fatalError("Cell Data Not found")
        }

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
        
        if indexPath.row == (dataItems.count - 1) && APIrequestType != "Search" {
            //loadMore Movies Data
            print("loading more shows")
            //apiRequestForShows()
        }
        
        return
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        var size = CGSize.zero
        
        if self.dataList.items?.count < 10 {
            return size
        }
        
        size = CGSize(width: 448 , height: 290)
        return size
        
    }
    
    func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = UICollectionReusableView()
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionFooter:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,withReuseIdentifier: "ViewMoreCell",forIndexPath: indexPath) as! ViewMoreCollectionReusableView

            headerView.btnViewMore.center = CGPointMake(160.0, 240.0)
            headerView.delegate = self
            
            return headerView
            
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        
        return view
    }

    func collectionCellReusableViewDelegate() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ListCollectionViewController") as? ListCollectionViewController else {
            fatalError("Unable to instatiate a ListCollectionViewController from the storyboard.")
        }
        
        detailScreen.cellType = cellType
        detailScreen.headerTitle = self.dataList.name!
        detailScreen.id       = String((self.dataList.items![0].list_id)!)
        parentViewController.navigationController?.pushViewController(detailScreen, animated: true)
    }

}
