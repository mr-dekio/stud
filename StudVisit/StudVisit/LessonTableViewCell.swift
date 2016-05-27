//
//  LessonTableViewCell.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/18/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

class LessonTableViewCell: UITableViewCell {

    static let reuseIdentifier = "LessonTableViewCellReuseIdentifier"
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
