//
//  Globals.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/3/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit

class Globals: NSObject {
    
    public static let ThemeColor = UIColor.init(red: 42/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1.0)
    public static let ThemeColorDisabled = UIColor.init(red: 123/255.0, green: 186/255.0, blue: 255/255.0, alpha: 1.0)
    public static let ThemeColorClicked = UIColor.init(red: 26/255.0, green: 88/255.0, blue: 159/255.0, alpha: 1.0)
    
    public static let restDir = "http://127.0.0.1:8080/csci201-fp-server/rest"
    
    public static var user: User? = nil
    
}
