//
//  ShowDetailFeilds.swift
//  HelloWorld
//
//  Created by MacPro on 26/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

class ShowDetailFeilds: UIView {
   
    //MARK: - Outlets
    @IBOutlet weak var genreAndRatingLbl: UILabel!
    @IBOutlet weak var showTitleLbl: UILabel!
    @IBOutlet weak var genreAndNumberofSeasonsLbl: UILabel!
    @IBOutlet weak var showDescriptionLbl: UILabel!
    @IBOutlet weak var imdbRatingsLbl: UILabel!
    @IBOutlet weak var showPoster : UIImageView!
    @IBOutlet weak var background : UIImageView!
	
	@IBOutlet weak var labelRuntime : UILabel!
    
    //MARK: - Class
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ShowDetailFeildsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
}
