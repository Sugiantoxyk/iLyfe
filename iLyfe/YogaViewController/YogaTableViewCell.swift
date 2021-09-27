//
//  YogaTableViewCell.swift
//  iLyfe
//
//  Created by ITP312 on 15/7/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit

class YogaTableViewCell: UITableViewCell {

    @IBOutlet weak var tableImage: UIImageView!
    @IBOutlet weak var tableName: UILabel!
    @IBOutlet weak var tableSanskritName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
