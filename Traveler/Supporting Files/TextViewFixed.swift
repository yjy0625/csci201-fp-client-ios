//
//  TextViewFixed.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/17/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit

@IBDesignable
class TextViewFixed: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
        font = UIFont(name: "Avenir", size: 17.0)
    }

}
