//
//  EpisodeModel.swift
//  HelloWorld
//
//  Created by MacPro on 26/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class SeasonModel: Mappable {
    
    //MARK: - Properties
    var results:[EpisodeModel]?
    var total_results : Int?
    var error: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        results <- map["results"]
        total_results <- map["total_results"]
        error <- map["error"]
    }
}

class EpisodeModel: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var content_type: String?
    var episode_number: Int?
    var first_aired: String?
    var title: String?
    var poster: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["id"]
        content_type <- map["content_type"]
        episode_number <- map["episode_number"]
        first_aired <- map["first_aired"]
        title <- map["title"]
        poster <- map["thumbnail_400x225"]
    }
}










