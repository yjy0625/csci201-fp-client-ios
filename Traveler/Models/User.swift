//
//  User.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/16/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ObjectMapper

class User: NSObject, Mappable {
    
    public private(set) var id: String!
    public private(set) var email: String!
    public var name: String!
    public var password: String!
    public private(set) var score: Int!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.id         <- map["id"]
        self.email      <- map["email"]
        self.name       <- map["name"]
        self.password   <- map["password"]
        self.score      <- map["score"]
    }
    
    public func incScore(inc: Int) {
        score = score + inc
    }
    
}
