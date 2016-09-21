//
//  AllSeasonsModel.swift
//  HelloWorld
//
//  Created by MacPro on 26/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class AllSeasonsModel: Mappable {
    
    //MARK: - Properties
    var results:[SeasonInfoModel]?
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

class SeasonInfoModel : Mappable {
    
    //MARK: - Properties
    var season_number: Int?
    var first_airdate: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        season_number <- map["id"]
        first_airdate <- map["content_type"]
    }
}
