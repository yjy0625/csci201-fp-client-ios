//
//  PlaceholderTimelineTableViewCell.swift
//  Traveler
//
//  Created by Jingyun Yang on 11/17/17.
//  Copyright © 2017 Jingyun Yang. All rights reserved.
//

import UIKit
import Shimmer

class PlaceholderTimelineTableViewCell: UITableViewCell {
    
    @IBOutlet var views: [UIView]!
    private var shimmeringViews: [FBShimmeringView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shimmeringViews = []
        
        for item in views {
            let shimmeringView = FBShimmeringView(frame: item.frame)
            shimmeringView.contentView = item
            shimmeringView.shimmeringSpeed = item.frame.width
            shimmeringView.isShimmering = true
            self.addSubview(shimmeringView)
            shimmeringViews.append(shimmeringView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
