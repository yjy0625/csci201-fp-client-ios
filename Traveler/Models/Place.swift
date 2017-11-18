//
//  Place.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/16/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ObjectMapper

class Place: NSObject, Mappable {

    public private(set) var id: String!
    public private(set) var name: String!
    public private(set) var lat: Double!
    public private(set) var lon: Double!
    public private(set) var points: Int!
    public var avatarUrl: String!
    public private(set) var numVisits: Int!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.id         <- map["id"]
        self.name       <- map["name"]
        self.lat        <- map["lat"]
        self.lon        <- map["lon"]
        self.points     <- map["points"]
        self.avatarUrl  <- map["avatar_url"]
        self.numVisits  <- map["num_visits"]
    }
    
    public func incNumOfVisit() {
        numVisits = numVisits + 1
    }
    
}
