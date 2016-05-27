//
//  LecturerOptionsTableViewCell.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/22/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

class LecturerOptionsTableViewCell: UITableViewCell {

    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    static let reuseIdentifier = "LecturerOptionsTableViewCellReuseIdentifier"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func clear() {
        iconView.image = nil
        titleLabel.text = nil
    }
}
