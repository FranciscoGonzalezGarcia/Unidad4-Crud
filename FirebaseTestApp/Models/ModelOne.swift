//
//  ModelOne.swift
//  FirebaseTestApp
//
//  Created by developer on 5/9/19.
//  Copyright © 2019 napify. All rights reserved.
//

import Foundation
import ObjectMapper

class ModelOne: NSObject, Mappable {
    
    var clasification = String()
    var name = String()
    var uses = String()
    var id = String()
    
    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        clasification <- map["Clasification"]
        name <- map["Name"]
        uses <- map["Uses"]
        id <- map["id"]
    }
}
