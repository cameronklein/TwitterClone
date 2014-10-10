//
//  Tweet.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class Tweet {
  
  var id                  : String
  var text                : String
  var image               : UIImage?
  var username            : String?
  var timestamp           : NSDate
  var background          : UIImage?
  var profileString       : String?
  var profileColorString  : String?
  var profileColor        : UIColor?
  var favoriteCount       : Int?
  var retweetCount        : Int?
  var bannerString        : String?  = "http://img4.wikia.nocookie.net/__cb20140603164657/p__/protagonist/images/b/b0/Blue-energy.jpg"
  var bannerImage         : UIImage?
  var handle              : String?
  
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
    self.favoriteCount = tweetDictionary["favorite_count"] as? Int
    if let userDictionary = tweetDictionary["user"] as? NSDictionary {
      self.profileString = (userDictionary["profile_image_url"] as String)
      self.username = userDictionary["name"] as String?
      self.profileColorString = userDictionary["profile_sidebar_fill_color"] as String?
      self.handle = userDictionary["screen_name"] as String?
      
      if let bannerURL = userDictionary["profile_banner_url"] as? String{
        self.bannerString = bannerURL
      }
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

}


    