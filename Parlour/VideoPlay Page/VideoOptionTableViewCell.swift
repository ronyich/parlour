//
//  VideoOptionTableViewCell.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/14.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit

class VideoOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var videoTitleLabel: UILabel!

    @IBOutlet weak var liveChatSetting: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
