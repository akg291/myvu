//
//  ItemModel.swift
//  MyVu
//
//  Created by MacPro on 26/09/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper


class itemPaginationModel: Mappable {
    
    //MARK: - Properties
    var status          :   Bool?
    var items           :   ItemDataModel?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map){
        status      <-  map["status"]
        items     <-    map["data.items"]
		
		print(map.JSONDictionary)
		
    }
    
}


class ItemDataModel: Mappable {
    
    //MARK: - Properties
    var status          :   Bool?
    var results         :   [ItemModel]?
    var total           :   String?
    var next_page_url   :   String?
	var per_page        :   Int?
	var current         :   Int?
	var last_page       :   Int?
	
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map){
        status              <-  map["status"]
        results             <-  map["data"]
        total               <-  map["total"]
        current             <-  map["current"]
        per_page            <-  map["per_page"]
        last_page           <-  map["last_page"]
        next_page_url       <-  map["next_page_url"]
    }
}

class ItemModel: Mappable {
    
    //MARK: - Properties
    var id          :   Int?
    var list_id     :   String?
    var item_id     :   Int?
    var name        :   String?
    var image       :   String?
    var status      :   String?
    var type        :   String?
    var sources     :   [SourceModel]?
    
    //MARK: - Init
    required init?(_ map: Map){ 
    }
    
    //MARK: - Mapper
    func mapping(map: Map){
        
        
        id          <- map["id"]
        list_id     <- map["list_id"]
        item_id     <- map["item_id"]
        name        <- map["name"]
        image       <- map["image"]
        status      <- map["status"]
        sources     <- map["sources"]
        type        <- map["type"]

    }
    
    func display(){
        
        print("sources \(sources)")
        print("id \(id)")
        print("list_id \(list_id)")
        print("item_id \(item_id)")
        print("name \(name)")
        print("image \(image)")
        print("status \(status)")
        
        
    }
}









