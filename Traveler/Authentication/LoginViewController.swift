//
//  LoginViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/25/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SkyFloatingLabelTextField
import SwiftyButton

class LoginViewController: AuthenticationViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernamePlaceholder: UILabel!
    @IBOutlet weak var passwordPlaceholder: UILabel!
    @IBOutlet weak var signInButton: FlatButton!
    @IBOutlet weak var noAccountLabel: UILabel!
    
    private weak var usernameTextField: SkyFloatingLabelTextField!
    private weak var passwordTextField: SkyFloatingLabelTextField!
    
    private enum LoginField: String {
        case Username, Password
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField = SkyFloatingLabelTextField(frame: usernamePlaceholder.frame)
        usernameTextField.placeholder = LoginField.Username.rawValue
        usernameTextField.title = LoginField.Username.rawValue
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.font = UIFont(name: "Avenir", size: 17.0)
        
        usernameTextField.tintColor = Globals.ThemeColor
        usernameTextField.selectedTitleColor = Globals.ThemeColor
        usernameTextField.selectedLineColor = Globals.ThemeColor
        usernameTextField.returnKeyType = UIReturnKeyType.next
        
        self.view.addSubview(usernameTextField)
        usernameTextField.delegate = self
        
        passwordTextField = SkyFloatingLabelTextField(frame: passwordPlaceholder.frame)
        passwordTextField.placeholder = LoginField.Password.rawValue
        passwordTextField.title = LoginField.Password.rawValue
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.font = UIFont(name: "Avenir", size: 17.0)
        passwordTextField.isSecureTextEntry = true
        
        passwordTextField.tintColor = Globals.ThemeColor
        passwordTextField.selectedTitleColor = Globals.ThemeColor
        passwordTextField.selectedLineColor = Globals.ThemeColor
        passwordTextField.returnKeyType = UIReturnKeyType.done
        
        self.view.addSubview(passwordTextField)
        passwordTextField.delegate = self
        noAccountLabel.font = UIFont(name: "Avenir", size: 13.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        usernameTextField.text = ""
        passwordTextField.text = ""
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signin(_ sender: UIButton) {
        
        signInButton.setTitle("Logging in...", for: .normal)
        signInButton.isEnabled = false
        
        usernameTextField.errorMessage = ""
        passwordTextField.errorMessage = ""
        
        if let username = usernameTextField.text, let password = passwordTextField.text, usernameTextField.text != "", passwordTextField.text != "" {
            let loginRequestUrl: String = "\(Globals.restDir)/signin/email/\(username)/password/\(password)"
            
            Alamofire.request(loginRequestUrl, method: .post).responseObject { (response: DataResponse<User>) in
                if let statusCode = response.response?.statusCode {
                    
                    switch statusCode {
                    case 200:
                        if let user = response.result.value {
                            Globals.guest = false
                            Globals.user = user
                            self.performSegue(withIdentifier: "enterHomepage", sender: self)
                        }
                        else {
                            self.showError()
                        }
                        break
                    case 404:
                        self.usernameTextField.errorMessage = "User not found"
                        break
                    case 400:
                        self.passwordTextField.errorMessage = "Password incorrect"
                        break
                    default:
                        break
                    }
                }
                else {
                    self.showError()
                }
                
                self.signInButton.setTitle("Log In", for: .normal)
                self.signInButton.isEnabled = true
            }
        }
        else {
            if usernameTextField.text == nil || usernameTextField.text == "" {
                usernameTextField.errorMessage = "Username cannot be empty"
            }
            else if passwordTextField.text == nil || passwordTextField.text == "" {
                passwordTextField.errorMessage = "Password cannot be empty"
            }
            
            self.signInButton.setTitle("Login", for: .normal)
            self.signInButton.isEnabled = true
        }
    }
    
    @IBAction func switchToSignup(_ sender: UIButton) {
        performSegue(withIdentifier: "enterSignupPage", sender: self)
    }
    
    @IBAction func signInAsGuest(_ sender: UIButton) {
        Globals.user = nil
        Globals.guest = true
        self.performSegue(withIdentifier: "enterHomepage", sender: self)
    }
    private func showError() {
        let alert = UIAlertController(title: "Network Error", message: "Cannot get response from server. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            self.passwordTextField.resignFirstResponder()
        }
        return false
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
    
    @IBAction func unwindToLoginView(segue: UIStoryboardSegue) {}

}
