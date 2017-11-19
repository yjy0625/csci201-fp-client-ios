//
//  Place.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/16/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

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
        self.avatarUrl  <- map["avatarUrl"]
        self.numVisits  <- map["numVisits"]
    }
    
    public func setNumOfVisits(_ num: Int) {
        numVisits = num
    }
    
    public func getLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: lat, longitude: lon)
    }
    
}
