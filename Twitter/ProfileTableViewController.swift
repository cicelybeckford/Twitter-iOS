//
//  ProfileTableViewController.swift
//  Twitter
//
//  Created by Cicely Beckford on 2/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    
    var tweetArray = [NSDictionary]()
    var userInfo = NSDictionary()
    var numberOfTweet: Int!
    var headerView : UIView!
    var newHeaderLayer : CAShapeLayer!
    var totalTweets:Int!
    
    let headerHeight : CGFloat = 150
    let headerCut : CGFloat = 0
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
        loadTweets()
        updateView()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
    }
       
    func updateView() {
        tableView.backgroundColor = UIColor.white
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.addSubview(headerView)
       
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = newHeaderLayer
       
        let newheight = headerHeight - headerCut / 2
        tableView.contentInset = UIEdgeInsets(top: newheight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newheight)
       
        setupNewView()
    }
    
    func setupNewView() {
        let newheight = headerHeight - headerCut / 2
        var getheaderframe = CGRect(x: 0, y: -newheight, width: tableView.bounds.width, height: headerHeight)
        if tableView.contentOffset.y < newheight
        {
            getheaderframe.origin.y = tableView.contentOffset.y
            getheaderframe.size.height = -tableView.contentOffset.y + headerCut / 2
        }
       
        headerView.frame = getheaderframe
        let cutdirection = UIBezierPath()
        cutdirection.move(to: CGPoint(x: 0, y: 0))
        cutdirection.addLine(to: CGPoint(x: getheaderframe.width, y: 0))
        cutdirection.addLine(to: CGPoint(x: getheaderframe.width, y: getheaderframe.height))
        cutdirection.addLine(to: CGPoint(x: 0, y: getheaderframe.height))
        cutdirection.addLine(to: CGPoint(x: 0, y: headerCut + 5))
        newHeaderLayer.path = cutdirection.cgPath
    }
    
    @objc func loadTweets() {
        numberOfTweet = 20
        
        let myURL = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
            self.myRefreshControl.endRefreshing()
        })
    }
    
    func loadMoreTweets() {
        let myURL = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        
        if ((totalTweets != nil) && (totalTweets > numberOfTweet)) {
            numberOfTweet = numberOfTweet + 20
            let myParams = ["count": numberOfTweet]
            
            TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { (tweets: [NSDictionary]) in
                
                self.tweetArray.removeAll()
                for tweet in tweets {
                    self.tweetArray.append(tweet)
                }
                
                self.tableView.reloadData()
            }, failure: { (Error) in
                print("Could not retrieve tweets!")
            })
        }
    }
    
    func loadUserInfo() {
        let myURL = "https://api.twitter.com/1.1/account/verify_credentials.json"
        
        TwitterAPICaller.client?.getDictionaryRequest(url: myURL, parameters: [:], success: { (res: NSDictionary) in
            self.userNameLabel.text = res["name"] as? String
            self.screenNameLabel.text = "@" + (res["screen_name"] as? String ?? "")
            self.bioLabel.text = res["description"] as? String
            self.followersCountLabel.text = String(res["followers_count"] as! Int)
            self.followingCountLabel.text = String(res["friends_count"] as! Int)
            self.tweetsCountLabel.text = String(res["statuses_count"] as! Int)
            
            self.totalTweets = res["statuses_count"] as? Int
            
            let profileImageURL = URL(string: (res["profile_image_url_https"] as? String)!)
            let imageData = try? Data(contentsOf: profileImageURL!)
            if let profileImageData = imageData {
                self.profileImageView.image = UIImage(data: profileImageData)
            }
            
        }, failure: { (Error) in
            print("Could not retrieve info!")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        cell.userNameLabel.text = user["name"] as? String
        cell.screenNameLabel.text = "@" + (user["screen_name"] as? String ?? "")
        cell.tweetContentLabel.text = tweetArray[indexPath.row]["text"] as? String
        cell.favCountLabel.text = String(tweetArray[indexPath.row]["favorite_count"] as! Int)
        cell.rtCountLabel.text = String(tweetArray[indexPath.row]["retweet_count"] as! Int)
        cell.timeLabel.text = getRelativeTime(timeString: (tweetArray[indexPath.row]["created_at"] as? String)!)
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    func getRelativeTime(timeString: String) -> String {
        let time: Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        time = dateFormatter.date(from: timeString)!
        return time.timeAgoDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        tableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupNewView()
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }
}
