//
//  TableViewCell3.swift
//  Weather
//
//  Created by Dmitry Moretz on 01.04.2020.
//  Copyright © 2020 Dmitry Moretz. All rights reserved.
//

import UIKit

class TableViewCell3: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            if self.accessoryType == .checkmark  {
                self.accessoryType = .none
            } else {
                self.accessoryType = .checkmark
            }
        }
    }

}
