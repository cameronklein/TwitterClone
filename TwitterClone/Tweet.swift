//
//  Tweet.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class Tweet {
  
  var id          : String
  var text        : String
  var image       : UIImage?
  var username    : String?
  var timestamp   : NSDate
  var background  : UIImage?
  var profileString : String?
  var profileColorString : String?
  var profileColor : UIColor?
  var favoriteCount : Int?
  var retweetCount: Int?
  
  var readableDate : String {
    
    let formatter = NSDateFormatter()
//    formatter.dateFormat = "MM d h:mm a"
    formatter.dateFormat = "h:mm a"
    return formatter.stringFromDate(self.timestamp)
      
  }
  
  
  let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
  let operationsQueue = NSOperationQueue()
  
  init (tweetDictionary : NSDictionary) {
    self.text = tweetDictionary["text"] as String
    self.id = tweetDictionary["id_str"] as String
    let formatter = NSDateFormatter()
    formatter.dateFormat = "E MMM dd HH:mm:ssZ yyyy"
    self.timestamp = formatter.dateFromString(tweetDictionary["created_at"] as String)!
    self.retweetCount = tweetDictionary["retweet_count"] as? Int
    self.favoriteCount = tweetDictionary["favourites_count"] as? Int
    if let userDictionary = tweetDictionary["user"] as? NSDictionary {
      self.profileString = (userDictionary["profile_image_url"] as String)
      self.username = userDictionary["name"] as String?
      self.profileColorString = userDictionary["profile_sidebar_fill_color"] as String?
    }
  }
  
  func loadImages() {
    
    let networkController = appDelegate.networkController
    
    if image == nil{

      let normalRange = profileString?.rangeOfString("_normal", options: nil, range: nil, locale: nil)
      let newString = profileString?.stringByReplacingCharactersInRange(normalRange!, withString: "_bigger")

      let imageURL = NSURL(string: newString!)
      self.image = networkController.getImageFromURL(imageURL)
    }
    
    if profileColor == nil{
      self.profileColor = networkController.getColorFromHex(profileColorString!)
    }
    
  }
 
  class func parseJSONDataIntoTweets(rawJSONData : NSData) -> [Tweet]? {
    var error : NSError?
    
    if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray {
      var tweets = [Tweet]()
      
      for JSONDictionary in JSONArray {
        if let tweetDictionary = JSONDictionary as? NSDictionary {
          var newTweet = Tweet(tweetDictionary: tweetDictionary)
          tweets.append(newTweet)

        }
      }
      println("\(tweets.count) tweets created.")
      return tweets
    }
    return nil
  }
  
  func updateInfo(data: NSData){
    
      var error : NSError?
      if let tweetDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary {
        println("Success!")
        self.favoriteCount = (tweetDictionary["favorite_count"] as Int)
        self.retweetCount = (tweetDictionary["retweet_count"] as Int)
        println(tweetDictionary)
        println(self.retweetCount!)
        println(self.favoriteCount!)

      }

}
}

    