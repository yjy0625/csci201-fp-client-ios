//
//  UserInfoTableViewCell.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/18/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Alamofire

protocol UserInfoTableViewCellDelegate {
    func shouldLogout()
}

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statsCollectionView: UICollectionView!
    
    var delegate: UserInfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let user = Globals.user {
            if let avatarUrl = try? "\(Globals.restDir)/file/image/download/user/\(user.id!)".asURL() {
                self.avatarImageView.sd_setImage(with: avatarUrl, completed: nil)
            }
            
            self.nameLabel.text = user.name!
        }
        else {
            NSLog("User not found in global data.")
        }
        
        statsCollectionView.dataSource = self
    }

    @IBAction func logout(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.shouldLogout()
        }
    }
}

extension UserInfoTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let index = indexPath.row
        if index < 0 || index > 2 {
            return UICollectionViewCell()
        }
        
        let identifiers = ["pointsCell", "levelCell", "rankingCell"]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifiers[index], for: indexPath) as? HomeViewStatsCellCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.titleLabel.font = UIFont(name: "Avenir", size: 14.0)
        cell.statsLabel.font = UIFont(name: "Avenir", size: 44.0)
        
        if indexPath.row == 0 {
            if let score = Globals.user?.score {
                cell.statsLabel.text = "\(score)"
            }
            else {
                cell.statsLabel.text = "--"
            }
            
            return cell
        }
        else if indexPath.row == 1 {
            if let score = Globals.user?.score {
                cell.statsLabel.text = "\(Int(floor(Double(score / 100))) + 1)"
            }
            else {
                cell.statsLabel.text = "--"
            }
            
            return cell
        }
        else {
            cell.statsLabel.text = "--"
            
            guard let user = Globals.user?.id else {
                return UICollectionViewCell()
            }
            
            let rankRequestUrl: String = "\(Globals.restDir)/user/rank/id/\(user)"
            Alamofire.request(rankRequestUrl).responseString { response in
                if let rankString = response.value {
                    if let rank = Int(rankString) {
                        cell.statsLabel.text = rank.prettify()
                    }
                }
            }
            
            return cell
        }
        
    }
}
