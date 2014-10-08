//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import Accounts
import Social

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var tweets : [Tweet]?
  var twitterAccount : ACAccount?
  var operationsQueue = NSOperationQueue()
  var myLoadView : UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.alpha = 0.0
    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 150.0
    
    
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    myLoadView = UIView(frame: self.view.frame)
    myLoadView.backgroundColor = UIColor.orangeColor()
    
//    self.navigationController!.view.addSubview(myLoadView)
//    self.navigationController!.navigationBar.hidden = true
    
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
    
    let text = tweet.text
    let username = tweet.username
    let timestamp = tweet.timestamp
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM d h:mm a"
    cell.dateLabel.text = formatter.stringFromDate(timestamp)
    
    cell.tweetTextLabel.text = text
    cell.usernameLabel.text = username!
    
    
    
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
  
  func getColorFromHex(hexString: String) -> UIColor {
    
    let url = NSURL(string: "http://rgb.to/save/json/color/\(hexString)")
    
    let data = NSData(contentsOfURL: url)
    
    var error : NSError?
    
    let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as NSDictionary
    
    let rgb = json["rgb"] as [String:Int]
    
    println(CGFloat(rgb["r"]!))
    
    return UIColor(red: CGFloat(rgb["r"]!), green: CGFloat(rgb["g"]!), blue: CGFloat(rgb["b"]!), alpha: 1.0)
    
    
  }
  
}
