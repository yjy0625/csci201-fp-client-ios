//
//  SelectLocationTableViewCell.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/19/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit

class SelectLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
