//
//  MarkerAnnotation.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/17/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Mapbox

class MarkerAnnotation: NSObject, MGLAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var data: Place
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, data: Place, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.data = data
        self.title = title
        self.subtitle = subtitle
    }

}
