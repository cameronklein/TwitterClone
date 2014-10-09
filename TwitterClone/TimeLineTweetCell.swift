//
//  TimeLineTweetCell.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class TimeLineTweetCell: UITableViewCell {

  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var tweetTextLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var topBarImage: UIImageView!
  @IBOutlet weak var favoriteLabel: UILabel!
  @IBOutlet weak var retweetLabel: UILabel!
  @IBOutlet weak var labelConstraint: NSLayoutConstraint!
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    
        // Configure the view for the selected state
  }
  

}
