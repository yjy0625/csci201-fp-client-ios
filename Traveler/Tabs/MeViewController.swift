//
//  MeViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/25/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class MeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var posts = [Post]()
    fileprivate var loaded = false
    
    private weak var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getUserInfoUpdate()
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getUserInfoUpdate() {
        guard let userId = Globals.user?.id else {
            NSLog("Cannot get user id.")
            return
        }
        
        let userInfoUpdateRequestUrl: String = "\(Globals.restDir)/user/id/\(userId)"
        
        Alamofire.request(userInfoUpdateRequestUrl).responseObject { (response: DataResponse<User>) in
            if let statusCode = response.response?.statusCode {
                
                switch statusCode {
                case 200:
                    if let user = response.result.value {
                        Globals.user = user
                        self.collectionView?.reloadData()
                    }
                    else {
                        NSLog("Get user info update error.")
                    }
                    break
                default:
                    NSLog("Get user info update error.")
                    break
                }
            }
            else {
                NSLog("Get user info update error.")
            }
        }
    }
    
    private func getPosts() {
        var tempPosts = [Post]()
        
        guard let userId = Globals.user?.id else {
            NSLog("Error when getting user id from global data.")
            return
        }
        
        Alamofire.request("\(Globals.restDir)/timeline/user/\(userId)/maxLength/80").responseArray { (response: DataResponse<[Post]>) in
            if let statusCode = response.response?.statusCode {
                
                guard statusCode == 200, let newPosts = response.result.value else {
                    NSLog("Get posts failed with status code \(statusCode)")
                    return
                }
                
                for post in newPosts {
                    tempPosts.append(post)
                }
                
                self.loaded = true
                self.posts = tempPosts
                self.tableView.reloadSections(IndexSet.init(integer: 1), with: .automatic)
                self.tableView.setNeedsLayout()
                
            }
        }
    }
    
    func logout() {
        let alertController = UIAlertController.init(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Yes", style: .destructive, handler: {
            _ in
            self.performSegue(withIdentifier: "unwindToLoginViewFromMeView", sender: self)
        }))
        alertController.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: {
            _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}

extension MeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if loaded {
            return posts.count
        }
        else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // user information cell
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell", for: indexPath) as? UserInfoTableViewCell {
                collectionView = cell.statsCollectionView
                cell.delegate = self
                return cell
            }
            else {
                NSLog("Unable to get user info cell.")
                return UITableViewCell()
            }
        }
        
        // loading cells
        if !loaded {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "placeholderCell", for: indexPath) as? PlaceholderTimelineTableViewCell {
                cell.tag = indexPath.hashValue
                return cell
            }
            else {
                return UITableViewCell()
            }
        }
        
        // user post contents
        let post = posts[indexPath.row]
        guard let numImages = post.numImages else {
            NSLog("Get number of images in post \(post.id) encounters an error.")
            return UITableViewCell()
        }
        
        guard let postId = post.id else {
            NSLog("Error when trying to get post id.")
            return UITableViewCell()
        }
        
        guard let postContent = post.postContent else {
            NSLog("Error when trying to get content of post \(postId).")
            return UITableViewCell()
        }
        
        if numImages == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "noImageCell", for: indexPath) as? NoImageTimelineTableViewCell else {
                return UITableViewCell()
            }
            
            cell.nameLabel.text = Date(milliseconds: post.timestamp).toAgoString(numericDates: true)
            cell.placeLabel.text = ""
            cell.postContentTextView.text = postContent
            cell.timeLabel.text = "At \(post.placeName!)"
            
            cell.tag = indexPath.hashValue
            return cell
        }
        else if numImages == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "singleImageCell", for: indexPath) as? SingleImageTimelineTableViewCell else {
                return UITableViewCell()
            }
            
            cell.nameLabel.text = Date(milliseconds: post.timestamp).toAgoString(numericDates: true)
            cell.placeLabel.text = ""
            cell.postContentTextView.text = postContent
            cell.timeLabel.text = "At \(post.placeName!)"
            
            if let imageUrl = try? "\(Globals.restDir)/file/image/download/post/\(postId)/index/1".asURL() {
                cell.postImageView.sd_setImage(with: imageUrl, completed: nil)
            }
            
            cell.tag = indexPath.hashValue
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "multipleImageCell", for: indexPath) as? MultipleImageTimelineTableViewCell else {
                return UITableViewCell()
            }
            
            cell.nameLabel.text = Date(milliseconds: post.timestamp).toAgoString(numericDates: true)
            cell.placeLabel.text = ""
            cell.postContentTextView.text = postContent
            cell.timeLabel.text = "At \(post.placeName!)"
            
            for index in 1 ... numImages {
                if index >= 10 {
                    break
                }
                
                if let imageUrl = try? "\(Globals.restDir)/file/image/download/post/\(postId)/index/\(index)".asURL() {
                    cell.postImageViews[index - 1].sd_setImage(with: imageUrl, completed: nil)
                }
            }
            
            if numImages < 9 {
                for index in numImages + 1 ... 9 {
                    cell.postImageViews[index - 1].isHidden = true
                    cell.postImageViews[index - 1].isUserInteractionEnabled = false
                }
            }
            
            cell.tag = indexPath.hashValue
            return cell
        }
    }
    
}

extension MeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 360.0
        }
        
        // post cells
        if posts.count == 0 {
            return 135.0
        }
        else {
            guard let numImages = posts[indexPath.row].numImages else {
                NSLog("Getting number of images in post encounters an error.")
                return 0.0
            }
            
            if numImages == 0 {
                guard let cell = tableView.viewWithTag(indexPath.hashValue) as? NoImageTimelineTableViewCell else {
                    NSLog("An error occurred when getting table view cell with no image")
                    return 0.0
                }
                
                let textViewHeight = cell.postContentTextView.adjustHeight()
                
                return textViewHeight + 67.0
            }
            else if numImages == 1 {
                guard let cell = tableView.viewWithTag(indexPath.hashValue) as? SingleImageTimelineTableViewCell else {
                    NSLog("An error occurred when getting table view cell with 1 image")
                    return 0.0
                }
                
                let textViewHeight = cell.postContentTextView.adjustHeight()
                
                return textViewHeight + 231.0
            }
            else {
                guard let cell = tableView.viewWithTag(indexPath.hashValue) as? MultipleImageTimelineTableViewCell else {
                    NSLog("An error occurred when getting table view cell with \(numImages) images")
                    return 0.0
                }
                
                let textViewHeight = cell.postContentTextView.adjustHeight()
                
                let imageWidth = (tableView.frame.width - 152.0) / 3
                if numImages <= 3 {
                    return imageWidth + textViewHeight + 102.0
                }
                else if numImages <= 6 {
                    return 2 * imageWidth + textViewHeight + 102.0
                }
                else {
                    return 3 * imageWidth + textViewHeight + 102.0
                }
            }
        }
    }
    
}

extension MeViewController: UserInfoTableViewCellDelegate {
    func shouldLogout() {
        self.logout()
    }
}
