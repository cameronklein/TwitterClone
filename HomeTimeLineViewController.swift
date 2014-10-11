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
  var imageQueue = NSOperationQueue()
  var networkController : NetworkController!
  var appDelegate : AppDelegate!
  var isRefreshing = false
  var refreshController : UIRefreshControl!

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /* SETUP TABLEVIEW STUFF */
    
    refreshController = UIRefreshControl()
    refreshController.attributedTitle = NSAttributedString(string: "Pull to Refresh")
    refreshController.addTarget(self, action: "reloadFromTop", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshController)
    
    self.tableView.registerNib(UINib(nibName: "TimeLineTweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
    
    self.tableView.alpha = 0.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 150.0
    
    /* GET DATA */
    
    appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
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
          UIView.animateWithDuration(1.0, delay: 1.0, options: nil, animations: { () -> Void in
            self.tableView.alpha = 1.0
            self.spinningWheel.alpha = 0.0
          }, completion: nil)
        })
      }
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    networkController.cache.removeAll(keepCapacity: false)
    println("Memory Warning!!!")
  }
  
  // MARK: - UITableViewDataSource
  
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
    cell.retweetLabel.text    = String(tweet.retweetCount)
    cell.favoriteLabel.text   = String(tweet.favoriteCount)
    
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    
    func setUpBackgroundForLabel(label: UILabel){
      let labelBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
      label.backgroundColor = labelBackgroundColor
      cell.usernameLabel.layer.cornerRadius = 4
      cell.usernameLabel.clipsToBounds = true
    }
    
    setUpBackgroundForLabel(cell.usernameLabel)
    setUpBackgroundForLabel(cell.dateLabel)
    
    cell.profileImage.clipsToBounds = true
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2.0
    
    cell.profileImage.layer.borderColor = UIColor.blackColor().CGColor
    cell.profileImage.layer.borderWidth = 2

    imageQueue.addOperationWithBlock { () -> Void in
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
  
  // MARK: - UITableViewDelegate
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == self.tweets!.count - 10 {
      self.reloadFromBottom()
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let destination : SingleTweetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET") as SingleTweetViewController
    destination.tweet = self.tweets![indexPath.row]
    self.navigationController!.pushViewController(destination, animated: true)
  }
  
  // MARK: - Helper Methods
  
  func reloadFromTop(){
    if self.isRefreshing == false {
      self.isRefreshing == true
      networkController.fetchTweets(forUser: nil, sinceID: tweets!.first!.id, maxID: nil, completionHandler: { (errorDescription, tweets) -> (Void) in
        for tweet in tweets! {
          self.tweets!.insert(tweet, atIndex: 0)
        }
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          self.tableView.reloadData()
          println("New tweets retrieved from top!")
          self.isRefreshing = false
          self.refreshController.endRefreshing()
        })
      })
    }
  }
  
  func reloadFromBottom(){
    println("Reloading from bottom")

    if self.isRefreshing == false{
      self.isRefreshing == true
    networkController.fetchTweets(forUser: nil, sinceID: nil, maxID: tweets!.last!.id) { (errorDescription, tweets) -> (Void) in
      if errorDescription != nil{
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          let alert = UIAlertController(title: "Error \(errorDescription)", message: "Loading backup tweets from bundle instead.", preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "That's cool.", style: UIAlertActionStyle.Cancel, handler: nil)
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        })
      } else {
      for tweet in tweets! {
        self.tweets!.append(tweet)
      }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.tableView.reloadData()
        println("New tweets retrieved from bottom!")
        self.isRefreshing = false
      })
    }
    }
  }
  }
  
}
