//
//  Tweet.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/6/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class Tweet {
  
  var text        : String
  var image       : UIImage?
  var username    : String?
  var timestamp   : NSDate
  var background  : UIImage?
  var profileString : String?
  var profileColorString : String?
  var profileColor : UIColor?
  
  let operationsQueue = NSOperationQueue()
  
  init (tweetDictionary : NSDictionary) {
    self.text = tweetDictionary["text"] as String
    let formatter = NSDateFormatter()
    formatter.dateFormat = "E MMM dd HH:mm:ssZ yyyy"
    self.timestamp = formatter.dateFromString(tweetDictionary["created_at"] as String)!
    if let userDictionary = tweetDictionary["user"] as? NSDictionary {
      self.profileString = (userDictionary["profile_image_url"] as String)
      self.username = userDictionary["name"] as String?
      self.profileColorString = userDictionary["profile_sidebar_fill_color"] as String?
    }
  }
  
  func loadImages() {
    
    if image == nil{
      let imageURL = NSURL(string: profileString!)
      var error : NSError?
      let imageData = NSData(contentsOfURL: imageURL, options: nil, error: &error)
      self.image = UIImage(data: imageData)
    }
    
    if profileColor == nil{
      self.profileColor = self.getColorFromHex(profileColorString!)
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
  
  func getColorFromHex(hexString: String) -> UIColor {
    
    let url = NSURL(string: "http://rgb.to/save/json/color/\(hexString)")
    let data = NSData(contentsOfURL: url)
    var error : NSError?
    let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as NSDictionary
    let rgb = json["rgb"] as [String:Int]
    
    let red = CGFloat(rgb["r"]!)/255
    let green = CGFloat(rgb["g"]!)/255
    let blue = CGFloat(rgb["b"]!)/255
    
    println(green)
    
    let myColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    
    println(myColor)
    return myColor
    
    
  }
}