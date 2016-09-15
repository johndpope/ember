//
//  GalleryImageProvider.swift
//  bounceapp
//
//  Created by Gabriel Wamunyu on 7/12/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

@objc public class GalleryImageProvider: NSObject, ImageProvider {
    
    let one = NSURL.init(string: "https://files.parsetfss.com/8a8a3b0c-619e-4e4d-b1d5-1b5ba9bf2b42/tfss-3045b261-7e93-4492-b7e5-5d6358376c9f-editedLiveAndDie.mov")
    var imageUrl : NSURL = NSURL()
    var array : NSArray = []
    
    public func provideImage(completion: NSURL? -> Void) {
        completion(one)
    }
    
    func setImage(sentImageUrl : NSURL){
        self.imageUrl = sentImageUrl
    }
    
    func setUrls(arr : NSArray){
        self.array = arr
    }
    
    public func provideImage(atIndex index: Int, completion: NSDictionary? -> Void) {
        let mediaDict = array.objectAtIndex(index) as! NSDictionary
//        let mediaLink = mediaDict.objectForKey("mediaLink") as! String
        
        completion(mediaDict)
    }
}
