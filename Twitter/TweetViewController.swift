//
//  TweetViewController.swift
//  Twitter
//
//  Created by Cicely Beckford on 2/24/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.becomeFirstResponder()
        tweetTextView.delegate = self
        
        tweetTextView.layer.borderWidth = 1
        tweetTextView.layer.borderColor = UIColor.black.cgColor
        
        loadImage()
        
        

        // Do any additional setup after loading the view.
    }
    
    func loadImage() {
        let myURL = "https://api.twitter.com/1.1/account/verify_credentials.json"
        
        TwitterAPICaller.client?.getDictionaryRequest(url: myURL, parameters: [:], success: { (res: NSDictionary) in
            
            let profileImageURL = URL(string: (res["profile_image_url_https"] as? String)!)
            let imageData = try? Data(contentsOf: profileImageURL!)

            if let profileImageData = imageData {
                self.profileImageView.image = UIImage(data: profileImageData)
            }
            
        }, failure: { (Error) in
            print("Could not retrieve info!")
        })
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweet(_ sender: Any) {
        if (!tweetTextView.text.isEmpty) {
            TwitterAPICaller.client?.postTweet(tweetString: tweetTextView.text, success: {
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print("Error posting tweet \(error)")
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let characterLimit = 140
        let newText = NSString(string: textView.text!).replacingCharacters(in: range, with: text)

        charCountLabel.text = String(characterLimit - newText.count)
        
        return newText.count < characterLimit
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
