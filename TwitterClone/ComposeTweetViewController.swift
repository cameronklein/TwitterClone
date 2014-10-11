//
//  ComposeTweetViewController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/10/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController {
  
  @IBOutlet weak var textField: UITextView!
  var networkController : NetworkController!
  
  @IBOutlet weak var label: UILabel!
  //MARK - Lifecycle Methods
  
  override func viewDidLoad() {
      super.viewDidLoad()

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
    
    textField.layer.borderColor = UIColor.blackColor().CGColor
    textField.layer.borderWidth = 1
    textField.layer.cornerRadius = 10
    textField.clipsToBounds = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK - Helper Methods
  @IBAction func sliderSlid(sender: UISlider) {
    switch sender.value{
    case 0...1:
      label.text = "Not at all"
    case 1...2:
      label.text = "A little"
    case 2...3:
      label.text = "Somewhat"
    case 3...4:
      label.text = "Pretty profound"
    default:
      label.text = "Wow"
    }
  }
  
  @IBAction func post(sender: UIButton) {
    networkController.postTweet(textField.text, completionHandler: { (errorDescription, tweets) -> (Void) in
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        if errorDescription == nil {
          self.textField.text = nil
          let alert = UIAlertController(title: "Success!", message: "Tweet Posted!", preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "Great!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
          })
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        } else {
          let alert = UIAlertController(title: "Uh oh!", message: "Something went wrong. Try again?", preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        }
      })
    })
  }
}



    

