//
//  NetworkController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/8/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation
import Accounts
import Social

class NetworkController {
  
  var twitterAccount : ACAccount?
  var tweets = [Tweet]()
  
  init () {
  }
  
  
  func fetchTweets(forUser handle: String = " ", completionHandler : (errorDescription: String?, tweets: [Tweet]?) -> (Void)) {
    
    let accountStore = ACAccountStore()
    let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error) -> Void in
      if granted {
        
        let accounts = accountStore.accountsWithAccountType(accountType)
        self.twitterAccount = (accounts.first as ACAccount)
        
        var twitterRequest : SLRequest!
        
        if handle != " " {
          let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
          twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["screen_name": handle])
          
          
          } else {
          
            let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
            twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["count":"20"])
          
          }
        
        twitterRequest.account = self.twitterAccount
        
        twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
          
          if error == nil {
            println(httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200...299:
              
              self.tweets = Tweet.parseJSONDataIntoTweets(data)!
              
              completionHandler(errorDescription: nil, tweets: self.tweets)
              println("Worked Just Fine!")
              
            case 400...499:
              
              completionHandler(errorDescription: "An error occured on your end.", tweets: nil)
              println("An error occured on your end.")
              
            case 500...599:
              
              completionHandler(errorDescription: "An error occured on Twitter's end.", tweets: nil)
              println("An error occured on Twitter's end.")
              
            default:
              println("Something bad happened: \(error.description)")
            }
          } else {
            println(error.description)
          }
        })
      }
    }
  }
  
  func fetchImagesForTweet(tweet: Tweet, completionHandler : (errorDescription: String?, images: (UIImage?, UIImage?)) -> (Void)) {
    
    var avatarImage : UIImage?
    var bannerImage : UIImage?
    let bannerString = tweet.bannerString!
    let profileString = tweet.profileString!
    
    if tweet.image == nil {
      let normalRange = profileString.rangeOfString("_normal", options: nil, range: nil, locale: nil)
      let newString = profileString.stringByReplacingCharactersInRange(normalRange!, withString: "_bigger")
      
      let imageURL = NSURL(string: newString)
      
      let data = NSData(contentsOfURL: imageURL)
      
      avatarImage = UIImage(data: data)
    }
    
    if tweet.bannerImage == nil {
      
      let imageURL = NSURL(string: bannerString)
      
      let data = NSData(contentsOfURL: imageURL)
      
      bannerImage = UIImage(data: data)
      
    }
    
    return completionHandler(errorDescription: nil, images: (avatarImage, bannerImage))
    
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
    
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    
  }
  
  func getImageFromURL(url : NSURL) -> UIImage{
    let data = NSData(contentsOfURL: url)
    return UIImage(data: data)
  }
}