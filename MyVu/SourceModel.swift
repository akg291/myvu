//
//  SourceModel.swift
//  MyVu
//
//  Created by MacPro on 29/09/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class SourceModel: Mappable {
    
    //MARK: - Properties
    
    var type                :   String?
    var app_link            :   String?
    var app_download_link   :   String?
    var app_name            :   String?
    var app_required        :   String?
    var display_name        :   String?
    var link                :   String?
    var categoryId          :   Int?
    var status              :   String?
    
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map){
        
        type                <- map["type"]
        app_link            <- map["app_link"]
        app_download_link   <- map["app_download_link"]
        app_name            <- map["app_name"]
        app_required        <- map["app_required"]
        categoryId          <- map["category_id"]
        display_name        <- map["display_name"]
        link                <- map["link"]
        status              <- map["status"]
        
        
    }
    
    func display(){
    
        print("type \(type)")
        print("app_link  \(app_link)")
        print("app_download_link  \(app_download_link)")
        print("app_name  \(app_name)")
        print("app_required  \(app_required)")
        print("display_name  \(display_name)")
        print("link \(link)")
        print("status \(status)")
        print("category \(categoryId)")
        
    }
    
}