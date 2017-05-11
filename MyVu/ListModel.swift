//
//  ListModel.swift
//  MyVu
//
//  Created by MacPro on 26/09/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper


class ListDataModel: Mappable {
    
    //MARK: - Properties
    var results:[ListModel]?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map) {
        results <- map["data"]
    }
}

class ListModel: Mappable {
    
    //MARK: - Properties

    var id          : String?
    var name        : String?
    var category    : String?
    //var items       : ItemDataModel?
    var items       : [ItemModel]?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map) {
    
        id          <-  map["id"]
        name        <-  map["name"]
        category    <-  map["category"]
        //items		<-  map["items"]
        items       <-  map["items"]
        
    }
    
    func display(){
        print(id)
        print(name)
        print(category)
        print(items)
    }
    
}

