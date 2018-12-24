//
//  ParlourTableViewCell.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/23.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit

class ParlourTableViewCell: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var channelHostNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
