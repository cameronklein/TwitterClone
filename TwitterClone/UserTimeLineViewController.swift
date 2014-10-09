//
//  UserTimeLineViewController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/9/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class UserTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var handleLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var bannerImage: UIImageView!
  @IBOutlet weak var profileImage: UIImageView!
  
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  
  let labelBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
  
  var lastIndexPath : NSIndexPath?
  
  var initialTweet : Tweet!
  
  var tweets : [Tweet]?
  
  var operationsQueue = NSOperationQueue()
  var networkController : NetworkController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
    
    self.tableView.alpha = 0.0
    
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 150.0
    
    self.tableView.registerNib(UINib(nibName: "TimeLineTweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
    
    self.handleLabel.text    = " @" + initialTweet.handle! + " "
    self.usernameLabel.text  = " " + initialTweet.username!
    self.bannerImage.image   = initialTweet.bannerImage
    self.profileImage.image  = initialTweet.image

    networkController.fetchTweets(forUser: initialTweet.handle!, completionHandler: { (errorDescription, tweets) -> (Void) in
      
      if errorDescription != nil{
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          let alert = UIAlertController(title: "Oops!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        })
      } else {
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.tweets = tweets
        self.tableView.reloadData()
        UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: { () -> Void in
          self.tableView.alpha = 1.0
          self.spinningWheel.alpha = 0.0
          
          }, completion: nil)
        
      })
      }
    })
    
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPath = lastIndexPath{
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    profileImage.clipsToBounds = true
    
    profileImage.layer.borderColor = UIColor.blackColor().CGColor
    profileImage.layer.borderWidth = 2
    
    usernameLabel.backgroundColor = labelBackgroundColor
    usernameLabel.layer.cornerRadius = 4
    usernameLabel.clipsToBounds = true
    
    handleLabel.backgroundColor = labelBackgroundColor
    handleLabel.layer.cornerRadius = 4
    handleLabel.clipsToBounds = true

  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL", forIndexPath: indexPath) as TimeLineTweetCell
    
    let tweet = tweets![indexPath.row]
    
    cell.tweetTextLabel.text  = tweet.text
    cell.usernameLabel.text   = " " + tweet.username! + " "
    cell.dateLabel.text       = " " + tweet.readableDate + " "
    cell.retweetLabel.text    = String(tweet.retweetCount!)
    cell.favoriteLabel.text   = String(tweet.favoriteCount!)
    
    cell.usernameLabel.layer.cornerRadius = 4
    cell.usernameLabel.clipsToBounds = true
    
    cell.dateLabel.layer.cornerRadius = 4
    cell.dateLabel.clipsToBounds = true
    
    cell.topBarImage.removeFromSuperview()
    cell.usernameLabel.removeFromSuperview()
//    cell.dateLabel.removeFromSuperview()
    cell.imageView?.removeFromSuperview()
    cell.labelConstraint.constant = -60
    
    return cell
    
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let tweetArray = tweets {
      return tweetArray.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    self.lastIndexPath = indexPath
    
    let destination : SingleTweetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET") as SingleTweetViewController
    
    destination.tweet = self.tweets![indexPath.row]
    
    self.navigationController?.pushViewController(destination, animated: true)
    
  }
  


}
