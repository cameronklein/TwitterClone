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
  var refreshController : UIRefreshControl!
  var isRefreshing = false
  
  let labelBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
  var initialTweet : Tweet!
  var tweets : [Tweet]?
  var operationsQueue = NSOperationQueue()
  var networkController : NetworkController!
  
  // MARK: - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
    
    var username : String? = nil
  
    
    /* SETUP TABLEVIEW STUFF */
    
    refreshController = UIRefreshControl()
    refreshController.attributedTitle = NSAttributedString(string: "Pull to Refresh")
    refreshController.addTarget(self, action: "reloadFromTop", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshController)
    
    self.tableView.alpha = 0.0
    
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 50.0
    
    self.tableView.registerNib(UINib(nibName: "TimeLineTweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")

    var didSetUsername = false
    
    if initialTweet == nil {
      if let user = networkController.authenticatedUserScreenName {
        username = user
        didSetUsername = true
      }
      else {
        
        let alert = UIAlertController(title: "Oh no!", message: "Unable to identify you. Network error.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "That's cool.", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)

      }
      
      
    } else {
      username = initialTweet.handle!
      self.profileImage.image  = self.initialTweet.image
      self.bannerImage.image   = self.initialTweet.bannerImage
      self.handleLabel.text    = " @" + self.initialTweet.handle! + " "
      self.usernameLabel.text  = " " + self.initialTweet.username!
      self.profileImage.layer.borderColor = UIColor.blackColor().CGColor
      self.profileImage.layer.borderWidth = 2
    }
    if username != nil{
    networkController.fetchTweets(forUser: username!, completionHandler: { (errorDescription, tweets) -> (Void) in
      
      if errorDescription != nil{
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          let alert = UIAlertController(title: "Oops!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        })
      } else {
        if didSetUsername{
          self.networkController.fetchImagesForTweet(tweets![0], completionHandler: { (errorDescription, images) -> (Void) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              self.profileImage.image  = images.0
              self.bannerImage.image   = images.1
              self.handleLabel.text    = " @" + tweets![0].handle! + " "
              self.usernameLabel.text  = " " + tweets![0].username!
              self.profileImage.layer.borderColor = UIColor.blackColor().CGColor
              self.profileImage.layer.borderWidth = 2
            })
          })
        }
        
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.tweets = tweets
        
        self.handleLabel.text    = " @" + tweets![0].handle! + " "
        self.usernameLabel.text  = " " + tweets![0].username!
        self.tableView.reloadData()
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: { () -> Void in
          self.tableView.alpha = 1.0
          self.spinningWheel.alpha = 0.0
          
          }, completion: nil)
        
      })
      }
    })
    } else {
      spinningWheel.stopAnimating()
      
    }
    
    
    
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    profileImage.clipsToBounds = true
    
    
    
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
  
  // MARK - UITableViewDataSource
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL", forIndexPath: indexPath) as TimeLineTweetCell
    
    let tweet = tweets![indexPath.row]
    
    cell.tweetTextLabel.text  = tweet.text
    cell.usernameLabel.text   = " " + tweet.username! + " "
    cell.dateLabel.text       = " " + tweet.readableDate + " "
    cell.retweetLabel.text    = String(tweet.retweetCount)
    cell.favoriteLabel.text   = String(tweet.favoriteCount)
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    
    cell.topBarImage.hidden = true
    cell.usernameLabel.hidden = true
    cell.imageView?.hidden = true
    cell.labelConstraint.constant = -40
    
    return cell
    
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if let tweetArray = tweets {
      return tweetArray.count
    } else {
      return 0
    }
    
  }
  
  //MARK - UITableViewDelegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let destination : SingleTweetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET") as SingleTweetViewController
    
    destination.tweet = self.tweets![indexPath.row]
    
    self.navigationController?.pushViewController(destination, animated: true)
    
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == self.tweets!.count - 10 {
      self.reloadFromBottom()
    }
  }
  
  // MARK - Helper Methods
  
  func reloadFromTop(){
    if self.isRefreshing == false {
      self.isRefreshing == true
      networkController.fetchTweets(forUser: tweets!.first!.handle!, sinceID: tweets!.first!.id, maxID: nil, completionHandler: { (errorDescription, tweets) -> (Void) in
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
      networkController.fetchTweets(forUser: tweets!.first!.handle!, sinceID: nil, maxID: tweets!.last!.id) { (errorDescription, tweets) -> (Void) in
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
