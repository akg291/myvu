//
//  PlaybackSourcesViewClass.swift
//  HelloWorld
//
//  Created by MacPro on 25/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire

class PlaybackSourcesViewClass : UIView, UICollectionViewDelegate , UICollectionViewDataSource, ChildCellDelegate {
	
	//MARK: - Outlets
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var labelNoSource: UILabel!
	@IBOutlet weak var bgView: UIImageView!
	
	
	@IBOutlet weak var btn : UIButton!
	
	//MARK: - Variables
    var parentVC = UIViewController()
    private var playBackSources = [SourceModel]()
    private static let minimumEdgePadding = CGFloat(90.0)
    var title = ""
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		// These properties are also exposed in Interface Builder.
		bgView.adjustsImageWhenAncestorFocused = true
		bgView.clipsToBounds = false
		
		/*		
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 20
		layout.scrollDirection = .Vertical
		layout.itemSize = CGSize(width: 252, height: 116)
		self.collectionView.collectionViewLayout = layout
		*/
	}
	
    //MARK: - Initializer
    class func instanceFromNib() -> UIView             {
        return UINib(nibName: "PlaybackSourcesView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    func setupCollectionView (playBackSources:[SourceModel]){
	
        self.playBackSources = playBackSources
		if self.playBackSources.count == 0 {
			
			labelNoSource.text = "No Sources Found"
			labelNoSource.hidden = false
			
			let headerFocusGuide = UIFocusGuide()
			headerFocusGuide.enabled = true
			headerFocusGuide.preferredFocusedView = labelNoSource
			self.addLayoutGuide(headerFocusGuide)
			
			let contraints:[NSLayoutConstraint] = [
				headerFocusGuide.topAnchor.constraintEqualToAnchor(self.topAnchor),
				headerFocusGuide.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor),
				headerFocusGuide.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor),
				headerFocusGuide.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor)
			]

			self.addConstraints(contraints)

		}
		
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
		
        let nibName = UINib(nibName: PlaybackSourceCell.reuseIdentifier, bundle:nil)
        self.collectionView.registerNib(nibName, forCellWithReuseIdentifier: PlaybackSourceCell.reuseIdentifier)
		let noSourceNibName = UINib(nibName: "NosourceCollectionReusableView", bundle:nil)
		self.collectionView.registerNib(noSourceNibName, forCellWithReuseIdentifier: NosourceCollectionReusableView.reuseIdentifier)
		
    }
	
	override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
		return true
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		//context.nextFocusedView?.setNeedsFocusUpdate()
	}
	
	override var preferredFocusedView: UIView? {
		return btn
	}

	
    //MARK: - Actions
    @IBAction func didTapSource(sender: NSIndexPath)   {
        print(sender.row)
        
    }
    
    // MARK: - UICollectionViewDelegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playBackSources.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlaybackSourceCell.reuseIdentifier, forIndexPath: indexPath) as! PlaybackSourceCell
        cell.delegate = self
        cell.configureCell(indexPath)
        return cell
    }
	
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PlaybackSourceCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
        let item = playBackSources[indexPath.row]
        cell.title.setTitle(item.display_name, forState: UIControlState.Normal)
        
    }
	
	func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool                {
        return false
    }
	
	func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		
		let view = UICollectionReusableView()
		//1
		switch kind {
		//2
		case UICollectionElementKindSectionFooter:
			//3
			let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
			                                                                       withReuseIdentifier: NosourceCollectionReusableView.reuseIdentifier ,
			                                                                       forIndexPath: indexPath) as! NosourceCollectionReusableView
			
			
			return headerView
			
		default:
			//4
			assert(false, "Unexpected element kind")
		}
		
		return view
	}
	func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
		if self.playBackSources.count > 0 {
			return NSIndexPath(forItem: 0, inSection: 0)
		}
		return nil
	}

	
	
    //MARK: - Others
    func swipedUP(sender:UISwipeGestureRecognizer){
        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
    }
	
    //MARK: - Child Cell Delegate
    func ChildCellDelegate(didClick indexPath: NSIndexPath) {

        
        let data = playBackSources[indexPath.row]
        var canOpen = false
        
        let urlString   = data.link!.stringByReplacingOccurrencesOfString("itms://", withString: "https://")
        if let url = NSURL(string: urlString) {
            canOpen = UIApplication.sharedApplication().canOpenURL(url)
			UIApplication.sharedApplication().openURL(url)
		}
        print("Category     == \(data.categoryId)")
        print("Url String   == \(urlString)")
		
		//return
		//UIApplication.sharedApplication().openURL(NSURL(string: "com.showtimeanytime://PAGE/t3429324")!)
		//return
		
        if canOpen {
            
            switch data.categoryId!{
                
            case 1:
                UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
                break
                
            case 2:
                
                let msg = "The \(data.app_name!) app doesn’t allow us to take you directly to \"\(self.title)\", but it is available to stream.\nWe can open the \(data.app_name!) app, but you will need to navigate to it yourself."
                
                let alert = UIAlertController(title: nil , message: msg , preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in

                    let scheme = NSURL(string: urlString)
                    let urlScheme = (scheme?.scheme)! + "://"
                    print(scheme?.scheme)
                    print(scheme?.resourceSpecifier)
                    print(urlScheme)
                    
                    if scheme?.scheme != "https" {
                        UIApplication.sharedApplication().openURL(NSURL(string: (urlScheme))!)
                    } else {
                        UIApplication.sharedApplication().openURL(scheme!)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "CANCEL", style: .Default, handler: nil))
                parentVC.presentViewController(alert, animated: true, completion: nil)
                
                break
                
            case 3:
				
                
                let msg = "The \(data.app_name!) app doesn't allow us to take you directly to \"\(self.title)\" but its available to stream. You will need to open the \(data.app_name!) app and navigate it yourself."
                
                let alert = UIAlertController(title: nil , message: msg , preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                    UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
                }))
                
                alert.addAction(UIAlertAction(title: "CANCEL", style: .Default, handler: nil))
                parentVC.presentViewController(alert, animated: true, completion: nil)
                
                break
                
            default:
                print("No link")
            }
        } else {
            self.alertAppNotInstall(self.playBackSources[indexPath.row])
        }
    
        /*-*-*-*/
        return
        
        /*if data.app_link! == "1"{
            var canOpen = false
            
            let urlString = data.link!.stringByReplacingOccurrencesOfString("itms://", withString: "https://")
            
            if let url = NSURL(string: urlString) {
                canOpen = UIApplication.sharedApplication().canOpenURL(url)
            }
            
            //UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/movie/the-great-gatsby-2013/id669947696?ign-mpt=uo%3D4")!)
            //"https://itunes.apple.com/us/movie/x-men-apocalypse/id1111396385?uo=4&at=10laHb"
            /*
             UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/vudu-player-movies-tv/id487285735")!)
             print(UIApplication.sharedApplication().canOpenURL(NSURL(string: "itms-apps://itunes.apple.com/us/app/vudu-movies-tv/id487285735?mt=8")!))
             print(UIApplication.sharedApplication().canOpenURL(NSURL(string: "com.apple.TVAppStore://itunes.apple.com/us/app/vudu-movies-tv/id487285735?mt=8")!))
             UIApplication.sharedApplication().openURL(NSURL(string: "com.apple.TVAppStore://itunes.apple.com/us/app/vudu-movies-tv/id487285735?mt=8")!)
             */
            
            if (canOpen){
                UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
            } else {
                if( data.app_download_link != nil ){
                
                    let msg = "We cannot open the \(playBackSources[indexPath.row].app_name!) app, because you have install it yet. Download app now"
                    
                    let alert = UIAlertController(title: nil , message: msg , preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                    
                        var appDownloadLink = ""
                        appDownloadLink     = data.app_download_link!.stringByReplacingOccurrencesOfString("itms://", withString: "https://")
                        appDownloadLink     = data.app_download_link!.stringByReplacingOccurrencesOfString("itms-apps://", withString: "https://")
                        print(appDownloadLink)
                        
                        UIApplication.sharedApplication().openURL(NSURL(string: appDownloadLink)!)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "CANCEL", style: .Default, handler: nil))
                    parentVC.presentViewController(alert, animated: true, completion: nil)

                }
            }
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Sorry, source isn't available" , preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                switch action.style{
                case .Default:
                    print("default")
                case .Cancel:
                    print("cancel")
                case .Destructive:
                    print("destructive")
                }
            }))
            
            parentVC.presentViewController(alert, animated: true, completion: nil)
        
        }*/
    }
    
    func alertAppNotInstall(playBackSources:SourceModel){
        
        playBackSources.display()
        
        let msg = "Please download the \(playBackSources.app_name!) app to open directly from here. Want to download now?"
        
        let alert = UIAlertController(title: nil , message: msg , preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            var appDownloadLink = ""
            appDownloadLink     = playBackSources.app_download_link!.stringByReplacingOccurrencesOfString("itms://", withString: "https://")
            appDownloadLink     = playBackSources.app_download_link!.stringByReplacingOccurrencesOfString("itms-apps://", withString: "https://")
            
            UIApplication.sharedApplication().openURL(NSURL(string: appDownloadLink)!)
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: .Default, handler: nil))
        parentVC.presentViewController(alert, animated: true, completion: nil)

    }
	
	

    
}
