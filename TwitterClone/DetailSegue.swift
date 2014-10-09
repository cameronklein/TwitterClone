//
//  DetailSegue.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/9/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class DetailSegue: UIStoryboardSegue {
  
  var source : HomeTimeLineViewController?
  var dest   : SingleTweetViewController?
  
  override func perform() {
    println("Hello!")
  }
   
}
