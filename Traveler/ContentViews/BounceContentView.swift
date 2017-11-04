//
//  BounceContentView.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/26/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BounceContentView: BasicContentView {

    public var duration = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = UIColor.init(red: 48/255.0, green: 48/255.0, blue: 48/255.0, alpha: 1.0)
        highlightTextColor = Globals.ThemeColor
        iconColor = UIColor.init(white: 48 / 255.0, alpha: 1.0)
        highlightIconColor = Globals.ThemeColor
        backdropColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightBackdropColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0, 0.85, 1.1, 0.95, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }

}
