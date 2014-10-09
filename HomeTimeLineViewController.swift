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

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.networkController = appDelegate.networkController
    
    self.tableView.alpha = 0.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 150.0
    
    self.networkController.fetchHomeTimeline { (errorDescription, tweets) -> Void in
      if errorDescription != nil{
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          let alert = UIAlertController(title: "Oops!", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        })
      } else {
        
        self.tweets = tweets
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          self.tableView.reloadData()
          UIView.animateWithDuration(1.0, delay: 1.0, options: nil, animations: { () -> Void in
            self.tableView.alpha = 1.0
            self.spinningWheel.stopAnimating()
            
          }, completion: nil)
          
        })
      }
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let index = tableView.indexPathForSelectedRow()
    
    if segue.identifier == "Single" {
      let destination = segue.destinationViewController as SingleTweetViewController
      destination.tweet = tweets![index!.row]
      
    }
    
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
    
    cell.tweetTextLabel.text = tweet.text
    cell.usernameLabel.text = tweet.username!
    cell.dateLabel.text = tweet.readableDate
    
    
    operationsQueue.addOperationWithBlock { () -> Void in
      
      tweet.loadImages()
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        cell.profileImage.image = tweet.image
        
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2.0
        
        cell.profileImage.layer.borderColor = UIColor.blackColor().CGColor
        cell.profileImage.layer.borderWidth = 2
        
        cell.topBarImage.backgroundColor = tweet.profileColor!
      })
      
    }
    
    return cell
    
  }
  
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 150
  }
  

  // MARK: - Helper Methods

  @IBAction func sort(sender: UIBarButtonItem) {
    tweets?.sort { $0.text < $1.text }
    tableView.reloadData()
  }
  
  func getRandomBackgroundWithWidth(x: Int, andHeight y: Int) -> UIImage{
    
    let imageString = "http://lorempixel.com/\(x)/\(y)/"
    let imageURL = NSURL(string: imageString)
    println(imageURL)
    var error : NSError?
    let imageData = NSData(contentsOfURL: imageURL, options: nil, error: &error)
    let newImage = UIImage(data: imageData)
    
    return newImage
    
  }
  
}
