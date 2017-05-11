/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A `UICollectionViewCell` subclass used to display `DataItem`s within `UICollectionView`s.
 */

import UIKit

class DataItemCollectionViewCell_: UICollectionViewCell {
    // MARK: - Variables
    static let reuseIdentifier = "DataItemCell_"
    static let reuseIdentifier1 = "DataItemCell1"
    
    //MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelfilterServices : UILabel!
    
    private var _data: ItemModel!
    var isFilter:Bool = false
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        // These properties are also exposed in Interface Builder.
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
		label.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
    }
    
    // MARK: - UICollectionReusableView
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the label's alpha value so it's initially hidden.
		label.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        imageView.image = nil
    }
    
    // MARK: - UIFocusEnvironment
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        /*
         Update the label's alpha value using the `UIFocusAnimationCoordinator`.
         This will ensure all animations run alongside each other when the focus
         changes.
         */
        
        
        coordinator.addCoordinatedAnimations({
            
            if self.focused {
                if (self.isFilter) {
                    self.labelfilterServices.alpha = 1.0
                } else {

					
					UIView.transitionWithView(self.label, duration: 0.25, options: .TransitionCrossDissolve, animations: {
						self.label.textColor = UIColor.whiteColor()
						}, completion: nil)
                }
            }
            else {
                if (self.isFilter) {
                    self.labelfilterServices.alpha = 0.0
                } else {

					self.label.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
                }
            }
        }, completion: nil)
		
    }
    
    // MARK: - Configure Cell
    func configureCell( data:ItemModel ){
        _data = data
        //
        
        if (self.isFilter) {
            
            if _data.sources?.count > 0 {
                labelfilterServices.text          = _data.sources![0].display_name
            } else {
                labelfilterServices.text          = ""
            }
            
            labelfilterServices.hidden      = false
            label.hidden                    = true
            
        } else {
            
            label.text                      = _data.name
            label.hidden                    = false
            labelfilterServices.hidden      = true
            
        }
        
        self.imageView.sd_setImageWithURL( NSURL(string:_data.image!), placeholderImage: UIImage(named: "movie-placeholder"))
		
		
		
		
		
    }
    
}
