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

class AddPostViewController: UIViewController {

    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var publicSwitch: SwitchButton!
    @IBOutlet weak var privateSwitch: SwitchButton!
    
    @IBOutlet weak var postContentTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var postImageCollectionView: UICollectionView!
    
    private static let TextViewPlaceholder = "Write about what's in your mind."
    
    var location: Place?
    fileprivate var postImages = [UIImage]()
    fileprivate weak var imagePickerController = ImagePickerController()
    fileprivate var postIsPublic = true
    
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
        
        imagePickerController?.imageLimit = 9
        imagePickerController?.delegate = self
        
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
    
    // MARK: - Navigation
    
    @IBAction func unwindToAddPostView(segue: UIStoryboardSegue) {}

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
        return postImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postImageCollectionViewCell", for: indexPath) as? PostImageCollectionViewCell {
            
            cell.imageView.image = postImages[indexPath.row]
            return cell
            
        }
        else {
            return UICollectionViewCell()
        }
    }
    
}

extension AddPostViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imagePickerController = imagePickerController else {
            return
        }
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
    }
    
}
