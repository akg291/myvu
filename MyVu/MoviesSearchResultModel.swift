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



class SearchModel: Mappable {
    
    //MARK: - Properties
    var movies              : SearchDataModel?
    var episodes            : SearchDataModel?
    var shows               : SearchDataModel?
    var status              : Bool?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        movies          <- map["data.movies"]
        episodes        <- map["data.episodes"]
        shows           <- map["data.shows"]
        status          <- map["status"]
    }
    
}

class SearchDataModel: Mappable {
    
    var total       : Int?
    var perPage     : Int?
    var currentPage : Int?
    var lastPage    : Int?
    var nextPageUrl : String?
    var prevPageUrl : String?
    var type        : String?
    var query       : String?
    
    var data        : [ItemModel]?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        total       <- map["total"]
        perPage     <- map["per_page"]
        currentPage <- map["current_page"]
        lastPage    <- map["last_page"]
        nextPageUrl <- map["next_page_url"]
        prevPageUrl <- map["prev_page_url"]
        data        <- map["results"]
		type		<- map["type"]
    }
    
}
