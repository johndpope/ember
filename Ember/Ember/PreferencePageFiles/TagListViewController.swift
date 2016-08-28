//
//  TagListViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class TagListViewController: UIViewController {

var newTagListView:TagListView!
var prefTags = [String]()
var individualInterests = [String]()
var mainSet:Set<String> = Set([])


    
    @IBOutlet weak var tagListView: UIView!
    @IBOutlet weak var callToAction: UILabel!
    @IBOutlet weak var loadingPreferences: UIActivityIndicatorView!
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        prefTags = []
        
        individualInterests = []
  
        // Do any additional setup after loading the view.
        
        loadingPreferences.hidesWhenStopped = true;
        loadingPreferences.hidden  = false
        loadingPreferences.startAnimating()

        newTagListView = TagListView(frame: CGRectMake(0, tagListView.frame.minY , self.view.frame.size.width,tagListView.frame.size.height))
        self.view.addSubview(newTagListView)
        newTagListView.backgroundColor = UIColor.whiteColor()
        newTagListView.layer.borderColor = UIColor.whiteColor().CGColor
        newTagListView.layer.borderWidth = 0.2
        
        //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tap(sender:UITapGestureRecognizer)
    {
        let label = (sender.view as! UILabel)
        let textToInsert = label.text!
        
        if(label.backgroundColor != UIColor.lightGrayColor()) {
            mainSet.insert(textToInsert)
            label.backgroundColor = UIColor.lightGrayColor()
        } else {
            mainSet.remove(textToInsert)
            label.backgroundColor = getRandomColor()
        }

    }
    @IBAction func preferencesDone(sender: AnyObject) {
        if !(mainSet.isEmpty) {
        let preferences = mainSet
            let userID = FIRAuth.auth()?.currentUser?.uid
    
        for object in preferences {
            self.ref.child(BounceConstants.firebaseSchoolRoot()).child("users").child(userID!).child("preferences").updateChildValues([object:true])
            
        }
    
        self.performSegueWithIdentifier("completePreferences", sender: nil)
        }
        else {
            let alertController = UIAlertController(title: "Hi :)", message:
                "Please pick some tags for us to better understand what you'd like to see.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Explore"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: PRIMARY_APP_COLOR,NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 25)!]
        
        let orgTagsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("orgTags").queryLimitedToFirst(100)
        
        orgTagsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.prefTags.append(rest.value as! String)
            }
            
            
            for (index,i) in self.prefTags.enumerate()
            {
                let color:UIColor!
                if index%4 == 1
                {
                    color = UIColor(red: 238/255, green: 101/255, blue: 107/255, alpha: 1)
                }
                else if index%4 == 2
                {
                    color = UIColor(red: 96/255, green: 95/255, blue: 132/255, alpha: 1)
                }
                else if index%4 == 3
                {
                    color = UIColor(red: 85/255, green: 152/255, blue: 158/255, alpha: 1)
                }
                else
                {
                    color = UIColor(red: 184/255, green: 205/255, blue: 158/255, alpha: 1)
                }
                self.newTagListView.addTag(i, target: self, tapAction: #selector(TagListViewController.tap(_:)),backgroundColor: color,textColor: UIColor.whiteColor())
            }
        })
        loadingPreferences.stopAnimating()

    }
    
    //Method to ensure you have deselected.
    func getRandomColor() -> UIColor  {
        let randomNumber = Int(arc4random_uniform(5) + 1)
        let color:UIColor!
        if randomNumber == 1
        {
            color = UIColor(red: 238/255, green: 101/255, blue: 107/255, alpha: 1)
        }
        else if randomNumber == 2
        {
            color = UIColor(red: 96/255, green: 95/255, blue: 132/255, alpha: 1)
        }
        else if randomNumber == 3
        {
            color = UIColor(red: 85/255, green: 152/255, blue: 158/255, alpha: 1)
        }
        else
        {
            color = UIColor(red: 184/255, green: 205/255, blue: 158/255, alpha: 1)
        }
        return color
        
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
