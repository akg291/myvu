/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A `UICollectionViewController` who's cells each contain a `UICollectionView`. This class demonstrates how to ensure focus behaves correctly in this situation.
*/

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage

class CollectionViewContainerViewController: UIViewController,UISearchResultsUpdating, UISearchBarDelegate ,UICollectionViewDelegate,UICollectionViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Variables
    enum Group: String {
        case Movies
        case Shows
        static let allGroups: [Group] = [.Movies, .Shows]
    }
    private static let minimumEdgePadding = CGFloat(90.0)
    private var dataItemsByGroup_ : [[Result]] = [[Result]]()
    private var resultMovieItems  = [Result]()
    var moviesRequest: Alamofire.Request?
    private var resultShowsItems  = [Result]()
    var shpowsRequest: Alamofire.Request?
    private let dataItemsByGroup: [[DataItem]] = {
        return DataItem.Group.allGroups.map { group in
            return DataItem.sampleItems.filter { $0.group == group }
        }
    }()
    
    var mySearchBar: UISearchBar!

    
    var filterString = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }
            filterString = filterString.stringByReplacingOccurrencesOfString(" ", withString: "")
            // Apply the filter or show all items if the filter string is empty.
            if filterString.isEmpty {
                //filteredDataItems = allDataItems
                self.moviesRequest?.cancel()
                self.shpowsRequest?.cancel()
                dataItemsByGroup_ = [[Result]]()
                self.collectionView!.reloadData()
            }
            else {
                self.moviesRequest?.cancel()
                self.shpowsRequest?.cancel()
                dataItemsByGroup_ = [[Result]]()
                self.collectionView!.reloadData()
                let searchUrl = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/search/movie/title/" + self.filterString
                let safeURL = searchUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                
                var indexPaths: [NSIndexPath] = []
                for s in 0..<self.collectionView!.numberOfSections() {
                    for i in 0..<collectionView!.numberOfItemsInSection(s) {
                        indexPaths.append(NSIndexPath(forItem: i, inSection: s))
                    }
                }
                
                
                
                self.moviesRequest = Alamofire.request(.GET,safeURL).responseObject {
                    (response: Response<MoviesSearchResultModel, NSError>) in
                    
                    let apiResponce = response.result.value
                    
                    
                    
                    print(apiResponce?.results?.count)
                    
                    if ( apiResponce?.results?.count > 0 ){
                        
                        self.resultMovieItems = [Result]()
                        for result in (apiResponce?.results)! {
                            result.group = "Movies"
                            self.resultMovieItems.append(result)
                        }
                        self.dataItemsByGroup_.append(self.resultMovieItems)
                        
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        if ( indexPaths.contains(indexPath)){
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }else {
                            self.collectionView!.reloadData()
                        }
                        
                        
                        let searchUrl_ = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/search/title/" + self.filterString
                        let safeURL_ = searchUrl_.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        self.shpowsRequest = Alamofire.request(.GET,safeURL_).responseObject {
                            (response: Response<MoviesSearchResultModel, NSError>) in
                            let apiResponce = response.result.value
                            if ( apiResponce?.results?.count > 0 ){
                                for result in (apiResponce?.results)! {
                                    result.group = "Shows"
                                    self.resultShowsItems.append(result)
                                }
                                self.dataItemsByGroup_.append(self.resultShowsItems)
                                let indexPath = NSIndexPath(forRow: 4, inSection: 0)
                                if ( indexPaths.contains(indexPath)){
                                    self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                                }else {
                                    self.collectionView!.reloadData()
                                }
                            }
                        }
                        
                        print("\n URL 1 \(safeURL) \n ")
                        print("\n URL 1 \(safeURL_) \n ")
                        
                    }
                }

                print(dataItemsByGroup_)
            }
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        //Make sure their is sufficient padding above and below the content.
        guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionView.contentInset.top = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.top
        collectionView.contentInset.bottom = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.bottom
        collectionView.contentInset.left = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.left
        collectionView.contentInset.right = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.right
        
        for view in self.view.subviews {
            print(view)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //containerView_.frame = CGRectMake(0,0, scroll.contentSize.width, scroll.contentSize.height)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Our collection view displays 1 section per group of items.
        //print(dataItemsByGroup_.count)
        return dataItemsByGroup_.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        //print(section)
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
    
        return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CollectionViewContainerCell else { fatalError("Expected to display a `CollectionViewContainerCell`.") }
        // Configure the cell.
        let sectionDataItems = dataItemsByGroup_[indexPath.section]
        cell.APIrequestType = "Search"
        cell.parentViewController = self
        cell.configureWithDataItems(sectionDataItems,section: indexPath.section)
    }
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
            Return `false` because we don't want this `collectionView`'s cells to
            become focused. Instead the `UICollectionView` contained in the cell
            should become focused.
        */
        return false
    }
    func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = UICollectionReusableView()
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,withReuseIdentifier: "FlickrPhotoHeaderView",forIndexPath: indexPath) as! FlickerPhotoHeaderView
            if ( indexPath.row == 0 && indexPath.section == 0 ){
                headerView.label.text = "Movies"
            }else if ( indexPath.row == 0 && indexPath.section == 1 ){
                headerView.label.text = "Shows"
            }
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return view
    }
    
    
 
    
    //MARK: - Others

    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        //self.moviesRequest?.cancel()
        //self.shpowsRequest?.cancel()
        
        print(searchController.searchBar.text)
        
        
        self.filterString = searchController.searchBar.text ?? ""
        
        let query = searchController.searchBar.text!.trim()
        if !query.isEmpty {
            //self.delegate?.show1()
        }else {
            //self.delegate?.show2()
        }
    }
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    } //F.E.
    
    

}
