//
//  OptionsViewCell.swift
//  WorkoutTimer
//
//  Created by Gavin Ryder on 8/19/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit

class OptionsViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let bgColorView = UIView()
        bgColorView.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        self.selectedBackgroundView = bgColorView

        // Configure the view for the selected state
    }

}
