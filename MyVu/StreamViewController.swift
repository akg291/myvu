//
//  StreamViewController.swift
//  MyVu
//
//  Created by MacPro on 08/12/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

protocol SteamViewControllerDelegate {
	func streamViewControllerDelegate( didSelectStream filterItem : [Dictionary<String , String>]  )
}

class StreamViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
	
    @IBOutlet weak var tableView    : UITableView!
    @IBOutlet weak var btnConfirm   : UIButton!
    @IBOutlet weak var btnDeselect  : UIButton!
    
    private var focusGuide: UIFocusGuide!
    
    override weak var preferredFocusedView: UIView? {
        if leftGesture {
            return btnDeselect
        } else if ( rightGesture ){
            return btnConfirm
        }else {
            return self.tableView
        }
    }
    
    var dataPlayBack : [PlaybackSource] = [PlaybackSource]()
    
    var leftGesture     = false
    var rightGesture    = false
	
	private var _delegate : SteamViewControllerDelegate?
	var delegate : SteamViewControllerDelegate? {
		
		get {
			return _delegate
		}
		
		set{
			if _delegate == nil {
				_delegate = newValue
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "search-bg.png")!)

        tableView.delegate      = self
        tableView.dataSource    = self
        tableView.maskView      = nil
        self.automaticallyAdjustsScrollViewInsets = false
        
        focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft(_:)))
        swipeLeft.direction = .Left
        self.tableView.addGestureRecognizer(swipeLeft)
        
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight(_:)))
        swipeRight.direction = .Right
        self.tableView.addGestureRecognizer(swipeRight)
        
        self.serviceGetSources()
    }
    
    //MARK:- Tableview Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataPlayBack.count
    }
	
	let filterArr = FilterPreference.get()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("StreamTableViewCell", forIndexPath: indexPath) as! StreamTableViewCell
		let cellData	= dataPlayBack[indexPath.row]
		let title		= cellData.display_name
		
		if cellData.selectedRow {
			dataPlayBack[indexPath.row].selectedRow = true
			cell.accessoryType = .Checkmark

			tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
			
			
		} else {
			dataPlayBack[indexPath.row].selectedRow = false
			cell.accessoryType = .None
			tableView.deselectRowAtIndexPath(indexPath, animated: false)
		}
		
		cell.configureCell(title!)
        return cell
    }
    
    //MARK:- Tableview Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        dataPlayBack[indexPath.row].selectedRow = true
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor(red: 96/255, green: 121/255, blue: 146/255, alpha: 1.0)
        cell?.accessoryType = .Checkmark
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        dataPlayBack[indexPath.row].selectedRow = false
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor(red: 141/255, green: 172/255, blue: 204/255, alpha: 1)
        cell?.accessoryType = .None
        
    }    
    
    //MARK:- API Service
    
    func serviceGetSources(){
        let sourcesURL = "http://demoz.online/tvios/public/api/get_sources"
        
        Alamofire.request(.GET,sourcesURL).responseObject {
            (response: Response<PlaybackSourceModel, NSError>) in
            let apiResponce = response.result.value
            
            if ( apiResponce?.results?.count > 0 ){
                self.dataPlayBack = (apiResponce?.results)!
				
				
				print(self.filterArr)
				
				if self.filterArr != nil{
				if self.filterArr!.count > 0 {
					for item in self.dataPlayBack{
						
						print(item.source)
						
						
						let flag = self.filterArr!.filter { $0["source"] == item.source }
						if flag.count > 0 { item.selectedRow = true }
						
					}
					}
				}
				
                self.tableView.reloadData()
                
                self.leftGesture = false
                self.rightGesture = false
            
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
    }
    
    
    //MARK:- Handler
    
    @IBAction func actionSelect(){
        
        if dataPlayBack.count == 0 {
            return
        }
        
        var sourceArr = [Dictionary<String,String>]()
        for item in dataPlayBack {

			if item.selectedRow && item.source != nil {
				sourceArr.append(["source" : item.source! ])
			}

        }
		
		print(sourceArr)
		
        //if sourceArr.count == 0 { return }
        
        print(sourceArr.count)
		_delegate?.streamViewControllerDelegate(didSelectStream: sourceArr)
		self.navigationController?.popViewControllerAnimated(true)

		/*return
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let filterScreen = storyboard.instantiateViewControllerWithIdentifier("HomeCollectionViewContainerVC") as? HomeCollectionViewContainerVC else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        
        filterScreen.isFilter       = true
        filterScreen.filterServicesArr  = sourceArr
        let filterNavVC = UINavigationController(rootViewController: filterScreen)
        self.navigationController!.presentViewController(filterNavVC, animated: true, completion: nil)*/
    
    }
    
    @IBAction func actionDeselect(){
        
        if dataPlayBack.count == 0 {
            return
        }
        
        for item in dataPlayBack {
            if item.selectedRow {
                item.selectedRow = false
            }
        }
        
        self.tableView.reloadData()
        
    }
    
    //MARK:- Gesture Handler
    
    func swipedUP(sender:UISwipeGestureRecognizer) {
        leftGesture = false
        rightGesture = false
        //
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    func swipedLeft(sender:UISwipeGestureRecognizer) {
        leftGesture = true
        //
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    func swipedRight(sender:UISwipeGestureRecognizer) {
        rightGesture = true
        //
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }

}
