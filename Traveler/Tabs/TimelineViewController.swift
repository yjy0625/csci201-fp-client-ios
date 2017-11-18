//
//  TimelineViewController.swift
//  Traveler
//
//  Created by Jingyun Yang on 10/25/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    
    fileprivate var posts: [ (Date, [Post]) ]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posts = []
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.separatorStyle = .none
        
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getPosts() {
        guard let dateMillis = Date().toMillis() else {
            NSLog("Cannot convert date to millisecond")
            return
        }
        Alamofire.request("\(Globals.restDir)/timeline/by/\(dateMillis)/maxLength/10").responseArray { (response: DataResponse<[Post]>) in
            if let statusCode = response.response?.statusCode {
                
                guard statusCode == 200, let newPosts = response.result.value else {
                    NSLog("Get posts failed with status code \(statusCode)")
                    return
                }
                
                // add section if new post have different day
                // populate posts object
                var currentDate: Int = -1
                for post in newPosts {
                    let thisDate = Date(milliseconds: post.timestamp)
                    
                    let isInSameDay =
                        Int(Double(currentDate) / Double(Date.DayInMilliseconds))
                            != Int(Double(post.timestamp) / Double(Date.DayInMilliseconds))
                    
                    if currentDate == -1 || isInSameDay {
                        self.posts.append( (thisDate, []) )
                        currentDate = post.timestamp
                    }
                    
                    self.posts[self.posts.count - 1].1.append(post)
                }
                
                self.timelineTableView.reloadData()
                
            }
        }
    }
    
    private func loadNewPosts() {
        
    }
    
    private func loadOlderPosts() {
        
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

extension TimelineViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if posts.count == 0 {
            return 1
        }
        else {
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.count == 0 {
            return 3
        }
        else {
            return posts[section].1.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if posts.count == 0 {
            if let cell = timelineTableView.dequeueReusableCell(withIdentifier: "placeholderCell", for: indexPath) as? PlaceholderTimelineTableViewCell {
                cell.tag = indexPath.hashValue
                return cell
            }
            else {
                return UITableViewCell()
            }
        }
        else {
            let post = posts[indexPath.section].1[indexPath.row]
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
            
            guard let userId = post.userId else {
                return UITableViewCell()
            }
            
            NSLog("Post Id: \(postId), numImages: \(numImages)")
            
            if numImages == 0 {
                guard let cell = timelineTableView.dequeueReusableCell(withIdentifier: "noImageCell", for: indexPath) as? NoImageTimelineTableViewCell else {
                    return UITableViewCell()
                }
                
                if let posterAvatarImageUrl = try? "\(Globals.restDir)/file/image/download/user/\(userId)".asURL() {
                    cell.avatarImageView.sd_setImage(with: posterAvatarImageUrl, completed: nil)
                }
                
                cell.nameLabel.text = post.userName
                cell.placeLabel.text = post.placeName
                cell.postContentTextView.text = postContent
                cell.timeLabel.text = Date(milliseconds: post.timestamp).toAgoString(numericDates: true)
                
                let contentSize = cell.postContentTextView.sizeThatFits(cell.postContentTextView.bounds.size)
                let contentHeight = contentSize.height
                let heightConstraint = NSLayoutConstraint(
                    item: cell.postContentTextView,
                    attribute: NSLayoutAttribute.height,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute,
                    multiplier: 1,
                    constant: contentHeight
                )
                NSLog("Inferred text view height: \(contentHeight)")
                view.addConstraint(heightConstraint)
                
                cell.tag = indexPath.hashValue
                return cell
            }
            else if numImages == 1 {
                guard let cell = timelineTableView.dequeueReusableCell(withIdentifier: "singleImageCell", for: indexPath) as? SingleImageTimelineTableViewCell else {
                    return UITableViewCell()
                }
                
                if let posterAvatarImageUrl = try? "\(Globals.restDir)/file/image/download/user/\(userId)".asURL() {
                    cell.avatarImageView.sd_setImage(with: posterAvatarImageUrl, completed: nil)
                }
                
                cell.nameLabel.text = post.userName
                cell.placeLabel.text = post.placeName
                cell.postContentTextView.text = postContent
                cell.timeLabel.text = Date(milliseconds: post.timestamp).toAgoString(numericDates: true)
                
                let contentSize = cell.postContentTextView.sizeThatFits(cell.postContentTextView.bounds.size)
                let contentHeight = contentSize.height
                let heightConstraint = NSLayoutConstraint(
                    item: cell.postContentTextView,
                    attribute: NSLayoutAttribute.height,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute,
                    multiplier: 1,
                    constant: contentHeight
                )
                NSLog("Inferred text view height: \(contentHeight)")
                view.addConstraint(heightConstraint)
                
                if let imageUrl = try? "\(Globals.restDir)/file/image/download/post/\(postId)/index/1".asURL() {
                    cell.postImageView.sd_setImage(with: imageUrl, completed: nil)
                }
                
                cell.tag = indexPath.hashValue
                return cell
            }
            else {
                guard let cell = timelineTableView.dequeueReusableCell(withIdentifier: "multipleImageCell", for: indexPath) as? MultipleImageTimelineTableViewCell else {
                    return UITableViewCell()
                }
                
                if let posterAvatarImageUrl = try? "\(Globals.restDir)/file/image/download/user/\(userId)".asURL() {
                    cell.avatarImageView.sd_setImage(with: posterAvatarImageUrl, completed: nil)
                }
                
                cell.nameLabel.text = post.userName
                cell.placeLabel.text = post.placeName
                cell.postContentTextView.text = postContent
                cell.timeLabel.text = Date(milliseconds: post.timestamp).toAgoString(numericDates: true)
                
                let contentSize = cell.postContentTextView.sizeThatFits(cell.postContentTextView.bounds.size)
                let contentHeight = contentSize.height
                let heightConstraint = NSLayoutConstraint(
                    item: cell.postContentTextView,
                    attribute: NSLayoutAttribute.height,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute,
                    multiplier: 1,
                    constant: contentHeight
                )
                NSLog("Inferred text view height: \(contentHeight)")
                view.addConstraint(heightConstraint)
                
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
    
}

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if posts.count == 0 {
            return 135.0
        }
        else {
            guard let numImages = posts[indexPath.section].1[indexPath.row].numImages else {
                NSLog("Getting number of images in post encounters an error.")
                return 0.0
            }
            
            if numImages == 0 {
                guard let cell = timelineTableView.viewWithTag(indexPath.hashValue) as? NoImageTimelineTableViewCell else {
                    NSLog("An error occurred when getting table view cell with no image")
                    return 0.0
                }
                let textViewHeight = cell.postContentTextView.frame.height
                return textViewHeight + 58.5
            }
            else if numImages == 1 {
                guard let cell = timelineTableView.viewWithTag(indexPath.hashValue) as? SingleImageTimelineTableViewCell else {
                    NSLog("An error occurred when getting table view cell with 1 image")
                    return 0.0
                }
                let textViewHeight = cell.postContentTextView.frame.height
                return textViewHeight + 223.0
            }
            else {
                guard let cell = timelineTableView.viewWithTag(indexPath.hashValue) as? MultipleImageTimelineTableViewCell else {
                    NSLog("An error occurred when getting table view cell with \(numImages) images")
                    return 0.0
                }
                let textViewHeight = cell.postContentTextView.frame.height
                
                let imageWidth = (self.timelineTableView.frame.width - 152.0) / 3
                if numImages <= 3 {
                    return imageWidth + textViewHeight + 94.0
                }
                else if numImages <= 6 {
                    return 2 * imageWidth + textViewHeight + 94.0
                }
                else {
                    return 3 * imageWidth + textViewHeight + 94.0
                }
            }
        }
    }
    
}
