//
//  VideoViewController.m
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/26/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import "VideoViewController.h"
#import "SDAVAssetExportSession.h"
#import "bounceapp-Swift.h"
#import <QuartzCore/QuartzCore.h>
@import AVFoundation;
@import AssetsLibrary;
@import MobileCoreServices;




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
@end



@implementation VideoViewController

- (instancetype)initWithVideoUrl:(NSURL *)url {
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
                NSData *newDataForUpload = [NSData dataWithContentsOfURL:_uploadUrl];
                NSLog(@"Size of new Video after compression is (bytes):%d",[newDataForUpload length]);
            }
        }];
        
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
        self.captionInput.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        self.captionInput.textColor = [UIColor whiteColor];
        self.captionInput.layer.cornerRadius=8.0f;
        self.captionInput.layer.masksToBounds=YES;
        self.captionInput.layer.borderColor= [[UIColor whiteColor]CGColor];
        [self.captionInput becomeFirstResponder];
        
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
        [[[UIApplication sharedApplication] delegate] window].windowLevel = UIWindowLevelNormal;

        EventVideoTableViewController *eventTBC = [[EventVideoTableViewController alloc]initWithFinalAddress:randomUniqueFileName myNSURL:localFile myVidCap:textValue];
        CATransition* transition = [CATransition animation];
        transition.duration = 0.10;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController pushViewController:eventTBC animated:NO];
        [self.avPlayer pause];
        [self.avPlayerLayer removeFromSuperlayer];
        self.avPlayer = nil;
    
    }
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

