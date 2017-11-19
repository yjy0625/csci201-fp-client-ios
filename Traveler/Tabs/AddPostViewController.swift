//
//  AddPostViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/26/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import ImagePicker
import Lightbox
import SwiftMessages
import Alamofire
import SwiftyButton

class AddPostViewController: UIViewController {

    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var publicSwitch: SwitchButton!
    @IBOutlet weak var privateSwitch: SwitchButton!
    
    @IBOutlet weak var postContentTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var postImageCollectionView: UICollectionView!
    
    @IBOutlet weak var addPostButton: FlatButton!
    
    private static let TextViewPlaceholder = "Write about what's in your mind."
    
    var location: Place?
    fileprivate var postImages = [UIImage]()
    fileprivate var imagePickerController = ImagePickerController()
    fileprivate var postIsPublic = true
    
    fileprivate var uploadedCount = 0
    
    var unwindSegueName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.navigationBar.isTranslucent = true
            navController.navigationBar.barTintColor = UIColor.white
            navController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black, NSAttributedStringKey.font: UIFont(name: "Avenir", size: 17)!]
            navController.navigationBar.tintColor = UIColor.white
            navController.setNavigationBarHidden(false, animated: false)
        }
        
        postContentTextView.delegate = self
        postContentTextView.text = AddPostViewController.TextViewPlaceholder
        postContentTextView.textColor = UIColor.lightGray
        
        publicSwitch.selection = true
        privateSwitch.selection = false
        
        imagePickerController.imageLimit = 9
        imagePickerController.delegate = self
        
        postImageCollectionView.delegate = self
        postImageCollectionView.dataSource = self
        
        if let user = Globals.user {
            if let avatarUrl = try? "\(Globals.restDir)/file/image/download/user/\(user.id!)".asURL() {
                self.avatarImageView.sd_setImage(with: avatarUrl, completed: nil)
            }
            
            self.nameLabel.text = user.name!
        }
        else {
            NSLog("User not found in global data.")
        }
        
        if let location = location {
            locationLabel.text = location.name!
        }
        else {
            performSegue(withIdentifier: "selectLocation", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func validate() -> Bool {
        if self.postContentTextView.text == AddPostViewController.TextViewPlaceholder || self.postContentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            return false
        }
        
        return true
    }
    
    @IBAction func post(_ sender: UIButton) {
        if validate() {
            addPostButton.titleLabel?.text = "Posting to timeline..."
            addPostButton.isEnabled = false
            
            guard let userId = Globals.user?.id else {
                NSLog("Cannot get user id.")
                return
            }
            
            guard let placeId = location?.id else {
                NSLog("Cannot get place id.")
                return
            }
            
            guard let postContent = self.postContentTextView.text else {
                NSLog("Cannot get post content.")
                return
            }
            
            guard let addPostRequestUrl = try? "\(Globals.restDir)/post".asURL() else {
                NSLog("Create signup request url failed.")
                return
            }
            
            let uuid: String = UUID().uuidString
            
            let timestamp: [String: Any] = [
                "$date": Date().toMillis()
            ]
            
            let parameters: [String: Any] = [
                "id": uuid,
                "timestamp": timestamp,
                "placeId": placeId,
                "userId": userId,
                "postContent": postContent,
                "numImages": postImages.count,
                "isPublic": postIsPublic
            ]
            
            var request = URLRequest(url: addPostRequestUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
            
            Alamofire.request(request).responseString { response in
                if let statusCode = response.response?.statusCode {
                    NSLog("Status code: \(statusCode)")
                    switch statusCode {
                    case 200:
                        if self.postImages.count == 0 {
                            self.showSuccess()
                            break
                        }
                        
                        self.uploadedCount = 0
                        
                        for i in 1 ... self.postImages.count {
                            guard let imageRequestUrl = try? "\(Globals.restDir)/file/image/upload/post/\(uuid)/index/\(i)".asURL() else {
                                NSLog("Create image upload request url failed.")
                                return
                            }
                            
                            let imageData = UIImageJPEGRepresentation(self.postImages[i-1], 0.2)!
                            
                            var imageRequest = URLRequest(url: imageRequestUrl)
                            imageRequest.httpMethod = "POST"
                            imageRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                            imageRequest.httpBody = imageData
                            
                            Alamofire.request(imageRequest).responseString { response in
                                if let statusCode = response.response?.statusCode {
                                    NSLog("Status code: \(statusCode)")
                                    switch statusCode {
                                    case 200:
                                        self.uploadedCount += 1
                                        NSLog("Submitted image count: \(self.uploadedCount)")
                                        if self.uploadedCount == self.postImages.count {
                                            self.showSuccess()
                                        }
                                        break
                                    default:
                                        self.showError()
                                        break
                                    }
                                }
                                else {
                                    self.showError()
                                }
                            }
                        }
                        
                        break
                    default:
                        self.showError()
                        break
                    }
                }
                else {
                    self.showError()
                }
            }
        }
        else {
            let error = MessageView.viewFromNib(layout: .tabView)
            error.configureTheme(.error)
            error.configureContent(title: "Error", body: "Post content cannot be empty.")
            error.button?.isHidden = true
            
            var config = SwiftMessages.Config()
            config.duration = .seconds(seconds: 2)
            
            SwiftMessages.show(config: config, view: error)
        }
    }
    
    private func showSuccess() {
        if let points = location?.points {
            let successMessage = MessageView.viewFromNib(layout: .cardView)
            successMessage.configureContent(title: "Success", body: "Your post is successfully added to your timeline! You earned \(points) points.", iconImage: UIImage.init(named: "SuccessIcon")!)
            successMessage.backgroundView.backgroundColor = Globals.ThemeColor
            successMessage.button?.isHidden = true
            successMessage.iconLabel?.tintColor = UIColor.white
            successMessage.titleLabel?.textColor = UIColor.white
            successMessage.bodyLabel?.textColor = UIColor.white
            
            var config = SwiftMessages.Config()
            config.duration = .seconds(seconds: 2)
            
            SwiftMessages.show(config: config, view: successMessage)
        }
        else {
            NSLog("Cannot get location points. Notification cannot be shown.")
        }
        
        self.addPostButton.titleLabel?.text = "Post to My Timeline"
        self.addPostButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showError() {
        let error = MessageView.viewFromNib(layout: .tabView)
        error.configureTheme(.error)
        error.configureContent(title: "Error", body: "Cannot post to timeline because an error occurred.")
        error.button = nil
        
        var config = SwiftMessages.Config()
        config.duration = .seconds(seconds: 2)
        
        SwiftMessages.show(config: config, view: error)
        
        self.addPostButton.titleLabel?.text = "Post to My Timeline"
        self.addPostButton.isEnabled = true
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToAddPostView(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwindToAddPostView", let svc = segue.source as? SelectLocationViewController {
            self.location = svc.selectedLocation
            
            if self.location == nil {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.locationLabel.text = svc.selectedLocation?.name!
            }
        }
        
    }

    // MARK: - Public / Private Switch
    
    @IBAction func switchToPublic(_ sender: UIButton) {
        // display
        publicSwitch.selection = true
        privateSwitch.selection = false
        
        // data
        postIsPublic = true
    }
    
    @IBAction func switchToPrivate(_ sender: UIButton) {
        // display
        publicSwitch.selection = false
        privateSwitch.selection = true
        
        // data
        postIsPublic = false
    }
    
}

extension AddPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = AddPostViewController.TextViewPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        // update character count text
        if numberOfChars <= 144 {
            let numCharsLeft = 144 - numberOfChars
            var plural = ""
            if numCharsLeft > 1 {
                plural = "s"
            }
            self.characterCountLabel.text = "\(numCharsLeft) character\(plural) left"
        }
        
        return numberOfChars <= 144
    }
    
}

extension AddPostViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if postImages.count == 0 {
            return 1
        }
        else {
            return postImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if postImages.count == 0 {
            if let cell = postImageCollectionView.dequeueReusableCell(withReuseIdentifier: "postImageCollectionViewCell", for: indexPath) as? PostImageCollectionViewCell {
                
                cell.imageView.image = UIImage.init(named: "SquareAddIcon")
                return cell
                
            }
            else {
                return UICollectionViewCell()
            }
        }
        else {
            if let cell = postImageCollectionView.dequeueReusableCell(withReuseIdentifier: "postImageCollectionViewCell", for: indexPath) as? PostImageCollectionViewCell {
                
                cell.imageView.image = postImages[indexPath.row]
                return cell
                
            }
            else {
                return UICollectionViewCell()
            }
        }
    }
    
}

extension AddPostViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NSLog("Item \(indexPath.row) selected.")
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
}

extension AddPostViewController: ImagePickerDelegate {
    
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
        self.postImages = images
        self.postImageCollectionView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
