//
//  DiscoverViewController.swift
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 7/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import UIKit
import FirebaseAuth

class DiscoverViewController: UIViewController {
    
    @IBOutlet weak var callToAction: UILabel!
    @IBOutlet weak var tagListView: UIView!
    
    @IBOutlet weak var tagsIndicator: UIActivityIndicatorView!
    var newTagListView:TagListView!
    var tagsFromUserObject = [String]()
    var mainTags = [String]()
    var mainSet:Set<String> = Set([])
    var didAppear: Bool = false
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        tagsFromUserObject = []
        mainTags = []
        tagsIndicator.hidesWhenStopped = true;
        tagsIndicator.startAnimating()
        
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
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        self.ref.child(BounceConstants.firebaseSchoolRoot()).child("users").child(userID!).child("preferences").removeValue()
        for item in mainSet {
        self.ref.child(BounceConstants.firebaseSchoolRoot()).child("users").child(userID!).child("preferences").updateChildValues([item:true])
        }
        self.navigationController?.popViewControllerAnimated(true)
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
    
    override func viewDidAppear(animated: Bool) {
        
        if (didAppear == false) {
           
        // Do any additional setup after loading the view.
        newTagListView = TagListView(frame: CGRectMake(0, tagListView.frame.minY , tagListView.frame.size.width,tagListView.frame.size.height))
        self.view.addSubview(newTagListView)
        newTagListView.backgroundColor = UIColor.whiteColor()
        newTagListView.layer.borderColor = UIColor.whiteColor().CGColor
        newTagListView.layer.borderWidth = 0.2
            
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let mainTagsQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("orgTags").queryLimitedToFirst(50)
            
        let tagsFromUserObjectQuery = self.ref.child(BounceConstants.firebaseSchoolRoot()).child("users").child(userID!).child("preferences").queryLimitedToFirst(50)
            
        tagsFromUserObjectQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
                for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    self.tagsFromUserObject.append(rest.key)
                }
            
        mainTagsQuery.queryOrderedByKey().observeSingleEventOfType(FIRDataEventType.Value, withBlock: {(snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.mainTags.append(rest.value as! String)
            }
            
            //Assign downloaded array of tags from org object into a set
            let set1:Set<String> = Set(self.mainTags)
            
            //Isolate tags that are not selected by user
            let validTags = set1.subtract(self.tagsFromUserObject)
            
            //Add them to the TagListView
            for (index,i) in validTags.enumerate()
            {let color:UIColor!
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
                
                self.newTagListView.addTag(i, target: self, tapAction: #selector(DiscoverViewController.tap(_:)),backgroundColor: color,textColor: UIColor.whiteColor())
            }
            for (index,i) in self.tagsFromUserObject.enumerate()
            { let color = UIColor.lightGrayColor()
                self.mainSet.insert(self.tagsFromUserObject[index])
                self.newTagListView.addTag(i, target: self, tapAction: #selector(DiscoverViewController.tap(_:)),backgroundColor: color,textColor: UIColor.whiteColor())
            }
             self.tagsIndicator.stopAnimating()
            
            self.didAppear = true
                })
            
        })
        self.extendedLayoutIncludesOpaqueBars = false;
        } else  {
            //nothing to do
        }
        
        
    }
  
}

