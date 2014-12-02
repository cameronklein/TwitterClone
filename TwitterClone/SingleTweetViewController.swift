//
//  SingleTweetViewController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/8/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class SingleTweetViewController: UIViewController {
  
  var tweet: Tweet!

  @IBOutlet weak var topBar: UIImageView!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var profileLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var tweetLabel: UILabel!
  @IBOutlet weak var retweetLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  var networkController : NetworkController!
  let operationQueue = NSOperationQueue()
  let labelBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
  
  // MARK: - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
    
    if tweet.image == nil || tweet.bannerImage == nil {
      networkController.fetchImagesForTweet(tweet, completionHandler: { (errorDescription, images) -> (Void) in
        if self.tweet.image == nil {
          self.tweet.image = images.0
        }
        
        if self.tweet.bannerImage == nil{
          self.tweet.bannerImage = images.1
        }
        
      })
    }
    
    topBar.backgroundColor  = UIColor.blueColor()
    topBar.image            = tweet.bannerImage
    profileImage.image      = tweet.image
    profileLabel.text       = " " + tweet.username! + " "
    dateLabel.text          = tweet.readableDate
    tweetLabel.text         = tweet.text
    retweetLabel.text       = String(tweet.retweetCount)
    favoriteLabel.text      = String(tweet.favoriteCount)
    
    let tapRecognizer = UITapGestureRecognizer()
    tapRecognizer.addTarget(self, action: "tapCaptured:")
    profileImage.addGestureRecognizer(tapRecognizer)
    profileImage.userInteractionEnabled = true
    
    let otherTapRecognizer = UITapGestureRecognizer()
    otherTapRecognizer.addTarget(self, action: "tapCaptured:")
    profileLabel.addGestureRecognizer(otherTapRecognizer)
    profileLabel.userInteractionEnabled = true
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    profileImage.clipsToBounds = true
    
    profileImage.layer.borderColor = UIColor.blackColor().CGColor
    profileImage.layer.borderWidth = 2
    
    profileLabel.backgroundColor = labelBackgroundColor
    profileLabel.layer.cornerRadius = 4
    profileLabel.clipsToBounds = true
    
    dateLabel.backgroundColor = labelBackgroundColor
    dateLabel.layer.cornerRadius = 4
    dateLabel.clipsToBounds = true
    
    self.profileImage.layer.needsDisplayOnBoundsChange = true
    let dateFrame = topBar.layer.frame
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Helper Methods
  
  func tapCaptured(sender: UILongPressGestureRecognizer){
    if sender.state == UIGestureRecognizerState.Ended {
      let userVC = self.storyboard?.instantiateViewControllerWithIdentifier("USER_TIMELINE") as UserTimeLineViewController
      userVC.initialTweet = tweet
      self.navigationController?.pushViewController(userVC, animated: true)
    }
  }



}
