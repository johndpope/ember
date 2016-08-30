//
//  FirebaseUtil.swift
//  Ember
//
//  Created by Gabriel Wamunyu on 8/29/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

@objc public class FirebaseUtil: NSObject {
    
    public static func increaseFireCount(ref : FIRDatabaseReference){
      
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = FIRAuth.auth()?.currentUser?.uid {
                
                if(post.isEmpty){
                    return FIRTransactionResult.successWithValue(currentData)
                }
                var starCount = currentData.value as? Int ?? 0
                starCount += 1
                currentData.setValue(NSNumber(integer: starCount), forKey: "fireCount")
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
}