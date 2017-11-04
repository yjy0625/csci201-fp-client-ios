//
//  LoginViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/25/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftyButton

class LoginViewController: AuthenticationViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernamePlaceholder: UILabel!
    @IBOutlet weak var passwordPlaceholder: UILabel!
    @IBOutlet weak var noAccountLabel: UILabel!
    
    private enum LoginField: String {
        case Username, Password
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let usernameTextField = SkyFloatingLabelTextField(frame: usernamePlaceholder.frame)
        usernameTextField.placeholder = LoginField.Username.rawValue
        usernameTextField.title = LoginField.Username.rawValue
        usernameTextField.font = UIFont(name: "Avenir", size: 17.0)
        
        usernameTextField.tintColor = Globals.ThemeColor
        usernameTextField.selectedTitleColor = Globals.ThemeColor
        usernameTextField.selectedLineColor = Globals.ThemeColor
        
        self.view.addSubview(usernameTextField)
        
        let passwordTextField = SkyFloatingLabelTextField(frame: passwordPlaceholder.frame)
        passwordTextField.placeholder = LoginField.Password.rawValue
        passwordTextField.title = LoginField.Password.rawValue
        passwordTextField.font = UIFont(name: "Avenir", size: 17.0)
        passwordTextField.isSecureTextEntry = true
        
        passwordTextField.tintColor = Globals.ThemeColor
        passwordTextField.selectedTitleColor = Globals.ThemeColor
        passwordTextField.selectedLineColor = Globals.ThemeColor
        
        self.view.addSubview(passwordTextField)
        
        noAccountLabel.font = UIFont(name: "Avenir", size: 13.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signin(_ sender: UIButton) {
        performSegue(withIdentifier: "enterHomepage", sender: self)
    }
    
    @IBAction func switchToSignup(_ sender: UIButton) {
        performSegue(withIdentifier: "enterSignupPage", sender: self)
    }
    
    // Mark: - UI Text Field Delegate
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        if let text = textField.text {
//            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
//                if(floatingLabelTextField.title == "Username") {
//                    if(text.characters.count < 3 || !text.contains("@")) {
//                        floatingLabelTextField.errorMessage = "Invalid email"
//                    }
//                    else {
//                        // The error message will only disappear when we reset it to nil or empty string
//                        floatingLabelTextField.errorMessage = ""
//                    }
//                }
//            }
//        }
//        return true
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
