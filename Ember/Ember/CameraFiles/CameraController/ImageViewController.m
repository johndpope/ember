//
//  ImageViewController.m
//  bounceapp
//
//  Created by Anthony Wamunyu Maina on 6/26/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import "ImageViewController.h"
#import "ViewUtils.h"
#import "UIImage+Crop.h"
#import "Ember-Swift.h"
#import <QuartzCore/QuartzCore.h>


@interface ImageViewController ()

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (nonatomic, retain) UITextView *captionInput;
@property (strong, nonatomic) UIButton *captionButton;
@property (strong, nonatomic) UIButton *acceptButton;

@end

@implementation ImageViewController

{
@private
    BOOL returnFromEventPage;
}


- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _image = [UIImage imageWithCGImage: image.CGImage
                                     scale: image.scale
                               orientation: image.imageOrientation];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.backgroundColor = [UIColor blackColor];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Register notification when the keyboard will be shown
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];

    
    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    returnFromEventPage = false;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.image = self.image;
    [self.view addSubview:self.imageView];
    
    // cancel button
    [self.view addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.frame = CGRectMake(0, 0, 60, 60);
    
    // caption button
    [self.view addSubview:self.captionButton];
    [self.captionButton addTarget:self action:@selector(captionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.captionButton.frame = CGRectMake(0, 0, 60, 60);
    
    // accept button
    [self.view addSubview:self.acceptButton];
    [self.acceptButton addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.acceptButton.frame = CGRectMake(0, 0, 60.0f, 60.0f);
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGesture];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    if (returnFromEventPage == true) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
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

- (void)cancelButtonPressed:(UIButton *)button {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)captionButtonPressed:(UIButton *)button {
    if (![self.captionInput isDescendantOfView:self.view]) {
        
    //caption input setup
    self.captionInput = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.contentBounds.size.width, 50.0f)];
    self.captionInput.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.captionInput.layer.borderWidth = 1;
    self.captionInput.font = [UIFont systemFontOfSize:17 weight:UIFontWeightLight];
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
    

    }
    else {
        NSLog(@"already have UITextView");
    }
    
    }

- (void)acceptButtonPressed:(UIButton *)button {
    __weak typeof(self) weakSelf = self;
    FIRUser *user = [FIRAuth auth].currentUser;
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
    NSString *timeString = [DateFormatter stringFromDate:[NSDate date]];
    if (user != nil) {
        NSString *uid = user.uid;
        NSString *randomUniqueFileName = [NSString stringWithFormat:@"/%@/%@/%@%@%@",@"images",uid,@"",timeString,@".jpeg"];
        //Caption Info
        NSString *textValue = [NSString stringWithFormat:@"%@", _captionInput.text];
        
        UINavigationController *Controller = [[UINavigationController alloc] init];
        [[[UIApplication sharedApplication] delegate] window].windowLevel = UIWindowLevelNormal;

        EventPickerTableViewController *eventTBC = [[EventPickerTableViewController alloc] initWithFinalAddress:randomUniqueFileName myImage:_image myCaption:textValue];
        Controller.viewControllers = [NSArray arrayWithObject:eventTBC];
        returnFromEventPage = true;
        [weakSelf presentViewController:Controller animated:NO completion:nil];

    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.imageView.frame = self.view.contentBounds;
    
    self.acceptButton.right = self.view.contentBounds.size.width - 5;
    self.acceptButton.bottom = self.view.height - 15.0f;

    self.cancelButton.left = 5;
    self.cancelButton.bottom = self.view.height - 15.0f;
    
    
    //caption Button
    self.captionButton.center = self.view.contentCenter;
    self.captionButton.bottom = self.view.height - 15.0f;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

