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
  
  
  func fetchTweets(forUser handle: String? = nil, sinceID : String? = nil, maxID : String? = nil, completionHandler : (errorDescription: String?, tweets: [Tweet]?) -> (Void)) {
    
    let accountStore = ACAccountStore()
    let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error) -> Void in
      if granted {
        
        let accounts = accountStore.accountsWithAccountType(accountType)
        self.twitterAccount = (accounts.first as ACAccount)
        
        var twitterRequest : SLRequest!
        
        var paramDictionary = [NSObject : AnyObject]()
        var url : NSURL!
        
        paramDictionary["count"] = 50
        if let screenname = handle{
          paramDictionary["screen_name"] = screenname
          url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        } else {
          url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        }
        if let thisSinceID = sinceID{
          paramDictionary["since_id"] = thisSinceID
        }
        if let thisMaxID = maxID{
          paramDictionary["max_id"] = thisMaxID
          println("Request sent with max ID: \(thisMaxID)")
        }
        
        
        twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: paramDictionary)
        

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
    println("Called!")
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
      
      if bannerImage == nil {
        let backupURL = NSURL(string: "http://img4.wikia.nocookie.net/__cb20140603164657/p__/protagonist/images/b/b0/Blue-energy.jpg")
        let backupData = NSData(contentsOfURL: backupURL)
        
        bannerImage = UIImage(data: backupData)
      }
      
    }
    
    return completionHandler(errorDescription: nil, images: (avatarImage, bannerImage))
    
  }
  
}