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


class CollectionViewContainerViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView       : UICollectionView!
	@IBOutlet weak var loader				: UIActivityIndicatorView!
    
    //MARK: - Variables
    private static let minimumEdgePadding = CGFloat(90.0)
    //
    var data : [SearchDataModel] = [SearchDataModel]()
    var apiSearchRequest: Alamofire.Request?
    //
    var mySearchBar: UISearchBar!
    let headerFocusGuide = UIFocusGuide()
    
    var filterString = "" {
		
		didSet {
			
            guard filterString != oldValue && !(filterString.isEmpty) && filterString != "" else {
                print("..........\nI WILL NOT SEARCH NOW OK?..........\n..........")
				
				
				
                return
			}
		
            let searchUrl = "http://demoz.online/tvios/public/api/search?query=" + self.filterString
            let safeURL = searchUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
			
			
			print("=======================\n --REQUEST--\n=======================")
			
			if data.count > 0 {
				data.removeAll()
			}
		
			apiSearchRequest?.cancel()
			self.loader.startAnimating()

            apiSearchRequest = Alamofire.request(.POST,safeURL).responseObject { (response: Response<SearchModel, NSError>) in
				
				let apiResponce = response.result.value
	
				print("movie count \(apiResponce?.movies)")
				print("episodes count \(apiResponce?.episodes)")
				print("shows count \(apiResponce?.shows)")
				
                if apiResponce?.movies != nil {
                    apiResponce?.movies?.type = "movies"
                    apiResponce?.movies?.query = self.filterString
                    self.data.append((apiResponce?.movies)!)
                }
				
                if apiResponce?.episodes != nil {
                    apiResponce?.episodes?.type = "episodes"
                    apiResponce?.movies?.query = self.filterString
                    self.data.append((apiResponce?.episodes)!)
                }
				
                if apiResponce?.shows != nil {
                    apiResponce?.shows?.type = "shows"
                    apiResponce?.shows?.query = self.filterString
                    self.data.append((apiResponce?.shows)!)
                }
				
				self.loader.stopAnimating()
                self.collectionView.reloadData()
				
            }
        }
    }
    
    // MARK :- UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        //Make sure their is sufficient padding above and below the content.
        /*guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionView.contentInset.top = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.top
        collectionView.contentInset.bottom = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.bottom
        collectionView.contentInset.left = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.left
        collectionView.contentInset.right = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.right*/
		
		loader.hidesWhenStopped = true
		loader.transform = CGAffineTransformMakeScale(1.25, 1.25)
        self.collectionView!.contentSize = CGSizeMake(1920, 2800)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        
        /*
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCellOld.reuseIdentifier, forIndexPath: indexPath) as! CollectionViewContainerCellOld
        cell.activityIndicator.startAnimating()
        cell.loadingLabel.hidden = false
        return cell
        */
        
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewContainerCellOld.reuseIdentifier, forIndexPath: indexPath) as! CollectionViewContainerCellOld
        
        let sectionData = data[indexPath.section].data
		let type		= data[indexPath.section].type
		
        cell.APIrequestType         = "Search"
        cell.parentViewController   = self
        
        var mySection = 0
		
		
		switch type! { //indexPath.section {
			case "movies":
				mySection = 0
				break
				
			case "shows":
				mySection = 1
				break
				
			case "episodes":
				mySection = 2
				break
				
			default:
				print("no sections")
				break
        }
		
		if self.data[indexPath.section].nextPageUrl != nil {
            cell.nextUrl = self.data[indexPath.section].nextPageUrl!
        }
		
		
        cell.configureWithDataItems(sectionData!,section: mySection)
        return cell
		
    }
    
    // MARK: - UICollectionViewDelegate
    /*func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CollectionViewContainerCellOld else { fatalError("Expected to display a `CollectionViewContainerCell`.") }
        
        let sectionData = data[indexPath.section].data
        cell.APIrequestType         = "Search"
        cell.parentViewController   = self
        
        var mySection = 0
        
        switch indexPath.section {
            
        case 0:
            mySection = 0
            break
            
        case 1:
            mySection = 1
            break
            
        case 2:
            mySection = 2
            break
            
        default:
            print("no sections")
            break
            
        }
        if self.data[indexPath.section].nextPageUrl != nil {
            cell.nextUrl = self.data[indexPath.section].nextPageUrl!
        }
        
        cell.configureWithDataItems(sectionData!,section: mySection)
    }*/
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = UICollectionReusableView()
		let type		= data[indexPath.section].type
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,withReuseIdentifier: "FlickrPhotoHeaderView",forIndexPath: indexPath) as! FlickerPhotoHeaderView

            switch type! {
            
            case "movies":
                headerView.label.text = "Movies"
                headerView.searchBtn.hidden = false
                headerView.searchBtn.backgroundColor = UIColor.clearColor()
                break
            
            case "shows":
                headerView.label.text = "Show"
                headerView.searchBtn.hidden = true
                break
                
            case "episodes":
                headerView.label.text = "Episode"
                headerView.searchBtn.hidden = true
                break

            default:
                print("no sections")
                break
                
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
        
        searchController.searchBar.autocapitalizationType = .Words
		self.apiSearchRequest?.cancel()
		
		delay(3) {
			self.filterString = (searchController.searchBar.text)!.capitalizedString ?? ""
			print(self.filterString)
		}
		
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {}

}
