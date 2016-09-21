//
//  ShowDetailsModel.swift
//  HelloWorld
//
//  Created by MacPro on 26/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class ShowDetailsModel: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var title: String?
    var artwork: String?
    var rating: String?
    var first_aired: String?
    var group: String?
    var overview: String?
    var genres:[Genre]?
    var directors:[Director]?
    var cast:[Character]?
    var duration: Int?
    var imdb_id: String?
    var error: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["id"]
        title <- map["title"]
        artwork <- map["artwork_448x252"]
        rating <- map["rating"]
        first_aired <- map["first_aired"]
        genres <- map["genres"]
        overview <- map["overview"]
        directors <- map["directors"]
        cast <- map["cast"]
        duration <- map["duration"]
        imdb_id <- map["imdb_id"]
        error <- map["error"]
    }
}
