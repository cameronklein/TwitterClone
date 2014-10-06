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
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let path = NSBundle.mainBundle().pathForResource("tweet", ofType: "json"){
      var error : NSError?
      let jsonData = NSData(contentsOfFile: path)
      
      self.tweets = Tweet.parseJSONDataIntoTweets(jsonData)
      
      
      
    }
    
  }
  
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
    formatter.dateFormat = "EEE, MMM d h:mm a"
    
    cell.tweetTextLabel.text = "\"\(text)\""
    cell.usernameLabel.text = "- \(username!)"
    cell.dateLabel.text = formatter.stringFromDate(timestamp)
    
    cell.tweetTextLabel.backgroundColor = UIColor.whiteColor()
    cell.usernameLabel.backgroundColor = UIColor.whiteColor()
    cell.dateLabel.backgroundColor = UIColor.whiteColor()
    
    if let thisPersonImage = tweet.image{
      cell.imageView?.image = self.getSmallImagefromBigImage(thisPersonImage)
    }
    

    cell.backgroundColor = UIColor(patternImage: self.getRandomBackgroundWithWidth(Int(cell.frame.width), andY: Int(cell.frame.height)))
    
    cell.imageView!.frame = CGRectMake(0.0, 0.0, 80.0, 80.0)
    cell.imageView!.clipsToBounds = true
    cell.imageView!.layer.borderColor = UIColor.blackColor().CGColor
    cell.imageView!.layer.borderWidth = 1
    cell.imageView!.layer.cornerRadius = cell.imageView!.frame.size.height / 2.0
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 100
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  }
  
  func getSmallImagefromBigImage(image: UIImage) -> UIImage{
    
    UIGraphicsBeginImageContext(CGSizeMake(80.0, 80.0))
    
    image.drawInRect(CGRectMake(0.0, 0.0, 80.0, 80.0))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return newImage
    
  }

  @IBAction func sort(sender: UIBarButtonItem) {
    tweets?.sort { $0.text < $1.text }
    tableView.reloadData()
  }
  
  func getRandomBackgroundWithWidth(x: Int, andY y: Int) -> UIImage{
    
    let imageString = "http://lorempixel.com/\(x)/\(y)/"
    let imageURL = NSURL(string: imageString)
    println(imageURL)
    var error : NSError?
    let imageData = NSData(contentsOfURL: imageURL, options: nil, error: &error)
    return UIImage(data: imageData)
    
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
