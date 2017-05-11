//
//  MovieDetailsModel.swift
//  HelloWorld
//
//  Created by MacPro on 18/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import ObjectMapper

class MovieDataModel: Mappable {
    
    var status      :       String?
    var data        :       MovieDetailsModel?
    
    //MARK: - Properties
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        status  <- map["status"]
        data    <- map["data"]
    }
}

class MovieDetailsModel: Mappable {

    //MARK: - Properties
    var id: Int?
    var title: String?
    var poster: String?
    var rating: String?
	var mpaa	: String?
    var release_date: String?
    var group: String?
    var overview: String?
    var genres:[Genre]?
    var directors:[Director]?
    var cast:[Character]?
    var duration: String?
    var imdb: String?
    var sources : [SourceModel]?
	var related : MoviesSearchResultModel?
    var error: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["movie_id"]
        title <- map["title"]
        poster <- map["poster_240x342"]
        rating <- map["rating"]
		mpaa	<- map["mpaa"]
        release_date <- map["release_date"]
        genres <- map["genres"]
        overview <- map["overview"]
        directors <- map["directors"]
        cast <- map["cast"]
        duration <- map["duration"]
        imdb <- map["imdb"]
        sources <- map["sources"]
		related <- map["related"]
		error <- map["error"]		
    }
}

class Genre: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var title: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["id"]
        title <- map["title"]
    }
}

class Director: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var name: String?
    var imdb: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["id"]
        name <- map["name"]
        imdb <- map["imdb"]
    }
}

class Character: Mappable {
    
    //MARK: - Properties
    var id: Int?
    var name: String?
    var character_name: String?
    var imdb: String?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        id <- map["id"]
        name <- map["name"]
        character_name <- map["character_name"]
        imdb <- map["imdb"]
    }
}

class Source: Mappable {
    
    //MARK: - Properties
    var source: String?
    var display_name: String?
    var link: String?
    var app_name: String?
    var app_required: Int?
    
    //MARK: - Init
    required init?(_ map: Map){
    }
    
    //MARK: - Mapper
    func mapping(map: Map)    {
        source <- map["source"]
        display_name <- map["display_name"]
        link <- map["link"]
        app_name <- map["app_name"]
        app_required <- map["app_required"]
    }
    
    func display() {
        print("Source \(self.source)")
        print("display_name \(self.display_name)")
        print("link \(self.link)")
        print("app_name \(self.app_name)")
        print("app_required \(self.app_required)")
    }
}





