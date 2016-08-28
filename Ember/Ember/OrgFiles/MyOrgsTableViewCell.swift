//
//  MyOrgsTableViewCell.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 7/21/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit

class MyOrgsTableViewCell: UITableViewCell {
    
    //MARK:Properties
    
    @IBOutlet weak var profImage: UIImageView!
    @IBOutlet weak var orgNameLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.profImage.layer.cornerRadius = self.profImage.frame.size.width / 2;
        self.profImage.clipsToBounds = true
        
        //Admin Label formatting
        self.adminLabel.layer.borderWidth = 1.0
        self.adminLabel.layer.borderColor = UIColor(red:250.0/255.0, green: 0/255.0, blue: 7.0/255.0, alpha: 1.0).CGColor
        self.adminLabel.layer.cornerRadius = 6
//        self.profImage.layer.borderWidth = 3.0;  
//        self.profImage.layer.borderColor = UIColor(red:90.0/255.0, green: 187.0/255.0, blue: 181.0/255.0, alpha: 1.0).CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
