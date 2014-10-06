//
//  Tweet.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class Tweet {
  
  var text : String
  var image : UIImage?
  var username : String?
  var timestamp : NSDate
  
  init (tweetDictionary : NSDictionary) {
    self.text = tweetDictionary["text"] as String
    let formatter = NSDateFormatter()
    formatter.dateFormat = "E MMM dd HH:mm:ssZ yyyy"
    self.timestamp = formatter.dateFromString(tweetDictionary["created_at"] as String)!
    if let userDictionary = tweetDictionary["user"] as? NSDictionary {
      var imageString = userDictionary["profile_image_url"] as String
      imageString = "http://lorempixel.com/100/100/"
      let imageURL = NSURL(string: imageString)
      println(imageURL)
      var error : NSError?
      let imageData = NSData(contentsOfURL: imageURL, options: nil, error: &error)
      println(error)
      println(imageData)
      self.image = UIImage(data: imageData)
      
      self.username = userDictionary["name"] as String?
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
      return tweets
    }
    return nil
  }
}