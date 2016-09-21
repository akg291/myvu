//
//  MoviesSearchResultModel.swift
//  ShopPinList
//
//  Created by MacPro on 17/06/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class MoviesSearchResultModel: Mappable {
    
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

class Result: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var title: String?
    var previewImage: String?
    var artWork: String?
    var group: String?
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["id"]
        title <- map["title"]
        previewImage <- map["poster_240x342"]
        artWork <- map["artwork_448x252"]
    }
}