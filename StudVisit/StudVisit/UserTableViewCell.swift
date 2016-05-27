//
//  UserTableViewCell.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/17/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    static let reuseIdentifier = "UserTableViewCellReuseIdentifier"
    
    @IBOutlet var roleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func clear() {
        roleLabel.text = nil
        nameLabel.text = nil
    }
}

extension UserTableViewCell {
    func fillWithUserName(name: String, role: Int) {
        nameLabel.text = name
        if role == 0 {
            roleLabel.text = "Студент"
            roleLabel.textColor = UIColor.blueColor()
        } else {
            roleLabel.text = "Викладач"
            roleLabel.textColor = UIColor.redColor()
        }
    }
}


