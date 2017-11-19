//
//  PlaceTableViewCell.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/18/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: RoundImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pointLabel.layer.backgroundColor = Globals.ThemeColor.cgColor
        pointLabel.layer.cornerRadius = 3.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
