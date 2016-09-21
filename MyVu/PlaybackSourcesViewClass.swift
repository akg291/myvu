//
//  PlaybackSourcesViewClass.swift
//  HelloWorld
//
//  Created by MacPro on 25/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire

class PlaybackSourcesViewClass : UIView,UICollectionViewDelegate,UICollectionViewDataSource{
    //MARK: - Variables
    var parentVC = UIViewController()
    private var playBackSources = [Source]()
    private static let minimumEdgePadding = CGFloat(90.0)
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bgView: UIImageView!
    
    //MARK: - Initializer
    class func instanceFromNib() -> UIView             {
        return UINib(nibName: "PlaybackSourcesView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    func setupCollectionView (playBackSources:[Source]){
        self.playBackSources = playBackSources
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let nibName = UINib(nibName: PlaybackSourceCell.reuseIdentifier, bundle:nil)
        self.collectionView.registerNib(nibName, forCellWithReuseIdentifier: PlaybackSourceCell.reuseIdentifier)
    }
    
    //MARK: - Actions
    @IBAction func didTapSource(sender: NSIndexPath)   {
        print(sender.row)
        
    }
    
    // MARK: - UICollectionViewDelegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int                                               {
        // Our collection view displays 1 section per group of items.
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int                            {
        // Each section contains a single `CollectionViewContainerCell`.
        return playBackSources.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(PlaybackSourceCell.reuseIdentifier, forIndexPath: indexPath)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)                       {
        print(playBackSources[indexPath.row].link)
        var canOpen = false
        if let url = NSURL(string: playBackSources[indexPath.row].link!) {
            canOpen = UIApplication.sharedApplication().canOpenURL(url)
        }
        if (canOpen){
            UIApplication.sharedApplication().openURL(NSURL(string: playBackSources[indexPath.row].link!)!)
        }else {
            
        }
    }
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? PlaybackSourceCell else { fatalError("Expected to display a DataItemCollectionViewCell") }
        let item = playBackSources[indexPath.row]
        // Configure the cell.
        item.display()
        cell.title.setTitle(item.display_name, forState: UIControlState.Normal)
        cell.title.addTarget(self, action: #selector(PlaybackSourcesViewClass.collectionView(_:didSelectItemAtIndexPath:)), forControlEvents: .PrimaryActionTriggered)
    }
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool                {
        /*
         Return `false` because we don't want this `collectionView`'s cells to
         become focused. Instead the `UICollectionView` contained in the cell
         should become focused.
         */
        return false
    }
    
    //MARK: - Others
    func swipedUP(sender:UISwipeGestureRecognizer){
        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
    }
    
    
}