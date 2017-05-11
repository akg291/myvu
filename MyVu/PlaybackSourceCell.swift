//
//  PlaybackSourceCell.swift
//  HelloWorld
//
//  Created by MacPro on 25/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

protocol ChildCellDelegate {
    func ChildCellDelegate( didClick indexPath:NSIndexPath )
}

class PlaybackSourceCell: UICollectionViewCell {
    
    // MARK: Variables
    static let reuseIdentifier = "PlaybackSourceCell"
    private var indexPath:NSIndexPath!
    private var data:AnyObject!
    
    private var _delegate:ChildCellDelegate?
    var delegate:ChildCellDelegate{
        
        get{
            return _delegate!
        }
        
        set{
            if _delegate == nil {
                _delegate = newValue
            }
        }
    }
    
    var representedDataItem: Result?
    
    //MARK: - Outlets
    @IBOutlet weak var title: UIButton!
	@IBOutlet weak var imgView : UIImageView!
    
    // MARK: - Initialization
	override func awakeFromNib() {
		super.awakeFromNib()
		
		imgView.adjustsImageWhenAncestorFocused = true
		imgView.clipsToBounds = false
		title.layer.cornerRadius = 6
		title.clipsToBounds = true
		
		self.title.titleLabel?.textColor = UIColor.whiteColor()
		self.title.backgroundColor = UIColor(red: 71/255, green: 71/255, blue: 71/255, alpha: 1)
		self.title.setTitleColor(UIColor(red: 71/255, green: 71/255, blue: 71/255, alpha: 1), forState: .Focused )
		
		title.titleLabel?.numberOfLines = 0
		title.titleLabel?.textAlignment = .Center
	}
	
	
    // MARK: - UICollectionReusableView
    override func prepareForReuse() {
        super.prepareForReuse()
    }
	
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        return true
    }
	
	
	// MARK: - UIFocusEnvironment
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

		coordinator.addCoordinatedAnimations({
			if self.title.focused {
				self.title.backgroundColor = UIColor.whiteColor()
			}
			else {
				self.title.backgroundColor = UIColor(red: 71/255, green: 71/255, blue: 71/255, alpha: 1)
				self.title.titleLabel?.textColor = UIColor.whiteColor()
			}
		}, completion: nil)
		
	}

    func configureCell( indexPath:NSIndexPath ){
        self.indexPath  = indexPath
    }
	
    @IBAction func ActionTitleButton(){
        _delegate?.ChildCellDelegate(didClick: indexPath)
    }
	
}
