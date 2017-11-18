//
//  TimelineTableViewCell.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/17/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit

 class TimelineTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var postContentTextView: TextViewFixed!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        nameLabel.font = UIFont(descriptor: (UIFont(name: "Avenir", size: 13.0)?.fontDescriptor.withSymbolicTraits(.traitBold))!, size: 13.0)
        placeLabel.font = UIFont(name: "Avenir", size: 13.0)
        timeLabel.font = UIFont(name: "Avenir", size: 12.0)
    }
}
