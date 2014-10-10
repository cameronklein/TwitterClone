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
  var lastIndexPath : NSIndexPath?
  var appDelegate : AppDelegate!

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    var footer = UIView()
    
    imageQueue.maxConcurrentOperationCount = 6
    imageQueue.qualityOfService = NSQualityOfService.UserInteractive
    
    //Register tableView cell
    self.tableView.registerNib(UINib(nibName: "TimeLineTweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
    
    // Get NetworkController
    appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
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
          for tweet in tweets!{
            println(tweet.id)
          }
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
      self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  // MARK: - TableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let theseTweets = self.tweets {
      println(theseTweets.count)
      return theseTweets.count
    }
    println("None")
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
    cell.profileImage.layer.borderWidth = 1

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
    cell.profileImage.addNaturalOnTopEffect(maximumRelativeValue: 40.0)
    
    return cell
  }
  
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 150
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row > self.tweets!.count - 7 {
      self.reloadFromBottom()
    }
  }

  func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    self.reloadFromBottom()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    lastIndexPath = indexPath
    let destination : SingleTweetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET") as SingleTweetViewController
    destination.tweet = self.tweets![indexPath.row]
    
    let thisCell : TimeLineTweetCell = self.tableView.cellForRowAtIndexPath(indexPath) as TimeLineTweetCell
    self.navigationController!.pushViewController(destination, animated: true)
    
//    let destinationFrame = destination.view.frame
//    
//    
//    
//    let subViews = thisCell.contentView.subviews as [UIView]
//    thisCell.contentView.frame = self.view.frame
//    
//    for view in subViews {
//      let constraints = view.constraints()
//      view.removeConstraints(constraints)
//      
//      let newCenter = view.convertPoint(view.center, toView: nil)
//      
//      appDelegate.window?.addSubview(view)
//      view.center = newCenter
//      
//    }
//    destination.view.layoutSubviews()
//    
//    
//    
//    
//    let thisProfile = thisCell.profileImage
//    let destProfile = destination.profileImage
//    let originalFrame = destProfile.frame
//    destProfile.frame = thisProfile.convertRect(thisProfile.frame, toView: nil)
//    
//    let thisBar = thisCell.topBarImage
//    let destBar = destination.topBar
//    let originalBarFrame = destBar.frame
//    let barWindowRef = thisBar.convertRect(thisBar.frame, toView: nil)
//    destBar.frame = appDelegate.window!.convertRect(barWindowRef, toView: destination.view)
//    destBar.frame = barWindowRef
//    destBar.frame.origin.y = destBar.frame.origin.y - self.navigationController!.navigationBar.frame.height
//    
//
//    var constant = destination.view.frame.width / destBar.frame.width
//    println(constant)
//    destBar.transform = CGAffineTransformMakeScale(constant, constant)
//    
//    destBar.frame.origin.x = 0.0
//    
//    println(barWindowRef)
//    println(destBar.frame)
//    destination.view.layoutSubviews()
//    
//    
//    UIView.animateWithDuration(1.0,
//      delay: 0.0,
////      usingSpringWithDamping: 0.0,
////      initialSpringVelocity: 0.0,
//      options: nil,
//      animations: { () -> Void in
//        
//        destProfile.frame = originalFrame
//        destBar.frame = originalBarFrame
//      },
//      completion: {success in
//        
//    })
//    
//    
    
    
  }
  

  // MARK: - Helper Methods

  @IBAction func sort(sender: UIBarButtonItem) {
    tweets?.sort { $0.text < $1.text }
    tableView.reloadData()
  }
  
  func reloadFromBottom(){
    println(tweets!.last!.id)
    networkController.fetchTweets(forUser: nil, sinceID: nil, maxID: tweets!.last!.id) { (errorDescription, tweets) -> (Void) in
      for tweet in tweets! {
        self.tweets!.append(tweet)
        println(tweet.id)
      }
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.tableView.reloadData()
        println("New tweets retrieved!")
      })
    }
  }
  
}
