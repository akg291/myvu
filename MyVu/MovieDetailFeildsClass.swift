//
//  MovieDetailFeildsClass.swift
//  HelloWorld
//
//  Created by MacPro on 24/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

class MovieDetailFeildsClass: UIView {
    
    //MARK: - Outlets
    @IBOutlet weak var genreAndRatingLbl: UILabel!
    @IBOutlet weak var movieTitleLbl: UILabel!
    @IBOutlet weak var directorAndStarringLbl: UILabel!
    @IBOutlet weak var movieDescriptionLbl: UILabel!
    @IBOutlet weak var movieEndingTimeLbl: UILabel!
    @IBOutlet weak var movieRunTimeLbl: UILabel!
    @IBOutlet weak var imdbRatingsLbl: UILabel!
    @IBOutlet weak var background : UIImageView!
    @IBOutlet weak var moviePoster : UIImageView!
    
    //MARK: - Class
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MovieDetailFeilds", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
}