//
//  SeasonEpisodeViewCell.swift
//  MyVu
//
//  Created by MacPro on 31/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import SDWebImage

class SeasonEpisodeViewCell: UICollectionViewCell {
    // MARK: - Variables
    static let reuseIdentifier = "SeasonEpisodeViewCell"
    
    //MARK: - Outlets
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var episodeDate: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var _data:ItemModel!
    private var isFitler:Bool = false
    
    
    // MARK: - Initialization
    override func awakeFromNib()    {
        super.awakeFromNib()
        // These properties are also exposed in Interface Builder.
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
		imageView.image = nil
    }
    
    // MARK: - UICollectionReusableView
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the label's alpha value so it's initially hidden.
        imageView.image = nil
		self.episodeName.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
		
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
				
				UIView.transitionWithView(self.episodeName, duration: 0.25, options: .TransitionCrossDissolve, animations: {
					self.episodeName.textColor = UIColor.whiteColor()
				}, completion: nil)
				
				UIView.transitionWithView(self.episodeDate, duration: 0.25, options: .TransitionCrossDissolve, animations: {
					self.episodeName.textColor = UIColor.whiteColor()
					}, completion: nil)
            }
            else {
				self.episodeName.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
				self.episodeDate.textColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
            }
            }, completion: nil)
    }
    
    
    // MARK: - Configure Cell
    func configureCell( data:ItemModel ){
        _data = data
        //
        self.episodeName.text = _data.name
        self.episodeDate.text = String(_data.display())
        self.imageView.sd_setImageWithURL(NSURL(string:_data.image!),placeholderImage: UIImage(named: "tv-series-placeholder"))
		//
	
    }
    
    
}

