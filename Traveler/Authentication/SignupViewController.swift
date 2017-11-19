//
//  SignupViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/25/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyButton
import SkyFloatingLabelTextField
import SDWebImage
import ImagePicker
import Lightbox
import SwiftMessages

class SignupViewController: AuthenticationViewController {

    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var addAvatarButton: UIButton!
    
    @IBOutlet weak var fullnamePlaceholder: UILabel!
    @IBOutlet weak var emailPlaceholder: UILabel!
    @IBOutlet weak var passwordPlaceholder: UILabel!
    
    @IBOutlet weak var signUpButton: FlatButton!
    @IBOutlet weak var alreadyHaveAccountLabel: UILabel!
    
    private weak var fullnameTextField: SkyFloatingLabelTextField!
    private weak var emailTextField: SkyFloatingLabelTextField!
    private weak var passwordTextField: SkyFloatingLabelTextField!
    
    fileprivate weak var imagePicker: UIImagePickerController?
    
    private enum SignupField: String {
        case Fullname, Email, Password
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let defaultAvatarImageUrl = try? "https://picsum.photos/200".asURL() {
            avatarImageView.sd_setImage(with: defaultAvatarImageUrl, completed: nil)
        }
        
        fullnameTextField = SkyFloatingLabelTextField(frame: fullnamePlaceholder.frame)
        fullnameTextField.placeholder = SignupField.Fullname.rawValue
        fullnameTextField.title = SignupField.Fullname.rawValue
        
        emailTextField = SkyFloatingLabelTextField(frame: emailPlaceholder.frame)
        emailTextField.placeholder = SignupField.Email.rawValue
        emailTextField.title = SignupField.Email.rawValue
        
        passwordTextField = SkyFloatingLabelTextField(frame: passwordPlaceholder.frame)
        passwordTextField.placeholder = SignupField.Password.rawValue
        passwordTextField.title = SignupField.Password.rawValue
        passwordTextField.isSecureTextEntry = true
        
        let textfields = [fullnameTextField, emailTextField, passwordTextField]
        
        for textfield in textfields {
            if let textfield = textfield {
                textfield.autocapitalizationType = .none
                textfield.autocorrectionType = .no
                textfield.font = UIFont(name: "Avenir", size: 17.0)
                textfield.tintColor = Globals.ThemeColor
                textfield.selectedTitleColor = Globals.ThemeColor
                textfield.selectedLineColor = Globals.ThemeColor
                
                self.view.addSubview(textfield)
            }
        }
        
        addAvatarButton.layer.cornerRadius = 15.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let textfields = [fullnameTextField, emailTextField, passwordTextField]
        for textfield in textfields {
            if let textfield = textfield {
                textfield.text = ""
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signup(_ sender: UIButton) {
        signUpButton.titleLabel?.text = "Signing up..."
        signUpButton.isEnabled = false
        
        fullnameTextField.errorMessage = ""
        emailTextField.errorMessage = ""
        passwordTextField.errorMessage = ""
        
        if let fullname = fullnameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, fullnameTextField.text != "", emailTextField.text != "", passwordTextField.text != "" {
            guard let signupRequestUrl = try? "\(Globals.restDir)/signup".asURL() else {
                NSLog("Create signup request url failed.")
                return
            }
            
            let uuid: String = UUID().uuidString
            
            let parameters: [String: Any] = [
                "id": uuid,
                "email": email,
                "name": fullname,
                "password": password,
                "score": 0
            ]
            
            var request = URLRequest(url: signupRequestUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
            
            Alamofire.request(request).responseObject { (response: DataResponse<User>) in
                if let statusCode = response.response?.statusCode {
                    NSLog("Status code: \(statusCode)")
                    switch statusCode {
                    case 200:
                        if let user = response.result.value {
                            Globals.user = user
                            
                            guard let imageRequestUrl = try? "\(Globals.restDir)/file/image/upload/user/\(user.id!)".asURL() else {
                                NSLog("Create image upload request url failed.")
                                return
                            }
                            
                            let imageData = UIImageJPEGRepresentation(self.avatarImageView.image!, 0.2)!
                            
                            var imageRequest = URLRequest(url: imageRequestUrl)
                            imageRequest.httpMethod = "POST"
                            imageRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                            imageRequest.httpBody = imageData
                            
                            Alamofire.request(imageRequest).responseString { response in
                                if let statusCode = response.response?.statusCode {
                                    NSLog("Status code: \(statusCode)")
                                    switch statusCode {
                                    case 200:
                                        self.signupSuccess()
                                        break
                                    default:
                                        self.emailTextField.errorMessage = "User already exists"
                                        break
                                    }
                                }
                                else {
                                    self.showError()
                                }
                            }
                        }
                        else {
                            self.showError()
                        }
                        break
                    default:
                        self.emailTextField.errorMessage = "User already exists"
                        break
                    }
                }
                else {
                    self.showError()
                }
                
                self.signUpButton.titleLabel?.text = "Create Account"
                self.signUpButton.isEnabled = true
            }
        }
        else {
            if self.fullnameTextField.text == "" {
                self.fullnameTextField.errorMessage = "Please enter fullname"
            }
            else if self.emailTextField.text == "" {
                self.emailTextField.errorMessage = "Please enter email"
            }
            else if self.passwordTextField.text == "" {
                self.passwordTextField.text = "Please enter password"
            }
            
            self.signUpButton.titleLabel?.text = "Create Account"
            self.signUpButton.isEnabled = true
        }
    }
    
    @IBAction func selectAvatarImage(_ sender: UIButton) {
        let imagePickerController = ImagePickerController()
        imagePickerController.imageLimit = 1
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func switchToSignin(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToLoginView", sender: self)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Network Error", message: "Cannot get response from server. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func signupSuccess() {
        let successMessage = MessageView.viewFromNib(layout: .cardView)
        successMessage.configureContent(title: "Success", body: "Your sign up request is processed.", iconImage: UIImage.init(named: "SuccessIcon")!)
        successMessage.backgroundView.backgroundColor = Globals.ThemeColor
        successMessage.button?.isHidden = true
        successMessage.iconLabel?.tintColor = UIColor.white
        successMessage.titleLabel?.textColor = UIColor.white
        successMessage.bodyLabel?.textColor = UIColor.white
        
        var config = SwiftMessages.Config()
        config.duration = .seconds(seconds: 2)
        
        SwiftMessages.show(config: config, view: successMessage)
        
        self.performSegue(withIdentifier: "unwindToLoginView", sender: self)
    }

}

extension SignupViewController: ImagePickerDelegate {
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }

        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }

        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.avatarImageView.image = images[0]
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

