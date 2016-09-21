//
//  HomeCollectionViewContainerVC.swift
//  HelloWorld
//
//  Created by MacPro on 15/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage

class HomeCollectionViewContainerVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,ContentLoadMoreProtocol,SearchResultsViewControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    enum Group: String {
        case Movies
        case Shows
        static let allGroups: [Group] = [.Movies, .Shows]
    }
    private let cellTypes : [String] = ["Movies","Shows"]
    private static let minimumEdgePadding = CGFloat(90.0)
    private var dataItemsByGroup_ : [[Result]] = [[Result]]()
    private let dataItemsByGroup: [[DataItem]] = {
        return DataItem.Group.allGroups.map { group in
            return DataItem.sampleItems.filter { $0.group == group }
        }
    }()
    var searchController = UISearchController()
    var m1 = CollectionViewContainerViewController()
    
    
    //MARK: - Actions
    @IBAction func goToSort (sender: UIButton)   {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("SourcesSelectionVC") as? SourcesSelectionVC else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        self.navigationController!.pushViewController(detailScreen, animated: true)
    }
    @IBAction func goToSearch (sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let searchResultsController1 = storyboard.instantiateViewControllerWithIdentifier("CollectionViewContainerViewController") as? CollectionViewContainerViewController else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        m1 = searchResultsController1
        
        searchController = UISearchController(searchResultsController: m1)
        searchController.searchResultsUpdater = m1
        searchController.searchBar.placeholder = NSLocalizedString("Enter keyword (e.g. iceland)", comment: "")
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.view.backgroundColor = UIColor(patternImage: UIImage(named: "search-bg.png")!)
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = NSLocalizedString("Search", comment: "")
        self.navigationController!.pushViewController(searchContainer, animated: true)
    }
    
    //MARK: - Others
    func loadMoreMoviesData(){
        print("loading more movies data")
        //apiRequestForMovies()
    }
    func loadMoreShowsData() {
        print("reloading movies data")
    }
    func show1() {
        (searchController.searchResultsController as! SearchResultsViewController).collectionViewA.hidden = true
        (searchController.searchResultsController as! SearchResultsViewController).collectionViewB.hidden = true
        (searchController.searchResultsController as! SearchResultsViewController).collectionViewC.hidden = false
    }
    func show2() {
        (searchController.searchResultsController as! SearchResultsViewController).collectionViewA.hidden = false
        (searchController.searchResultsController as! SearchResultsViewController).collectionViewB.hidden = false
        (searchController.searchResultsController as! SearchResultsViewController).collectionViewC.hidden = true
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "search-bg.png")!)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // Make sure their is sufficient padding above and below the content.
        guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionView.contentInset.top = HomeCollectionViewContainerVC.minimumEdgePadding - layout.sectionInset.top
        collectionView.contentInset.bottom = HomeCollectionViewContainerVC.minimumEdgePadding - layout.sectionInset.bottom
        collectionView.contentInset.left = HomeCollectionViewContainerVC.minimumEdgePadding - layout.sectionInset.left
        collectionView.contentInset.right = HomeCollectionViewContainerVC.minimumEdgePadding - layout.sectionInset.right
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Our collection view displays 1 section per group of items.
        print(dataItemsByGroup_.count)
        return 2
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        print(section)
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath) as! CollectionViewContainerCell
        cell.activityIndicator.startAnimating()
        cell.parentViewController = self
        cell.cellType = cellTypes[indexPath.section]
        cell.requestCellData()
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    }
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
         Return `false` because we don't want this `collectionView`'s cells to
         become focused. Instead the `UICollectionView` contained in the cell
         should become focused.
         */
        return false
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (section == 1){
            return CGSize(width: UIScreen.mainScreen().bounds.width,height: 50)
        }else {
            return CGSize(width: UIScreen.mainScreen().bounds.width,height: 200)
        }
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = UICollectionReusableView()
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                      withReuseIdentifier: "FlickrPhotoHeaderView",
                                                                      forIndexPath: indexPath)
                    as! FlickerPhotoHeaderView
            
            if ( indexPath.section == 0 ){
                headerView.label.text = "Top Rated Movies"
                headerView.brandName.hidden = false
                headerView.searchBtn.hidden = false
                headerView.searchBtn.addTarget(self, action: #selector(HomeCollectionViewContainerVC.goToSearch(_:)), forControlEvents: .PrimaryActionTriggered)
                headerView.sortBtn.hidden = false
                headerView.sortBtn.addTarget(self, action: #selector(HomeCollectionViewContainerVC.goToSort(_:)), forControlEvents: .PrimaryActionTriggered)
                
            }else if ( indexPath.section == 1 ){
                headerView.label.text = "Shows"
                headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, UIScreen.mainScreen().bounds.width, 50)
                headerView.brandName.hidden = true
                headerView.searchBtn.hidden = true
                headerView.sortBtn.hidden = true
            }
            return headerView
            
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        
        return view
    }
}

