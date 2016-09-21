//
//  SeasonEpisodeViewCell.swift
//  MyVu
//
//  Created by MacPro on 31/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

class SeasonEpisodeViewCell: UICollectionViewCell {
    // MARK: - Variables
    static let reuseIdentifier = "SeasonEpisodeViewCell"
    
    //MARK: - Outlets
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var episodeDate: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Initialization
    override func awakeFromNib()    {
        super.awakeFromNib()
        // These properties are also exposed in Interface Builder.
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
        episodeName.alpha = 0.0
        episodeDate.alpha = 0.0
    }
    
    // MARK: - UICollectionReusableView
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the label's alpha value so it's initially hidden.
        episodeName.alpha = 0.0
        episodeDate.alpha = 0.0
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
                self.episodeName.alpha = 1.0
                self.episodeDate.alpha = 1.0
            }
            else {
                self.episodeName.alpha = 0.0
                self.episodeDate.alpha = 0.0
            }
            }, completion: nil)
    }
}

