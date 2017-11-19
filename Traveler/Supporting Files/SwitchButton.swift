//
//  SwitchButton.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/19/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit

@IBDesignable
class SwitchButton: UIButton {
    
    @IBInspectable var unselectedColor: UIColor! = UIColor.gray
    @IBInspectable var selectedColor: UIColor! = Globals.ThemeColor
    
    var selection = false {
        didSet {
            setupViews()
        }
    }

    //this init fires usually called, when storyboards UI objects created:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    //This method is called during programmatic initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    func setupViews() {
        
        self.titleLabel?.font = UIFont.init(name: "Avenir", size: self.frame.height * 0.6)
        
        var targetColor = unselectedColor
        if selection {
            targetColor = selectedColor
        }
        
        self.titleLabel?.textColor = targetColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = targetColor?.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        
    }
    
    //required method to present changes in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupViews()
    }

}
