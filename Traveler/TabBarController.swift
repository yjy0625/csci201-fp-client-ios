//
//  NavController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/26/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import SwiftyButton

class TabBarController: ESTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    func configureViewController() {
        self.title = "Irregularity"
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.isTranslucent = false
        
        self.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 2 {
                return true
            }
            return false
        }
        self.didHijackHandler = { // [weak self]
            tabbarController, viewController, index in
            return
        }
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 0.5)
        topBorder.backgroundColor = UIColor(white: 0.4, alpha: 1.0).cgColor
        self.tabBar.layer.addSublayer(topBorder)
        
        let v1 = UINavigationController.init(
                    rootViewController: self.storyboard?.instantiateViewController(withIdentifier: "HomeTab") as! HomeViewController)
        let v2 = UINavigationController.init(
                    rootViewController: self.storyboard?.instantiateViewController(withIdentifier: "ExploreTab") as!ExploreViewController)
        let v3 = UINavigationController.init(
                    rootViewController: self.storyboard?.instantiateViewController(withIdentifier: "AddPostTab") as! AddPostViewController)
        let v4 = UINavigationController.init(
                    rootViewController: self.storyboard?.instantiateViewController(withIdentifier: "TimelineTab") as! TimelineViewController)
        let v5 = UINavigationController.init(
                    rootViewController: self.storyboard?.instantiateViewController(withIdentifier: "MeTab") as! MeViewController)
        
        setupMiddleButton()
        
        v1.tabBarItem = ESTabBarItem.init(BounceContentView(), title: nil, image: UIImage(named: "HomeTabIcon"), selectedImage: UIImage(named: "HomeTabIcon-Selected"))
        v2.tabBarItem = ESTabBarItem.init(BounceContentView(), title: nil, image: UIImage(named: "ExploreTabIcon"), selectedImage: UIImage(named: "ExploreTabIcon-Selected"))
        v3.tabBarItem = ESTabBarItem.init(BounceContentView(), title: nil, image: nil, selectedImage: nil)
        v4.tabBarItem = ESTabBarItem.init(BounceContentView(), title: nil, image: UIImage(named: "TimelineTabIcon"), selectedImage: UIImage(named: "TimelineTabIcon-Selected"))
        v5.tabBarItem = ESTabBarItem.init(BounceContentView(), title: nil, image: UIImage(named: "MeTabIcon"), selectedImage: UIImage(named: "MeTabIcon-Selected"))
        
        let tabBarViewControllers = [v1, v2, v3, v4, v5]
        let tabNames = ["Home", "Explore", "Add Post", "Timeline", "Me"]
        
        for i in 0 ..< tabBarViewControllers.count {
            let v = tabBarViewControllers[i]
            v.navigationBar.isTranslucent = true
            v.navigationBar.barTintColor = UIColor.white
            v.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName: UIFont(name: "Avenir", size: 17)!]
            v.navigationBar.tintColor = UIColor.white
            v.navigationBar.topItem?.title = tabNames[i]
        }
        
        self.viewControllers = tabBarViewControllers
    }
    
    func setupMiddleButton() {
        let menuButton = FlatButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height / 2 - self.tabBar.frame.size.height / 2
        menuButtonFrame.origin.x = view.bounds.width / 2 - menuButtonFrame.size.width / 2
        menuButton.frame = menuButtonFrame
        
        menuButton.color = Globals.ThemeColor
        menuButton.highlightedColor = Globals.ThemeColorClicked
        menuButton.cornerRadius = menuButtonFrame.height / 2
        view.addSubview(menuButton)
        
        menuButton.setImage(UIImage(named: "EditTabIcon"), for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    @objc private func menuButtonAction(sender: UIButton) {
        self.performSegue(withIdentifier: "addPost", sender: self)
    }
    
    @IBAction func unwindToMainPage(segue: UIStoryboardSegue) {
        
    }
    
}
