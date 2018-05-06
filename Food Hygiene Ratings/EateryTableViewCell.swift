//
//  EateryTableViewCell.swift
//  Food Hygiene Ratings
//
//  Created by Kenny Wong on 25/01/2018.
//  Copyright © 2018 Kenny Wong. All rights reserved.
//

import UIKit

class EateryTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
