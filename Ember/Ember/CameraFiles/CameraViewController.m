//
//  CameraViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "CameraViewController.h"
#import "ViewUtils.h"
#import "ImageViewController.h"
#import "VideoViewController.h"
#import "SDRecordButton.h"

const int videoDuration  = 15;

@interface CameraViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;


@property (weak, nonatomic) IBOutlet SDRecordButton *recordButton;


@property (nonatomic, strong)          NSTimer        *progressTimer;
@property (nonatomic)                  CGFloat        progress;

@property (nonatomic,strong) UILongPressGestureRecognizer *recordVideo;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong,nonatomic) UIWindow *statusWindow;
@end


@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recordVideo = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    self.recordVideo.minimumPressDuration = 1.0f;
    self.recordVideo.allowableMovement = 100.0f;
    
    
    [self configureButtonWithColor:[UIColor  whiteColor] progressColor:[UIColor redColor]];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //[self.view.window addSubview:<#(nonnull UIView *)#>]
    
        
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
    
    // ----- camera buttons -------- //
    
    //record button
    [self.view addSubview:self.recordButton];
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 0, 16.0f + 20.0f, 50.0f);
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash"] forState:UIControlStateNormal];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    
    self.flashButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.flashButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.flashButton.layer.shadowOpacity = 0.9f;
    self.flashButton.layer.shadowRadius = 4.0f;
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    //button to go back to app
    self.homeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.homeButton.frame = CGRectMake(0, 0, 60.0f, 60.0f);
    self.homeButton.tintColor = [UIColor whiteColor];
    [self.homeButton setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
    self.homeButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    
    self.homeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.homeButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.homeButton.layer.shadowOpacity = 0.9f;
    self.homeButton.layer.shadowRadius = 4.0f;
    [self.homeButton addTarget:self action:@selector(homeCameraPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:self.homeButton];
    
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(0, 0, 60.0f, 60.0f);
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch"] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        self.switchButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.switchButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.switchButton.layer.shadowOpacity = 0.9f;
        self.switchButton.layer.shadowRadius = 4.0f;
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[[UIApplication sharedApplication] delegate] window].windowLevel = UIWindowLevelNormal;
    
}


- (void)configureButtonWithColor:(UIColor*)color progressColor:(UIColor *)progressColor {
    
    // Configure colors
    self.recordButton.buttonColor = color;
    self.recordButton.progressColor = progressColor;
    
    [self.recordButton addGestureRecognizer:_recordVideo];
    
    // Add Targets
    [self.recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpOutside];
    
}

- (void) handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{

    if([sender isEqual:self.recordVideo])
    {
        if (sender.state ==UIGestureRecognizerStateBegan)
        {
            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
            self.flashButton.hidden = YES;
            self.switchButton.hidden = YES;
            self.homeButton.hidden = YES;
            
            // start recording
            NSURL *outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
            [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
                
                VideoViewController *vc = [[VideoViewController alloc] initWithVideoUrl:outputFileUrl];
                 CATransition* transition = [CATransition animation];
                transition.duration = 0.5;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
                //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
                [self.navigationController.view.layer addAnimation:transition forKey:nil];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        
        }
        if(sender.state ==UIGestureRecognizerStateEnded || sender.state ==UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed)
        {
            [self.progressTimer invalidate];
           
            
            self.flashButton.hidden = NO;
            self.switchButton.hidden = NO;
            self.homeButton.hidden = NO;
            
            [self.camera stopRecording];
            self.progress = 0;
            [self.recordButton setProgress:self.progress];
        }
    }
}

-(void) resetButton {
}

-(void) recordButtonPressed:(SDRecordButton *) button
{
    __weak typeof(self) weakSelf = self;
    
    // capture
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            
            ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
            [weakSelf presentViewController:imageVC animated:NO completion:nil];
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [[[UIApplication sharedApplication] delegate] window].windowLevel = UIWindowLevelStatusBar + 1;
    // start the camera
    [self.camera start];
    
    
}

/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

- (void) homeCameraPressed: (UIButton *)button
{
    [[[UIApplication sharedApplication] delegate] window].windowLevel = UIWindowLevelNormal;

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    

}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}


- (void)recording {
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)pausedRecording {
    [self.progressTimer invalidate];
}

- (void)updateProgress {
    self.progress += 0.05/videoDuration;
    [self.recordButton setProgress:self.progress];
    if (self.progress >= 1)
    {
        self.flashButton.hidden = NO;
        self.switchButton.hidden = NO;
        self.homeButton.hidden = NO;
        
        [self.camera stopRecording];
        [self.progressTimer invalidate];
        self.progress = 0;
        [self.recordButton setProgress:self.progress];
    }
    
}


/* other lifecycle methods */

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.recordButton.center = self.view.contentCenter;
    self.recordButton.bottom = self.view.height - 10.0f;
    
    self.flashButton.center = self.view.contentCenter;
    self.flashButton.top = 5.0f;
    
//    self.switchButton.top = 5.0f;
//    self.switchButton.right = self.view.width - 5.0f;
    
//    self.homeButton.top = 5.0f;
//    self.homeButton.left = 5.0f;
    
    self.homeButton.left = 5;
    self.homeButton.bottom = self.view.height - 15.0f;
    
    self.switchButton.right = self.view.contentBounds.size.width - 5;
    self.switchButton.bottom = self.view.height - 15.0f;

}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
