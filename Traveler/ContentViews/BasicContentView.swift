//
//  BasicContentView.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/26/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BasicContentView: ESTabBarItemContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.init(white: 0.0 / 255.0, alpha: 1.0)
        highlightTextColor = Globals.ThemeColor
        iconColor = UIColor.init(white: 0.0 / 255.0, alpha: 1.0)
        highlightIconColor = Globals.ThemeColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
