//
//  VideoViewController.m
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/26/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import "VideoViewController.h"
#import "SDAVAssetExportSession.h"
#import "Ember-Swift.h"
#import <QuartzCore/QuartzCore.h>
#import "M13ProgressViewSegmentedBar.h"


@import AVFoundation;
@import AssetsLibrary;
@import MobileCoreServices;
@import Firebase;



@interface VideoViewController ()
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) NSURL *uploadUrl;
@property (strong, nonatomic) NSString*myPathDocs;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *acceptButton;
@property (nonatomic, retain) UITextView *captionInput;
@property (strong, nonatomic) UIButton *captionButton;
@property (strong, nonatomic) FIRDatabaseReference *ref;


//Progress Bar setup
@property (nonatomic, retain) M13ProgressViewSegmentedBar *progressView;


//Segue from CameraViewController
@property (strong, nonatomic) NSString *mEventName;
@property (strong, nonatomic) NSString *mEventID;
@property (strong, nonatomic) NSString *mEventDate;
@property (strong, nonatomic) NSString *mEventTime;
@property (strong, nonatomic) NSString *mOrgID;
@property (strong, nonatomic) NSString *mHomeFeedMediaKey;
@property (strong, nonatomic) NSString *mOrgProfImage;
@property (strong, nonatomic) NSNumber *mEventDateObject;

@end



@implementation VideoViewController

- (instancetype)initWithVideoUrl:(NSURL *)url mEventID:(NSString *) eventID mEventDate:(NSString *) eventDate mEventName:(NSString *) eventName mEventTime:(NSString *) eventTime mOrgID:(NSString *) orgID mHomefeedMediaKey:(NSString *) homeFeedMediaKey mOrgProfImage:(NSString *) orgProfImage mEventDateObject:(NSNumber *) eventDateObject {
    self = [super init];
    if(self) {
        _videoUrl = url;
        _uploadUrl = [NSURL fileURLWithPath:
                            [NSTemporaryDirectory()
                             stringByAppendingPathComponent:@"temporaryPreview.mov"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:_uploadUrl.path  error:NULL];
        [self compressVideo:_videoUrl outputURL:_uploadUrl handler:^(AVAssetExportSession *completion) {
            if (completion.status == AVAssetExportSessionStatusCompleted) {
            }
        }];
        _mEventName = eventName;
        _mEventID = eventID;
        _mEventDate = eventDate;
        _mEventTime = eventTime;
        _mOrgID = orgID;
        _mHomeFeedMediaKey = homeFeedMediaKey;
        _mOrgProfImage = orgProfImage;
        _mEventDateObject = eventDateObject;
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
    // Register notification when the keyboard will be shown
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    // the video player
    self.avPlayer = [AVPlayer playerWithURL:self.videoUrl];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.avPlayerLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    [self.view.layer addSublayer:self.avPlayerLayer];
    
    // cancel button
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.frame = CGRectMake(0, 0, 60, 60);
    
     CGPoint leftPoint = CGPointMake(screenRect.size.width * 0.10, screenRect.size.height * 0.935);
    
    self.cancelButton.center = leftPoint;
    [self.view addSubview:self.cancelButton];
    
    

    
    // accept button
    [self.acceptButton addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.acceptButton.frame = CGRectMake(0,0, 60, 60);
    CGPoint rightPoint = CGPointMake(screenRect.size.width * 0.90, screenRect.size.height * 0.935);
    
    self.acceptButton.center = rightPoint;
    [self.view addSubview:self.acceptButton];

    
    //caption Button
    [self.captionButton addTarget:self action:@selector(captionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.captionButton.frame = CGRectMake(0, 0, 60, 60);
    //Bottom Centre
    CGPoint bottomCentre = CGPointMake(screenRect.size.width/2.0, screenRect.size.height * 0.935);
    self.captionButton.center = bottomCentre;
    
    [self.view addSubview:self.captionButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //Firebase connection
    self.ref = [[FIRDatabase database] reference];
    
    
    // Create the progress view.
    _progressView = [[M13ProgressViewSegmentedBar alloc] initWithFrame:CGRectMake(0.0, screenRect.size.height * 0.985, self.view.frame.size.width, 8.0)];
    
    
    // Configure the progress view here.
    
    [_progressView setSegmentShape:M13ProgressViewSegmentedBarSegmentShapeCircle];
    
//    NSArray *foregroundColors = @[[UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.96 blue:0.32 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.96 blue:0.32 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.96 blue:0.32 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.96 blue:0.32 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.12 blue:0.12 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.12 blue:0.12 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.12 blue:0.12 alpha:1],
//                                  [UIColor colorWithRed:1 green:0.12 blue:0.12 alpha:1]];

    
    _progressView.primaryColor = [UIColor colorWithRed:0.12 green:0.98 blue:0.33 alpha:1];
    _progressView.secondaryColor = [UIColor colorWithRed:0.07 green:0.44 blue:0.14 alpha:0];
    
    
    // Add it to the view.
    [self.view addSubview: _progressView];
    
    
    


}


- (void)viewTapped:(UIGestureRecognizer *)gesture {
    
    if(!(self.captionInput.isHidden)) {
        if (![self.captionInput.text  isEqual: @""]) {
    [self.view endEditing:YES];
    self.captionInput.textAlignment = NSTextAlignmentCenter;
        } else {
        [self.view endEditing:YES];
        [self.captionInput removeFromSuperview];
        }
    }
}

- (UIButton *)acceptButton {
    if(!_acceptButton) {
        UIImage *acceptImage = [UIImage imageNamed:@"paper_plane"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor whiteColor];
        [button setImage:acceptImage forState:UIControlStateNormal];
        button.imageView.clipsToBounds = NO;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        button.contentMode = UIViewContentModeScaleToFill;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        button.layer.shadowOpacity = 0.9f;
        button.layer.shadowRadius = 4.0f;
        button.clipsToBounds = NO;
        
        _acceptButton = button;
    }
    
    return _acceptButton;
}
- (UIButton *)cancelButton {
    if(!_cancelButton) {
        UIImage *cancelImage = [UIImage imageNamed:@"undo"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor whiteColor];
        [button setImage:cancelImage forState:UIControlStateNormal];
        button.imageView.clipsToBounds = NO;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        button.layer.shadowOpacity = 0.9f;
        button.layer.shadowRadius = 4.0f;
        button.clipsToBounds = NO;
        _cancelButton = button;
    }
    
    return _cancelButton;
}

- (UIButton *)captionButton {
    if(!_captionButton) {
        UIImage *acceptImage = [UIImage imageNamed:@"comments"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor whiteColor];
        [button setImage:acceptImage forState:UIControlStateNormal];
        button.imageView.clipsToBounds = NO;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        button.contentMode = UIViewContentModeScaleToFill;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        button.layer.shadowOpacity = 0.9f;
        button.layer.shadowRadius = 4.0f;
        button.clipsToBounds = NO;
        
        _captionButton = button;
    }
    
    return _captionButton;
}
- (void)captionButtonPressed:(UIButton *)button {
    if (![self.captionInput isDescendantOfView:self.view]) {
        //caption input setup
        self.captionInput = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 50.0f)];
        self.captionInput.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.captionInput.layer.borderWidth = 1;
        self.captionInput.font = [UIFont systemFontOfSize:17 weight:UIFontWeightLight];
        self.captionInput.textColor = [UIColor whiteColor];
        self.captionInput.layer.cornerRadius=8.0f;
        self.captionInput.layer.masksToBounds=YES;
        self.captionInput.layer.borderColor= [[UIColor whiteColor]CGColor];
        [self.captionInput becomeFirstResponder];
        //self.captionInput.returnKeyType = UIReturnKeyDone;
        [self.view addSubview:self.captionInput];
        
        [_captionInput setAlpha:0.f];
        
        [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_captionInput setAlpha:1.f];
        } completion:nil];
        [self.captionInput becomeFirstResponder];
    }
    else {
        NSLog(@"already have UITextView");
    }
    
}
- (void)compressVideo:(NSURL*)inputURL
            outputURL:(NSURL*)outputURL
              handler:(void (^)(AVAssetExportSession*))completion  {
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completion(exportSession);
    }];
}

- (void)acceptButtonPressed:(UIButton *)button {
    FIRUser *user = [FIRAuth auth].currentUser;
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
    NSString *timeString = [DateFormatter stringFromDate:[NSDate date]];
    
    if (user != nil) {
    NSString *uid = user.uid;
    // Create a reference to the file you want to upload
    NSString *randomUniqueFileName = [NSString stringWithFormat:@"%@/%@/%@%@%@",@"videos",uid,@"",timeString,@".mp4"];
         NSURL *localFile = _uploadUrl;
        //Caption Info
        NSString *textValue = [NSString stringWithFormat:@"%@", _captionInput.text];
        [self uploadContent: randomUniqueFileName secondVal:textValue];
        
        //[[[UIApplication sharedApplication] delegate] window].windowLevel = UIWindowLevelNormal;
//        EventVideoTableViewController *eventTBC = [[EventVideoTableViewController alloc]initWithFinalAddress:randomUniqueFileName myNSURL:localFile myVidCap:textValue];
//        CATransition* transition = [CATransition animation];
//        transition.duration = 0.10;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        transition.type = kCATransitionFade;
//        //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//        //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
//        [self.navigationController.view.layer addAnimation:transition forKey:nil];
//        [self.navigationController pushViewController:eventTBC animated:NO];
//        [self.avPlayer pause];
//        [self.avPlayerLayer removeFromSuperlayer];
//        self.avPlayer = nil;
    
    }
}
- (void) uploadContent:(NSString *) finalAddress secondVal:(NSString *) captionText {
    
    
    //Get current User
    FIRUser *user = [FIRAuth auth].currentUser;
    
    // Get a reference to the storage service, using the default Firebase App
    FIRStorage *storage = [FIRStorage storage];
    
    // Create a storage reference from our storage service
    FIRStorageReference *storageRef = [storage referenceForURL:[BounceConstants firebaseStorageUrl]];
    
    //Create ImageRef
    FIRStorageReference *vidsRef = [storageRef child: finalAddress];
    
    //Get NSDateObject
    NSNumber *timeStamp = [NSNumber numberWithDouble:-[[NSDate date] timeIntervalSince1970]];
    
    //Generate autovidHomefeed
    NSString *autoVidHomefeed = [[[[_ref child:[BounceConstants firebaseSchoolRoot]] child:@"HomeFeed"] childByAutoId] key];
    
    //save to homefeed
    [[[[[_ref child:[BounceConstants firebaseSchoolRoot]] child:@"HomeFeed"] child:autoVidHomefeed] child:@"postDetails"] updateChildValues:@{@"eventDate" :_mEventDate,@"eventName":self.mEventName,@"eventTime":self.mEventTime,@"orgID":self.mOrgID,@"eventID":self.mEventID,@"orgProfileImage": self.mOrgProfImage, @"eventDateObject":self.mEventDateObject}];
    
    //save fireCount
    [[[[_ref child:[BounceConstants firebaseSchoolRoot]]child:@"HomeFeed"] child:autoVidHomefeed] updateChildValues:@{@"fireCount": [NSNumber numberWithInt:0]}];
    
    //save mediaLinks
    [[[[[[[_ref child:[BounceConstants firebaseSchoolRoot]] child:@"HomeFeed"] child:autoVidHomefeed] child:@"postDetails"] child:@"mediaInfo"] childByAutoId] updateChildValues:@{@"fireCount": [NSNumber numberWithInt:0], @"mediaLink":[vidsRef fullPath],@"userID": [user uid], @"mediaCaption":captionText, @"timeStamp": timeStamp}];
    
    
    //save to personal profile
    [[[[_ref child:@"users"] child:[user uid] ]child:@"HomeFeedPosts"]  updateChildValues:@{autoVidHomefeed: [vidsRef fullPath]}];
    
    //save highest level timeStamp
    [[[[_ref child:[BounceConstants firebaseSchoolRoot]] child:@"HomeFeed"] child:autoVidHomefeed] updateChildValues:@{@"timeStamp":timeStamp}];
    
    //Get list of tags
    [[[[[[_ref child:[BounceConstants firebaseSchoolRoot]]child:@"Organizations"] child:_mOrgID] child:@"preferences"] queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        for (FIRDataSnapshot *rest in [[snapshot children] allObjects]) {
            
            [[[[[_ref child:[BounceConstants firebaseSchoolRoot]] child:@"HomeFeed"] child:autoVidHomefeed] child:@"orgTags"] updateChildValues:@{[rest key]:@"true"}];
        }
    }];
    
    
    // Local file you want to upload
    NSURL *localVid = _uploadUrl;
    
    // Create the file metadata
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"video/mp4";
    
    
    // Upload file and metadata to the object 'images/mountains.jpg'
    FIRStorageUploadTask *uploadTask = [vidsRef putFile:localVid metadata:metadata];
    
    // Listen for state changes, errors, and completion of the upload.
    [uploadTask observeStatus:FIRStorageTaskStatusResume handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload resumed, also fires when the upload starts
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusPause handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload paused
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload reported progress
        double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
        // Update the progress as needed
        [_progressView setProgress: percentComplete/100 animated: YES];
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload completed successfully
        [_progressView performAction:M13ProgressViewActionSuccess animated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    // Errors only occur in the "Failure" case
    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        if (snapshot.error != nil) {
            switch (snapshot.error.code) {
                case FIRStorageErrorCodeObjectNotFound:
                    // File doesn't exist
                    break;
                    
                case FIRStorageErrorCodeUnauthorized:
                    // User doesn't have permission to access file
                    break;
                    
                case FIRStorageErrorCodeCancelled:
                    // User canceled the upload
                    break;
                    
                case FIRStorageErrorCodeUnknown:
                    // Unknown error occurred, inspect the server response
                    break;
            }
        }
    }];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.avPlayer play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;
    
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    self.captionInput.bottom =(self.view.frame.size.height - keyboardBounds.size.height);
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardBounds;
    
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    self.captionInput.bottom = self.view.height - 70.0f;
    
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)cancelButtonPressed:(UIButton *)button {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

