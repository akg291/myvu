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



enum ListType: String {
    case Movies         = "movies"
    case Seasons        = "shows"
    case Episode        = "episodes"
    case Uncategorize   = "uncat"
    
    static let allGroups: [ListType] = [.Movies, .Seasons , .Episode, .Uncategorize]
}

class HomeCollectionViewContainerVC:UIViewController,
									UICollectionViewDelegate,
									UICollectionViewDataSource,
									ContentLoadMoreProtocol,
									SearchResultsViewControllerDelegate,
									CollectionViewContainerCellDelegate,
									SteamViewControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var loader : UIActivityIndicatorView!

    
    private static let minimumEdgePadding = CGFloat(90.0)
    private var dataItems:[ListModel] = [ListModel]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    private var searchController = UISearchController()
    private var m1 = CollectionViewContainerViewController()
    
    /* 
     * Homescreen Or Filterscreen
     */
    
    var isFilter      = false
	var filterServicesArr:[Dictionary<String, String>] = []
    
    //MARK: - Actions
    @IBAction func goToSort(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
//        guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("SourcesSelectionVC") as? SourcesSelectionVC else {
//            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
//        }

        guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("StreamViewController") as? StreamViewController else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
		detailScreen.delegate = self
        self.navigationController!.pushViewController(detailScreen, animated: true)
    }
    @IBAction func goToSearch (sender: UIButton) {
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let searchResultsController1 = storyboard.instantiateViewControllerWithIdentifier("CollectionViewContainerViewController") as? CollectionViewContainerViewController else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        
        m1 = searchResultsController1
        m1.definesPresentationContext = true
        
        searchController    = UISearchController(searchResultsController: m1)
        m1.mySearchBar      = searchController.searchBar
        searchController.searchResultsUpdater = m1
        searchController.searchBar.placeholder = NSLocalizedString("Enter keyword (e.g. iceland)", comment: "")
        if #available(tvOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
	
//		let searchContainer = UISearchContainerViewController(searchController: searchController)
//		self.navigationController!.pushViewController(searchContainer , animated: true)
//		print(self.navigationController)
		
		searchController.view.backgroundColor = UIColor(patternImage: UIImage(named: "search-bg.png")!)
        //searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        searchController.searchBar.canBecomeFocused()
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = NSLocalizedString("Search", comment: "")


        self.navigationController!.pushViewController(searchContainer , animated: true)
    }
    
    //MARK: - Others
    func loadMoreMoviesData(){
        print("loading more movies data")
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
        //-
        //self.getListDetail()
    }
	
	override func viewWillAppear(animated: Bool) {
		self.getListDetail()
	}

	
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Our collection view displays 1 section per group of items.
        return self.dataItems.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Each section contains a single `CollectionViewContainerCell`.
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCell.reuseIdentifier, forIndexPath: indexPath) as! CollectionViewContainerCell
        cell.parentViewController = self
        cell.isFilter = isFilter
        cell.delegate = self
        

        cell.configureCell(dataItems[indexPath.section], indexPath: indexPath)
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
        if (section == 0 && !isFilter){
            return CGSize(width: UIScreen.mainScreen().bounds.width,height: 200)
        }else {
            return CGSize(width: UIScreen.mainScreen().bounds.width,height: 60)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let view = UICollectionReusableView()
        switch kind {
        case UICollectionElementKindSectionHeader:
            
            let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                      withReuseIdentifier: "FlickrPhotoHeaderView",
                                                                      forIndexPath: indexPath) as! FlickerPhotoHeaderView

            headerView.label.text = dataItems[indexPath.section].name
            
            if ( indexPath.section == 0 && !isFilter){
                
                headerView.brandName.hidden = false
                headerView.searchBtn.hidden = false
                headerView.searchBtn.addTarget(self, action: #selector(HomeCollectionViewContainerVC.goToSearch(_:)), forControlEvents: .PrimaryActionTriggered)
                headerView.sortBtn.hidden = false
                headerView.sortBtn.addTarget(self, action: #selector(HomeCollectionViewContainerVC.goToSort(_:)), forControlEvents: .PrimaryActionTriggered)
                headerView.searchBtn.updateFocusIfNeeded()
                headerView.searchBtn.setNeedsFocusUpdate()
                
            }else {
                
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
    
    //MARK:- API Services
    
    private func getListDetail(){
		
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
            return
        }
		
        var urlString = "http://demoz.online/tvios/public/api/get_all_lists"
    
        //Filter Logic
        if !isFilter && filterServicesArr.count > 0 {
			
			let filterStr =  FilterPreference.getString()!
			urlString = "http://demoz.online/tvios/public/api/get_all_lists?sources=\(filterStr)"
			print(urlString)
			
		}
		
		if dataItems.count == 0 {
			loader.startAnimating()
		}
		
        Alamofire.request(.POST, urlString).responseObject{ (response:Response<ListDataModel, NSError>) in
			
			self.loader.stopAnimating()
			
            let apiResponse = response.result.value
			
			if ( apiResponse?.results?.count > 0 ){
				
				self.dataItems = (apiResponse?.results)!
				dispatch_async(dispatch_get_main_queue(),{
					self.collectionView.reloadData()
				})
				
            }
        }
        
    }
    
    //MARK:- CollectionView Container Cell Delegate
    
    func CollectionViewContainerCellDelegate(data: [ItemModel], indexPath: NSIndexPath) {
        self.dataItems[indexPath.section].items! += data
        print(self.dataItems[indexPath.section].items!.count)
        self.collectionView.reloadData()
    }
    
    func makeJsonArr(arr: [String]) -> String? {
        var para = [NSMutableDictionary()]
        para.removeAll()
        for item in arr {
            let paraT = NSMutableDictionary()
            paraT.setValue(item, forKey: "service_id")
            para.append(paraT)
        }
        let jsonData: NSData
        do{
            jsonData = try NSJSONSerialization.dataWithJSONObject(para, options: NSJSONWritingOptions())
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            return jsonString
            
        } catch _ {
            return nil
        }
    }
	
	
	// MARK :- StreamVC Delegate
	
	func streamViewControllerDelegate(didSelectStream filterItem: [Dictionary<String, String>]) {
		
		self.filterServicesArr	= filterItem
		self.isFilter			= false
		
		FilterPreference.save(filterItem)
		self.getListDetail()
	}
    
}


class FilterPreference : NSObject {
	
	// MARK:- Save Selected Filters
	class func save(filters : [Dictionary<String,String>]){

		print(filters)
		FilterPreference.delete()
		let preference = NSUserDefaults.standardUserDefaults() 
		preference.setObject(filters, forKey: "filters")
		preference.synchronize()
		
	}
	
	// MARK:- Get Selected Filters
	class func get() -> [Dictionary<String,String>]? {
		
		let preference = NSUserDefaults.standardUserDefaults()
		
		if let filters = preference.objectForKey("filters") as? [Dictionary<String,String>] {
			print(filters)
			return filters
		} else {
			return nil
		}
	}
	
	// MARK:- Delete Saved Filters
	class func delete(){
		
		let preference = NSUserDefaults.standardUserDefaults()
		preference.removeObjectForKey("filters")
		preference.synchronize()
		
	}
	
	class func getString() -> String? {
	
		let jsonData:NSData!
		let filterServicesArr  = FilterPreference.get()
		
		if filterServicesArr == nil || filterServicesArr?.count == 0 {
			return ""
		}
		
		print(filterServicesArr)
		
		do{
			jsonData = try NSJSONSerialization.dataWithJSONObject(filterServicesArr!, options: NSJSONWritingOptions())
			let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
			let str = jsonString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
			
			return str
			
		} catch _ {
			return nil
		}
	}
}
