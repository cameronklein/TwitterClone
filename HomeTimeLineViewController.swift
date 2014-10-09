//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var tweets : [Tweet]?
  var operationsQueue = NSOperationQueue()
  var networkController : NetworkController!
  var lastIndexPath : NSIndexPath?
  
  let labelBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Register tableView cell
    self.tableView.registerNib(UINib(nibName: "TimeLineTweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
    
    // Get NetworkController
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
    
    // Set up auto sizing
    self.tableView.alpha = 0.0
    
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 150.0
    
    // Fetch timeline and handle request
    self.networkController.fetchTweets (completionHandler: { (errorDescription, tweets) -> Void in
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
          UIView.animateWithDuration(1.0, delay: 0.5, options: nil, animations: { () -> Void in
            self.tableView.alpha = 1.0
            self.spinningWheel.alpha = 0.0
            
          }, completion: nil)
          
        })
      }
    })
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPath = lastIndexPath{
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - TableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let theseTweets = self.tweets {
      return theseTweets.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL", forIndexPath: indexPath) as TimeLineTweetCell
    
    let tweet = self.tweets![indexPath.row]
    
    cell.tweetTextLabel.text  = tweet.text
    cell.usernameLabel.text   = " " + tweet.username! + " "
    cell.dateLabel.text       = " " + tweet.readableDate + " "
    cell.retweetLabel.text    = String(tweet.retweetCount!)
    cell.favoriteLabel.text   = String(tweet.favoriteCount!)
    
    cell.usernameLabel.backgroundColor = labelBackgroundColor
    cell.usernameLabel.layer.cornerRadius = 4
    cell.usernameLabel.clipsToBounds = true
    
    cell.dateLabel.backgroundColor = labelBackgroundColor
    cell.dateLabel.layer.cornerRadius = 4
    cell.dateLabel.clipsToBounds = true
    
    cell.profileImage.clipsToBounds = true
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2.0
    
    cell.profileImage.layer.borderColor = UIColor.blackColor().CGColor
    cell.profileImage.layer.borderWidth = 1

    operationsQueue.addOperationWithBlock { () -> Void in
      
      if tweet.image == nil || tweet.bannerImage == nil {

        self.networkController.fetchImagesForTweet(tweet, completionHandler: { (errorDescription, images) -> (Void) in
          if tweet.image == nil {
            tweet.image = images.0
          }
          
          if tweet.bannerImage == nil{
            tweet.bannerImage = images.1
          }
          
        })
      }
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        cell.profileImage.image = tweet.image
        cell.topBarImage.image = tweet.bannerImage
        
        
        
      })
    }
    return cell
  }
  
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 150
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    lastIndexPath = indexPath
    
    let destination : SingleTweetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET") as SingleTweetViewController
    
    destination.tweet = self.tweets![indexPath.row]
    
    self.navigationController?.pushViewController(destination, animated: true)
    
  }
  

  // MARK: - Helper Methods

  @IBAction func sort(sender: UIBarButtonItem) {
    tweets?.sort { $0.text < $1.text }
    tableView.reloadData()
  }
  
  func getRandomBackgroundWithWidth(x: Int, andHeight y: Int) -> UIImage{
    
    let imageString = "http://lorempixel.com/\(x)/\(y)/"
    let imageURL = NSURL(string: imageString)
    var error : NSError?
    let imageData = NSData(contentsOfURL: imageURL, options: nil, error: &error)
    let newImage = UIImage(data: imageData)
    
    return newImage
    
  }
  
}
