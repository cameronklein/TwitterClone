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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topBar.backgroundColor  = tweet.profileColor
    profileImage.image      = tweet.image
    profileLabel.text       = tweet.username
    dateLabel.text          = tweet.readableDate
    tweetLabel.text         = tweet.text

    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
  
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    networkController.updateTweet(tweet, completionHandler: { (errorDescription, data) -> (Void) in
      self.tweet.updateInfo(data!)
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.retweetLabel.text  = String(self.tweet.retweetCount!)
        self.favoriteLabel.text = String(self.tweet.favoriteCount!)
      })
      
    })
    
    profileImage.clipsToBounds = true
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 3.1
    
    profileImage.layer.borderColor = UIColor.blackColor().CGColor
    profileImage.layer.borderWidth = 2

    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let destination = segue.destinationViewController as HomeTimeLineViewController
    
    if segue.identifier == "Single"{
      let index = destination.tableView.indexPathForSelectedRow()
      destination.tableView.deselectRowAtIndexPath(index!, animated: true)
      destination.tableView.reloadData()
      
    }
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
