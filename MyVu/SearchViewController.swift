//
//  SearchViewController.swift
//  HelloWorld
//
//  Created by MacPro on 25/07/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

class SearchViewController: UISearchController {
    
    //MARK: - ViewController Life Cycle
    override func viewDidLoad()                  {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning()      {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let searchResultsController = storyboard!.instantiateViewControllerWithIdentifier(SearchResultsViewController.storyboardIdentifier) as? SearchResultsViewController else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        self.searchResultsUpdater = searchResultsController
        self.searchBar.placeholder = NSLocalizedString("Enter keyword (e.g. iceland)", comment: "")
        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: self)
        searchContainer.title = NSLocalizedString("Search", comment: "")
    }
}

