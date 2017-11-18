//
//  Post.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/16/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ObjectMapper

class Post: NSObject, Mappable {
    
    public private(set) var id: String!
    public private(set) var timestamp: Int!
    public private(set) var userId: String!
    public private(set) var userName: String!
    public private(set) var placeId: String!
    public private(set) var placeName: String!
    public private(set) var postContent: String!
    public private(set) var numImages: Int!
    public private(set) var isPublic: Bool!
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.id             <- map["id"]
        self.timestamp      <- map["timestamp"]
        self.userId         <- map["userId"]
        self.userName       <- map["userName"]
        self.placeId        <- map["placeId"]
        self.placeName      <- map["placeName"]
        self.postContent    <- map["postContent"]
        self.numImages      <- map["numImages"]
        self.isPublic       <- map["isPublic"]
    }
    
}
