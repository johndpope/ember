//
//  VideoSplashViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/3/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import AVFoundation



class VideoSplashViewController: UIViewController {
    
    
    var player: AVPlayer?
   
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let path = NSBundle.mainBundle().pathForResource("BackgroundVideo", ofType: "mp4")
        player = AVPlayer(URL: NSURL(fileURLWithPath: path!))
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(playerLayer, atIndex: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoSplashViewController.playerItemDidReachEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: player!.currentItem)
        player?.muted = true
        player!.seekToTime(kCMTimeZero)
        player!.play()
        
         let borderAlpha : CGFloat = 0.7
        
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.layer.cornerRadius = 4
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        
        signUpButton.backgroundColor = UIColor.clearColor()
        signUpButton.layer.cornerRadius = 4
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -10
        verticalMotionEffect.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -10
        horizontalMotionEffect.maximumRelativeValue = 10
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        self.view.addMotionEffect(group)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(VideoSplashViewController.playVideo), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
   
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)

    }
    
    func playVideo() {
        player!.play()
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player!.seekToTime(kCMTimeZero)
    }
    
    @IBAction func signInSelect(sender: AnyObject) {
        
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainLogInViewController") as UIViewController
        let navController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navController, animated: true, completion: nil)
        
    }

    @IBAction func signUpSelect(sender: AnyObject) {
        
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUpViewController") as UIViewController
        let navController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

}
