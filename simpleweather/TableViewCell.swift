//
//  TableViewCell.swift
//  simpleweather
//
//  Created by Lloyd Rochester on 2/26/17.
//  Copyright © 2017 Lloyd Rochester. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detailedForecast: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var temp: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
