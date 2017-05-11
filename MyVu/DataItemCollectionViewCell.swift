/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A `UICollectionViewCell` subclass used to display `DataItem`s within `UICollectionView`s.
*/

import UIKit

class DataItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    static let reuseIdentifier = "DataItemCell"
    static let reuseIdentifier1 = "DataItemCell1"
    var representedDataItem: Result?
    
    //MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelServices:UILabel!
    
    private var _data:ItemModel!
    var isFitler:Bool = false
    
    // MARK: Initialization
    override func awakeFromNib()    {
        super.awakeFromNib()
        // These properties are also exposed in Interface Builder.
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
        //label.alpha = 0.0
		//self.label.alpha = 0.0
		if labelServices != nil {
			labelServices.alpha = 0.0
			labelServices.hidden = true
		}
		
    }
	
    // MARK: UICollectionReusableView
    override func prepareForReuse() {
        super.prepareForReuse()
        //Reset the label's alpha value so it's initially hidden.
        imageView.image = nil
        //label.alpha = 0.0
		if labelServices != nil {
			labelServices.alpha = 0.0
			labelServices.hidden = true
		}
		
		self.label.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
		
    }
    
    // MARK: UIFocusEnvironment
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        /*
            Update the label's alpha value using the `UIFocusAnimationCoordinator`.
            This will ensure all animations run alongside each other when the focus
            changes.
        */
		
        coordinator.addCoordinatedAnimations({
            if self.focused {
				
				self.label.alpha = 1.0
				UIView.transitionWithView(self.label, duration: 0.25, options: .TransitionCrossDissolve, animations: {
					self.label.textColor = UIColor.whiteColor()
				}, completion: nil)
				
            } else {
				self.label.alpha = 1.0
				self.label.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
            }
        }, completion: nil)
    }
    
    // MARK: - Configure Cell
    func configureCell( data:ItemModel ){
        
        _data = data

        self.label.text = data.name
        self.imageView.sd_setImageWithURL( NSURL(string:_data.image!), placeholderImage: UIImage(named: "movie-placeholder"))
    }
    
    
}
