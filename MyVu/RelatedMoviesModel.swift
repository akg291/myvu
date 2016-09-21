//
//  RelatedMoviesModel.swift
//  HelloWorld
//
//  Created by MacPro on 23/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class RelatedMoviesModel: Mappable {
    
    //MARK: - Properties
    var results:[Result]?
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
