/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A `UICollectionViewController` subclass that is used to show `DataItem` search results for the `UISearchController` shown by `SearchViewController`.
*/

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage

protocol SearchResultsViewControllerDelegate {
    func show1() -> Void
    func show2() -> Void
}

class SearchResultsViewController: UIViewController, UISearchResultsUpdating,UICollectionViewDelegate,UICollectionViewDataSource{
    
    // MARK: - Variables
    static let storyboardIdentifier = "SearchResultsViewController"
    var request: Alamofire.Request?
    private static let minimumEdgePadding = CGFloat(90.0)
    let collectionViewAIdentifier = "CollectionViewACell"
    let collectionViewBIdentifier = "CollectionViewBCell"
    let collectionViewCIdentifier = "CollectionViewCCell"
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var delegate: SearchResultsViewControllerDelegate?
    private let dataItemsByGroup: [[DataItem]] = {
        return DataItem.Group.allGroups.map { group in
            return DataItem.sampleItems.filter { $0.group == group }
        }
    }()
    
    //MARK: - Outlets
    @IBOutlet weak var collectionViewA: UICollectionView!
    @IBOutlet weak var collectionViewB: UICollectionView!
    @IBOutlet weak var collectionViewC: UICollectionView!
    private var resultItems  = [Result]()
    var filterString = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }
            // Apply the filter or show all items if the filter string is empty.
            if filterString.isEmpty {
            }
            else {
                let searchUrl = "https://api-public.guidebox.com/v1.43/US/wBQ4DHVkRfrlQJIdb7Fi5HcJB9QLZ7/search/movie/title/" + filterString
                self.resultItems = [Result]()
                self.request?.cancel()
                request = Alamofire.request(.GET,searchUrl).responseObject {
                    (response: Response<MoviesSearchResultModel, NSError>) in
                    let apiResponce = response.result.value
                    if ( apiResponce?.results?.count > 0 ){
                        for result in (apiResponce?.results)! {
                            self.resultItems.append(result)
                        }
                        self.collectionViewA.reloadData()
                    }else if ( apiResponce?.results?.count < 0 ){
                        let alert = UIAlertController(title: "Error!", message: "API respond nil", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                            switch action.style{
                            case .Default:
                                print("default")
                            case .Cancel:
                                print("cancel")
                            case .Destructive:
                                print("destructive")
                            }
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else {
                        print(apiResponce?.toJSONString())
                    }
                }
            }
            // Reload the collection view to reflect the changes.
            self.collectionViewA.reloadData()
        }
    }
    
    //MARK: - ViewController lifeCycle and updateResult
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterString = searchController.searchBar.text ?? ""
        let query = searchController.searchBar.text!.trim()
        if !query.isEmpty {
            self.delegate?.show1()
        }else {
            self.delegate?.show2()
        }
    }
    override func viewDidLoad() {
        // Initialize the collection views, set the desired frames
        collectionViewA.delegate = self
        collectionViewB.delegate = self
        collectionViewC.delegate = self
        collectionViewA.dataSource = self
        collectionViewB.dataSource = self
        collectionViewC.dataSource = self
        // Do any additional setup after loading the view, typically from a nib
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height

        // Make sure their is sufficient padding above and below the content.
        guard let collectionViewC = collectionViewC, layoutc = collectionViewC.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionViewC.contentInset.top = SearchResultsViewController.minimumEdgePadding - layoutc.sectionInset.top
        collectionViewC.contentInset.bottom = SearchResultsViewController.minimumEdgePadding - layoutc.sectionInset.bottom
        self.view.addSubview(collectionViewA)
        self.view.addSubview(collectionViewB)
        self.view.addSubview(collectionViewC)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var view = UICollectionReusableView()
        if ( collectionView == collectionViewA || collectionView == collectionViewB ){
            //1
            switch kind {
            //2
            case UICollectionElementKindSectionHeader:
                //3
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,withReuseIdentifier: "FlickrPhotoHeaderView",forIndexPath: indexPath) as! FlickerPhotoHeaderView
                headerView.label.text = "My Title"
                view = headerView
            default:
                //4
                assert(false, "Unexpected element kind")
            }
        }else if ( collectionView == collectionViewC ){
            let commentView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "GalleryItemCommentView", forIndexPath: indexPath) as! GalleryItemCommentView
            commentView.commentLabel.text = "Supplementary view of kind \(kind)"
            view = commentView
        }
        return view
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int                    {
        if ( collectionView == collectionViewA || collectionView == collectionViewB ){
            return 1
        }else {
            return 2
        }
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ( collectionView == collectionViewA || collectionView == collectionViewB ){
            return resultItems.count
        }else {
            return 1
        }   
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        if collectionView == self.collectionViewA {
            let cellA = collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
            // Set up cell
            return cellA
        }
        else  if collectionView == self.collectionViewB {
            let cellB = collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier1, forIndexPath: indexPath)
            return cellB
        }
        else{
            let cellC =  collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath)
            return cellC
        }
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView == collectionViewA || collectionView == collectionViewA){
            guard let cell = cell as? DataItemCollectionViewCell else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
            let downlaoder : SDWebImageDownloader = SDWebImageDownloader .sharedDownloader()
            downlaoder.downloadImageWithURL(
                NSURL(string: resultItems[indexPath.row].previewImage!),
                options: SDWebImageDownloaderOptions.UseNSURLCache,
                progress: nil,
                completed: { (image, data, error, bool) -> Void in
                    if image != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imageView.image = image
                        })
                    }
            })
            cell.label.text = resultItems[indexPath.row].title
        }else if ( collectionView == collectionViewC ){
            guard let cell = cell as? CollectionViewContainerCell else { fatalError("Expected to display a `CollectionViewContainerCell`.") }
            // Configure the cell.
            let sectionDataItems = dataItemsByGroup[indexPath.section]
            cell.configureWithDataItems(sectionDataItems)
        }
    }
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
         Return `false` because we don't want this `collectionView`'s cells to
         become focused. Instead the `UICollectionView` contained in the cell
         should become focused.
         */
        if ( collectionView == collectionViewA || collectionView == collectionViewB ){
            return true
        }else {
            return false
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)        {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}