//
//  TweetCellTableViewCell.swift
//  Twitter
//
//  Created by Cicely Beckford on 2/17/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var rtButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    @IBOutlet weak var rtCountLabel: UILabel!
    
    var favorited:Bool = false
    var tweetId:Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFavorite(_ isFavorited:Bool) {
        favorited = isFavorited
        if (favorited) {
            favButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
        } else {
            favButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
        }
    }
    
    func setRetweeted(_ isRetweeted:Bool) {
        if (isRetweeted) {
            rtButton.setImage(UIImage(named: "retweet-icon-green"), for: UIControl.State.normal)
            rtButton.isEnabled = false
        } else {
            rtButton.setImage(UIImage(named: "retweet-icon"), for: UIControl.State.normal)
            rtButton.isEnabled = true
        }
    }
    
    @IBAction func favoriteTweet(_ sender: Any) {
        let toBeFavorited = !favorited
        if (toBeFavorited) {
            TwitterAPICaller.client?.favoriteTweet(tweetId: tweetId, success: {
                self.setFavorite(true)
                self.favCountLabel.text = String(Int(self.favCountLabel.text!)! + 1)
            }, failure: { (error) in
                print("Favorite did not succeed: \(error)")
            })
        } else {
            TwitterAPICaller.client?.unfavoriteTweet(tweetId: tweetId, success: {
                self.setFavorite(false)
                if (Int(self.favCountLabel.text!)! > 0) {
                    self.favCountLabel.text = String(Int(self.favCountLabel.text!)! - 1)
                }
            }, failure: { (error) in
                print("Unfavorite did not succeed: \(error)")
            })
        }
    }
    
    @IBAction func retweetTweet(_ sender: Any) {
        TwitterAPICaller.client?.retweetTweet(tweetId: tweetId, success: {
            self.setRetweeted(true)
            self.rtCountLabel.text = String(Int(self.rtCountLabel.text!)! + 1)
        }, failure: { (error) in
            print("Error retweeting: \(error)")
        })
    }
    
}
