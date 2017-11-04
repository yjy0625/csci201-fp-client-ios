//
//  AddPostViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/26/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.navigationBar.isTranslucent = true
            navController.navigationBar.barTintColor = UIColor.white
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName: UIFont(name: "Avenir", size: 17)!]
            navController.navigationBar.tintColor = UIColor.white
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
