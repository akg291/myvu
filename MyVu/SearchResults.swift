//
//  SearchResults.swift
//  HelloWorld
//
//  Created by MacPro on 09/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage

protocol SearchResultsViewControllerDelegate_ {
    func show1_() -> Void
    func show2_() -> Void
}

class SearchResults : UIViewController,UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var parentTableView: UITableView!
    
    private var showsResultItems  = [Result]()
    
    var searchShowsRequest: Alamofire.Request?
    
    var delegate: SearchResultsViewControllerDelegate_?
    
    // MARK: Properties
    static let storyboardIdentifier = "SearchResults"
    
    func makeShowsSearchRequest (searchString : String) {
        
        let searchUrl = "https://api-public.guidebox.com/v1.43/US/wBQ4DHVkRfrlQJIdb7Fi5HcJB9QLZ7/search/title/" + searchString
        
        self.showsResultItems = [Result]()
        
        self.searchShowsRequest?.cancel()
        
        searchShowsRequest = Alamofire.request(.GET,searchUrl).responseObject {
            
            (response: Response<MoviesSearchResultModel, NSError>) in
            
            let apiResponce = response.result.value
            
            if ( apiResponce?.results?.count > 0 ){
                
                //let downlaoder : SDWebImageDownloader = SDWebImageDownloader .sharedDownloader()
                
                for result in (apiResponce?.results)! {
                    
                    self.showsResultItems.append(result)
                    
                    //                            self.featuredPostImageUrls.append(post.image!)
                    //                            self.featuredPostIds.append(post.post_id!)
                    
                    
                }
                let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                self.parentTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                //self.collectionViewA.reloadData()
                
            }else if ( apiResponce?.results?.count < 0 ){
                
                //                let alert = UIAlertController(title: "Error!", message: "API respond nil", preferredStyle: UIAlertControllerStyle.Alert)
                //                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                //                    switch action.style{
                //                    case .Default:
                //                        print("default")
                //
                //                    case .Cancel:
                //                        print("cancel")
                //
                //                    case .Destructive:
                //                        print("destructive")
                //                    }
                //                }))
                //                self.presentViewController(alert, animated: true, completion: nil)
            }else {
                print(apiResponce?.toJSONString())
            }
            
        }
    }
    
    var filterString = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }
            
            // Apply the filter or show all items if the filter string is empty.
            if filterString.isEmpty {
                //filteredDataItems = allDataItems
            }
            else {
                
                print(filterString)
                //makeMoviesSearchRequest(filterString)
                //makeShowsSearchRequest(filterString)
                
                //filteredDataItems = allDataItems.filter { $0.title.localizedStandardContainsString(filterString) }
            }
            
            // Reload the collection view to reflect the changes.
            //self.collectionViewA.reloadData()
        }
    }
    
    override func viewDidLoad() {
        // Initialize the collection views, set the desired frames
        parentTableView.delegate = self
        parentTableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
//        guard let tableViewCell = cell as? NewTableCell else { return }
//        tableViewCell.loadData(filterString)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filterString = searchController.searchBar.text ?? ""
        
        let query = searchController.searchBar.text!.trim()
        if !query.isEmpty {
            self.delegate?.show1_()
        }else {
            self.delegate?.show2_()
        }
    }
}