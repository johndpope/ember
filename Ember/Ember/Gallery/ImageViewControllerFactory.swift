//
//  ImageViewControllerFactory.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 06/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewControllerFactory {
    
    private let imageProvider: ImageProvider
    private let displacedView: UIView
    private let imageCount: Int
    private let startIndex: Int
    private var configuration: GalleryConfiguration
    private var fadeInHandler: ImageFadeInHandler
    private weak var delegate: ImageViewControllerDelegate?
    private var homefeedID : NSString?
    
    init(imageProvider: ImageProvider, displacedView: UIView, imageCount: Int, startIndex: Int, configuration: GalleryConfiguration, fadeInHandler: ImageFadeInHandler, delegate: ImageViewControllerDelegate, homefeedID: NSString) {
        
        self.imageProvider = imageProvider
        self.displacedView = displacedView
        self.imageCount = imageCount
        self.startIndex = startIndex

        self.configuration = configuration
        self.fadeInHandler = fadeInHandler
        self.delegate = delegate
        self.homefeedID = homefeedID
    }
    
    func createImageViewController(imageIndex: Int) -> GalleryImageViewController? {
      
        return GalleryImageViewController(imageProvider: imageProvider,  configuration: configuration, imageCount: imageCount, displacedView: displacedView, startIndex: startIndex, imageIndex: imageIndex, showDisplacedImage: (imageIndex == self.startIndex), fadeInHandler: fadeInHandler, delegate: delegate, homefeedID: homefeedID!)
    }
}
