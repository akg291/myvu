//
//  PlaybackSourceModel.swift
//  HelloWorld
//
//  Created by MacPro on 22/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class PlaybackSourceModel: Mappable {
    
    //MARK: - Properties
    var results:[PlaybackSource]?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
     func mapping(map: Map)   {
        results <- map["data"]
    }
}

class PlaybackSource: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var source: String?
    var display_name: String?
    var type: String?
    var info: String?
    var ios_app: String?
    var android_app: String?
    var selectedRow : Bool = false
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["id"]
        source <- map["source"]
        display_name <- map["display_name"]
        type <- map["type"]
        info <- map["info"]
        ios_app <- map["ios_app"]
        android_app <- map["android_app"]
    }
}
