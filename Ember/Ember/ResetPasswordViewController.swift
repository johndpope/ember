//
//  ResetPasswordViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 8/20/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailAddressLink: UITextField!
    @IBOutlet weak var backResetButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let image = UIImage(named: "backReset") as UIImage?
        backResetButton.setImage(image, forState: UIControlState.Normal)
        backResetButton.titleEdgeInsets.left = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPasswordLink(sender: AnyObject) {
        let email = self.emailAddressLink.text!
        
        if (email.hasSuffix(".edu") && email.isEmail) {
        FIRAuth.auth()?.sendPasswordResetWithEmail(email) { error in
            if let error = error {
                // An error happened.
                print(error)
            } else {
                // Password reset email sent.
                self.navigationController?.popViewControllerAnimated(true)
                }
            
            }
        } else {
            // User needs to use .edu email address before continuing
            let alertController = UIAlertController(title: "Email address",
                                                    message: "Please use a correct .edu email address only",
                                                    preferredStyle: UIAlertControllerStyle.Alert
            )
            alertController.addAction(UIAlertAction(title: "Gotcha!",
                style: UIAlertActionStyle.Default, handler: nil)
            )
            // Display alert
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }

    @IBAction func backResetButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

