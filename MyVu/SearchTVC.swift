//
//  SearchTVC.swift
//  MyVu
//
//  Created by MacPro on 02/01/2017.
//  Copyright © 2017 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class SearchTVC: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView : UITableView!
	
	var storedOffsets                       = [Int: CGFloat]()
	var data : [SearchDataModel]            = [SearchDataModel]()
	//
	var apiLoadMore : Alamofire.Request?
	var nextUrl : [String?]              = [String?]()
	var mySearchBar: UISearchBar!
	

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.maskView = nil
		self.tableView.clipsToBounds = true
		
		print(self.navigationController)
		
    }
	
	override func viewWillAppear(animated: Bool) {
		print(self.navigationController)
	}
	
	var filterString = "" {
		
		didSet {
			guard	filterString != oldValue && !(filterString.isEmpty) && filterString.stringByReplacingOccurrencesOfString(" ", withString: "") != "" else {
				print("..........\nI WILL NOT SEARCH NOW OK?..........\n..........")
				return
			}
			
			let searchUrl = "http://demoz.online/tvios/public/api/search?query=" + self.filterString
			print(searchUrl)
			let safeURL = searchUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
			
			apiLoadMore?.cancel()
			data.removeAll()
			self.tableView.reloadData()
			
			Alamofire.request(.POST,safeURL).responseObject { (response: Response<SearchModel, NSError>) in
				
				let apiResponce = response.result.value
				
				if apiResponce?.movies != nil {
					apiResponce?.movies?.type = "movies"
					self.data.append((apiResponce?.movies)!)
					
					print(apiResponce?.movies?.nextPageUrl)
					//self.nextUrl.append("")
					//self.nextUrl[0] = (apiResponce?.movies?.nextPageUrl)!
				}
				
				if apiResponce?.episodes != nil {
					apiResponce?.episodes?.type = "episodes"
					self.data.append((apiResponce?.episodes)!)
					self.nextUrl.append("")
					self.nextUrl[1] = (apiResponce?.movies?.nextPageUrl)!
				}
				
				if apiResponce?.shows != nil {
					apiResponce?.shows?.type = "shows"
					self.data.append((apiResponce?.shows)!)
					//self.nextUrl.append("")
					//self.nextUrl[2] = (apiResponce?.movies?.nextPageUrl)!
				}
				
				self.tableView.reloadData()
				
				
//				let indexesPath = [ NSIndexPath(forItem: 0, inSection: 0),
//					NSIndexPath(forItem: 0, inSection: 1),
//					NSIndexPath(forItem: 0, inSection: 2) ]
//				
//				self.tableView.insertRowsAtIndexPaths(indexesPath, withRowAnimation: .None)

			}
		}
	}
	
	//MARK:- Tableview Datasource and Delegate
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return data.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(ItemContainerCell.cellIdentifier , forIndexPath: indexPath) as! ItemContainerCell
		return cell
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
		guard let tableViewCell = cell as? ItemContainerCell else { return }
		tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
		tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
		
		if data.count == 0 { return  }
	}
	
	func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		guard let tableViewCell = cell as? ItemContainerCell else { return }
		storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
	}
	
	func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return false
	}
	
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 500
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let cell = tableView.dequeueReusableCellWithIdentifier("ItemHeaderCellTableViewCell") as! ItemHeaderCellTableViewCell
		cell.configureCell()
		return cell
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "wow"
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 100
	}
	
	func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 100
	}

	
	//MARK:- SearchBar Delegate
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		searchController.searchBar.autocapitalizationType = .Words
		self.filterString = (searchController.searchBar.text)!.capitalizedString ?? ""
	}
	
}

extension SearchTVC: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView( collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return data[collectionView.tag].data!.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		let item = data[collectionView.tag].data![indexPath.row]
		var cell : UICollectionViewCell?
		

		//print(collectionView.tag)
		
		if collectionView.tag != 0 {
			
			let temp = collectionView.dequeueReusableCellWithReuseIdentifier(SeasonCell.cellIdentifier, forIndexPath: indexPath) as! SeasonCell
			temp.imgView.sd_setImageWithURL(NSURL(string: item.image!))
			temp.labelTitle.text = item.name
			cell = temp
			
		} else {
			
			let temp = collectionView.dequeueReusableCellWithReuseIdentifier(MovieCell.cellIdentifier , forIndexPath: indexPath) as! MovieCell
			temp.imgView.sd_setImageWithURL(NSURL(string: item.image!))
			temp.labelTitle.text = item.name
			cell = temp
			
		}
		
		return cell!
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

		let itemData = data[collectionView.tag].data![indexPath.row]
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		
		print(self.description)

		
		if itemData.type == "movies" {
			
			guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("PartitionedMovieDetailVC") as? PartitionedMovieDetailVC else {
				fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
			}
			detailScreen.movieId = String(itemData.id!)
			detailScreen.cellType = "movies"
			self.navigationController?.presentViewController(detailScreen, animated: true, completion: nil)
			

		} else {
		
			guard let detailScreen = storyboard.instantiateViewControllerWithIdentifier("ShowDetailsVC") as? ShowDetailsVC else {
				fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
			}
			
			
			print(self.navigationController)
			
			detailScreen.showID = String(itemData.id)
			detailScreen.cellType = "seasons"
			self.navigationController?.pushViewController(detailScreen, animated: true)
			
		}
		
	}
	
	
	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		
		if data[collectionView.tag].data!.count - 1 == indexPath.row {
			self.loadMore(nextUrl[collectionView.tag]!, collection: collectionView)
		}
	}
	
	func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		
		var size = CGSize.zero
		
		if collectionView.tag == 0 {
			size =  CGSizeMake(242, 400)
		} else {
			size =  CGSizeMake(448, 250)
		}
		
		return size
	}	
	
	//MARK:- API Services
	
	func queryParams(urlStr:String, paramName:String) -> String {
		let url = urlStr
		let urlComponents = NSURLComponents(string: url)
		let queryItems = urlComponents?.queryItems
		let params = queryItems?.filter({$0.name == "page"}).first
		return (params?.value)!
	}
	
	func loadMore(nextUrl:String = "" , collection : UICollectionView) {
		
		let count = data[collection.tag].data!.count
		
		apiLoadMore?.cancel()
		
		apiLoadMore = Alamofire.request(.POST,nextUrl).responseObject { (response: Response<SearchModel, NSError>) in
			
			let apiResponce = response.result.value
			
			if collection.tag == 0 {
				
				for item in (apiResponce?.movies?.data)! {
					self.data[collection.tag].data!.append(item)
				}
				
				self.nextUrl[collection.tag] = (apiResponce?.movies?.nextPageUrl != nil ) ? (apiResponce?.movies?.nextPageUrl)! : ""
				
			} else if collection.tag == 1 {
				
				for item in (apiResponce?.episodes?.data)! {
					self.data[collection.tag].data!.append(item)
				}
				
				self.nextUrl[collection.tag] = (apiResponce?.episodes?.nextPageUrl != nil ) ? (apiResponce?.episodes?.nextPageUrl)! : ""
				
				
			} else {
				
				for item in (apiResponce?.shows?.data)! {
					self.data[collection.tag].data!.append(item)
				}
				
				self.nextUrl[collection.tag] = (apiResponce?.shows?.nextPageUrl != nil ) ? (apiResponce?.shows?.nextPageUrl)! : ""
			}
			
			NSOperationQueue.mainQueue().addOperationWithBlock({
			
				var indexPathsToReload = [NSIndexPath]()
				for i in count ..< self.data[collection.tag].data!.count {
					indexPathsToReload.append(NSIndexPath(forItem: i, inSection: 0))
				}
				
				collection.performBatchUpdates({
					collection.insertItemsAtIndexPaths(indexPathsToReload)
				}, completion: nil)
				
			})
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
	
}


