//
//  HomeScreenViewController.swift
//  HelloWorld
//
//  Created by MacPro on 12/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import UIKit

class HomeScreenViewController: UIViewController {
    
    //MARK: - Properties
    private var items = [Result]()
    private let cellComposer = DataItemCellComposer()
    var delay = 2.0 * Double(NSEC_PER_SEC)
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var options: UISegmentedControl!
   
    //MARK: - Actions
    @IBAction func segmentSwitch (sender: UISegmentedControl) {
        delay = 2.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            
            let selectedSegment =  sender.selectedSegmentIndex
            
            if (selectedSegment == 0) {
                self.optionsButton.titleLabel?.text = "First"
            }else if (selectedSegment == 1){
                self.optionsButton.titleLabel?.text = "Second"
            }
            else{
                self.optionsButton.titleLabel?.text = "Third"
            }
        }
    }
    @IBAction func toggelOptionsView (sender: AnyObject)      {
        if ( self.view.viewWithTag(1)!.hidden ){
            self.view.viewWithTag(1)?.hidden = false
        }else {
            self.view.viewWithTag(1)?.hidden = true
        }
    }
    
    
    // MARK: UIViewController
    override func viewDidLoad()           {
        super.viewDidLoad()
        guard let collectionView = collectionView else { return }
        /*
         Add a gradient mask to the collection view. This will fade out the
         contents of the collection view as it scrolls beneath the transparent
         navigation bar.
         */
        collectionView.maskView = GradientMaskView(frame: CGRect(origin: CGPoint.zero, size: collectionView.bounds.size))
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let collectionView = collectionView,
            let maskView = collectionView.maskView as? GradientMaskView,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            else {
                return
        }
        
        /*
         Update the mask view to have fully faded out any collection view
         content above the navigation bar's label.
         */
        maskView.maskPosition.end = topLayoutGuide.length * 0.8
        /*
         Update the position from where the collection view's content should
         start to fade out. The size of the fade increases as the collection
         view scrolls to a maximum of half the navigation bar's height.
         */
        let maximumMaskStart = maskView.maskPosition.end + (topLayoutGuide.length * 0.5)
        let verticalScrollPosition = max(0, collectionView.contentOffset.y + collectionView.contentInset.top)
        maskView.maskPosition.start = min(maximumMaskStart, maskView.maskPosition.end + verticalScrollPosition)
        /*
         Position the mask view so that it is always fills the visible area of
         the collection view.
         */
        var rect = CGRect(origin: CGPoint(x: 0, y: collectionView.contentOffset.y), size: collectionView.bounds.size)
        
        /*
         Increase the width of the mask view so that it doesn't clip focus
         shadows along its edge. Here we are basing the amount to increase the
         frame by on the spacing defined in the collection view's layout.
         */
        rect = CGRectInset(rect, -layout.minimumInteritemSpacing, 0)
        maskView.frame = rect
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int                    {
        // The collection view shows all items in a single section.
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        return collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? DataItemCollectionViewCell else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
        let item = items[indexPath.row]
        // Configure the cell.
        cellComposer.composeCell(cell, withDataItem: item)
    }
}
