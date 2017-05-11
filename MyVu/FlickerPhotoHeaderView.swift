//
//  FlickerPhotoHeaderView.swift
//  UIKitCatalog
//
//  Created by MacPro on 10/08/2016.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation
import UIKit

class FlickerPhotoHeaderView: UICollectionReusableView {
  
    //MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var sortBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
        let headerFocusGuide = UIFocusGuide()
        headerFocusGuide.preferredFocusedView = searchBtn
        self.addLayoutGuide(headerFocusGuide)
		
        let contraints:[NSLayoutConstraint] = [
            headerFocusGuide.topAnchor.constraintEqualToAnchor(self.topAnchor),
            headerFocusGuide.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor),
            headerFocusGuide.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor),
            headerFocusGuide.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor)
        ]
		
        self.addConstraints(contraints)
		self.label.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
    
    }
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        return true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        context.nextFocusedView?.setNeedsFocusUpdate()
    }
    
    override var preferredFocusedView: UIView? {
        return searchBtn
    }
    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    
}
