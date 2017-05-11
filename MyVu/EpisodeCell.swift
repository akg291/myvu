//
//  EpisodeCell.swift
//  MyVu
//
//  Created by MacPro on 02/01/2017.
//  Copyright © 2017 Aplos Inovations. All rights reserved.
//

import UIKit

class EpisodeCell: UICollectionViewCell {
	
	static let cellIdentifier = "EpisodeCell"
	
	@IBOutlet weak var imgView : UIImageView!
	@IBOutlet weak var labelTitle : UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		imgView.adjustsImageWhenAncestorFocused = true
		imgView.clipsToBounds = false
		labelTitle.alpha = 0.0
	}
    
}
