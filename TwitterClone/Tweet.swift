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
  var username            : String?
  var handle              : String?
  var profileString       : String?
  var mediaString         : String?
  var image               : UIImage?
  var bannerImage         : UIImage?
  var mediaImage          : UIImage?
  var timestamp           : NSDate
  var favoriteCount       : Int
  var retweetCount        : Int
  var bannerString        : String?  = "http://img4.wikia.nocookie.net/__cb20140603164657/p__/protagonist/images/b/b0/Blue-energy.jpg"
  let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
  let operationsQueue = NSOperationQueue()
  
  var readableDate : String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter.stringFromDate(self.timestamp)
  }
  
  // MARK: - Initializer
  
  init (tweetDictionary : NSDictionary) {
    self.text             = tweetDictionary["text"]             as String
    self.id               = tweetDictionary["id_str"]           as String
    self.retweetCount     = tweetDictionary["retweet_count"]    as Int
    self.favoriteCount    = tweetDictionary["favorite_count"]   as Int
    if let userDictionary = tweetDictionary["user"]             as? NSDictionary {
      self.profileString  = userDictionary["profile_image_url"] as? String
      self.username       = userDictionary["name"]              as String?
      self.handle         = userDictionary["screen_name"]       as String?
      if let bannerURL    = userDictionary["profile_banner_url"]   as? String{
        self.bannerString = bannerURL
      }
    }
    if let entitiesDict   = tweetDictionary["entities"]         as? NSDictionary {
      println("Found Entities")
      if let mediaArray    = entitiesDict["media"]              as? NSArray {
        if let mediaDict    = mediaArray[0]                     as? NSDictionary {
          println("Found Media")
          if let mediaURL   = mediaDict["media_url_https"]        as String? {
            self.mediaString  = mediaURL
            println(mediaURL)
          }
        }
      }
    }
    let formatter = NSDateFormatter()
    formatter.dateFormat = "E MMM dd HH:mm:ssZ yyyy"
    self.timestamp = formatter.dateFromString(tweetDictionary["created_at"] as String)!
  }
 
  // MARK - Factory Method
  
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


    