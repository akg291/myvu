//
//  ShowDetailsModel.swift
//  HelloWorld
//
//  Created by MacPro on 26/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class ShowDataModel: Mappable {
    
    //MARK: - Properties
    var status  : Bool?
    var data    : ShowDetailsModel?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        
        
        
        status  <- map["status"]
        data    <- map["data"]

    }
}


class ShowDetailsModel: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var title: String?
    var artwork: String?
    var rating: String?
	var mpaa: String?
    var first_aired: String?
    var group: String?
    var overview: String?
    var genres:[Genre]?
    var directors:[Director]?
    var cast:[Character]?
    var duration: String?
    var imdb_id: String?
	var showName : String?
    var error: String?
    var sources : [SourceModel]?
    var seasons : [SeasonModel]?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
	
        id <- map["movie_id"]
        title <- map["title"]
		showName <- map["show_name"]
        artwork <- map["poster_400x570"]
        rating <- map["rating"]
		mpaa <- map["mpaa"]
        first_aired <- map["first_aired"]
        genres <- map["genres"]
        overview <- map["overview"]
        directors <- map["director"]
        cast <- map["cast"]
        duration <- map["duration"]
        imdb_id <- map["imdb"]
        error <- map["error"]
        sources <- map["sources"]
        seasons <- map["seasons"]
    }
}
