//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "LTReJyreyyuz4SWjVABuA1WKI", consumerSecret: "ajf07xfd6869heCG8Ptn8iztfFHBWPIxLkFGvsmoEwI7MKZcz")

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }

    @IBAction func predictPressed(_ sender: Any) {
      
        fetchTweets()
       
    
    }
    
    func fetchTweets() {
       
        if let searchText = textField.text {
            
            let prediction = try! sentimentClassifier.prediction(text: searchText)
            
            print(prediction.label)
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended) { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassifier = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassifier)
                    }
                }
                
                self.tweetPredictions(with: tweets)
            } failure: { (error) in
                print("There was an error with the Twitter API Request, \(error)")
            }

        }
 
    }
    
    func tweetPredictions(with tweets: [TweetSentimentClassifierInput]) {
        
        do {
            
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
                
              updateUI(with: sentimentScore)
                
            }

        } catch {
           print("There was an error with making a prediction \(error)")
        }
        
        print(tweets)
    }
    
    func updateUI(with sentimentScore: Int) {
       
        if sentimentScore > 20 {
            self.sentimentLabel.text = "🥰"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😄"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤢"
        }
        print(sentimentScore)
    }
    
}

