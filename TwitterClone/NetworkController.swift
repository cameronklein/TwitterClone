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
  
  func fetchHomeTimeline(completionHandler : (errorDescription: String?, tweets: [Tweet]?) -> (Void)) {
    
    let accountStore = ACAccountStore()
    let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error) -> Void in
      if granted {
        
        let accounts = accountStore.accountsWithAccountType(accountType)
        self.twitterAccount = (accounts.first as ACAccount)
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["count":"60"])
        twitterRequest.account = self.twitterAccount
        
        twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
          
          if error == nil {
            println(httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200...299:
              
              self.tweets = Tweet.parseJSONDataIntoTweets(data)!
              
              completionHandler(errorDescription: nil, tweets: self.tweets)
 
            case 400...499:
              
              completionHandler(errorDescription: "An error occured on your end.", tweets: nil)
              
            case 500...599:
              
             completionHandler(errorDescription: "An error occured on Twitter's end.", tweets: nil)
              
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
  
  func updateTweet(tweet: Tweet, completionHandler : (errorDescription: String?, data: NSData?) -> (Void)){
    let id = tweet.id
    let accountStore = ACAccountStore()
    let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    var thisData : NSData? = nil
    
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error) -> Void in
      if granted {
        
        let accounts = accountStore.accountsWithAccountType(accountType)
        self.twitterAccount = (accounts.first as ACAccount)
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json")
        let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["id":id])
        twitterRequest.account = self.twitterAccount
        
        twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
          
          if error == nil {
            println("Single Tweet Called!")
            println(httpResponse.statusCode)
            
            switch httpResponse.statusCode {
              
            case 200...299:
              
              completionHandler(errorDescription: nil, data: data)
              
            case 400...499:
              println("Oops")
            case 500...599:
              println("Oops")
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