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
  
  @IBAction func cancel(sender: UIButton) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func post(sender: UIButton) {
    networkController.postTweet(textField.text, completionHandler: { (errorDescription, tweets) -> (Void) in
      println("Tweet posted!")
    })
  }



    

}
