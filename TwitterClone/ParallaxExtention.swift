//
//  ParallaxExtention.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/10/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

extension UIView {
  func addNaturalOnTopEffect(maximumRelativeValue : Float = 20.0) {
    //Horizontal motion
    var motionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis);
    motionEffect.minimumRelativeValue = maximumRelativeValue;
    motionEffect.maximumRelativeValue = -maximumRelativeValue;
    addMotionEffect(motionEffect);
    
    //Vertical motion
    motionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis);
    motionEffect.minimumRelativeValue = maximumRelativeValue;
    motionEffect.maximumRelativeValue = -maximumRelativeValue;
    addMotionEffect(motionEffect);
  }
  
  func addNaturalBelowEffect(maximumRelativeValue : Float = 20.0) {
    addNaturalOnTopEffect(maximumRelativeValue: -maximumRelativeValue)
  }
}
