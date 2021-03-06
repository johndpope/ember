/* This file provided by Facebook is for non-commercial testing and evaluation
 * purposes only.  Facebook reserves all rights not expressly granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "EmberVideoNode.h"
#import "Video.h"

#import "Ember-Swift.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASStackLayoutSpec.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASVideoNode.h>

//static const CGFloat kImageSize = 80.0f;
//static const CGFloat kOuterPadding = 16.0f;
//static const CGFloat kInnerPadding = 10.0f;
static const CGFloat kOrgPhotoWidth = 50.0f;
static const CGFloat kOrgPhotoHeight = 50.0f;

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


@interface EmberVideoNode () <ASVideoNodeDelegate,UIGestureRecognizerDelegate> {
    
    ASNetworkImageNode *_imageNode;
    Video *_videoNode;
    ASTextNode *_textNode;
    ASDisplayNode *_divider;
    BOOL _swappedTextAndImage;
    ASTextNode *_dateTextNode;
    UIImage *_placeholderImage;
    BOOL _placeholderEnabled;
    EmberSnapShot*_snapShot;
    ASDisplayNode *_background;
    ASNetworkImageNode *_orgProfilePhoto;
    ASTextNode *_interested;
    ASTextNode *_userName;
    ASTextNode *_caption;
    NSString *uuid;
    FIRDatabaseReference *_usersRef;
    ASButtonNode *_fire;
    ASTextNode *_fireCount;
    EmberDetailsNode* _emberDetailsNode;
    CGFloat _screenWidth;

}

@end

@implementation EmberVideoNode

-(void)setPlaceholderImage:(UIImage *)img{
    [_videoNode setPlaceholderImage:img];
}

-(Video *)getVideoNode{
    return _videoNode;
}

-(ASTextNode *)getTextNode{
    return _textNode;
}

-(ASTextNode *)getDateTextNode{
    return _dateTextNode;
}

-(void)setPlaceholderEnabled:(BOOL)placeholderEnabled{
    _videoNode.placeholderEnabled = placeholderEnabled;
}

-(void)fetchOrgProfilePhotoUrl:(NSString*) orgId{
    
    FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:[BounceConstants firebaseOrgsChild]] child:orgId]  queryLimitedToFirst:100];
    [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        NSDictionary *org = snapShot.value;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _orgProfilePhoto.URL = [NSURL URLWithString:org[[BounceConstants firebaseOrgsChildSmallImageLink]]];
            
        });
    }];
}

-(void)fetchUserName{
    FIRDatabaseQuery *recentPostsQuery = [[[_usersRef child:[BounceConstants firebaseUsersChild]] child:uuid]  child:@"username"];
    [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
//                        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        
        NSString *userName = snapShot.value;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_userName setAttributedString:[[NSAttributedString alloc] initWithString:userName
                                                                           attributes:[self textStyleUsername]]];
            
        });
    }];
}

- (NSDictionary *)textStyleLeft{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentLeft;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleUsername{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:10.0f];
    }else{
        font = [UIFont systemFontOfSize:12.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentLeft;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

-(void)setFollowButtonHidden{
    [_emberDetailsNode setFollowButtonHidden];
    
}

-(void)showFireCount{
    [_emberDetailsNode showFireCount];
}

-(void)setIsVideo{
    _emberDetailsNode.isVideo = YES;
}

- (instancetype)initWithEvent:(EmberSnapShot *)snapShot{
    if (!(self = [super init]))
        return nil;
  
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _emberDetailsNode.isVideo = NO;

    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _usersRef = [[FIRDatabase database] reference];
    
    _background = [[ASDisplayNode alloc] init];
    _background.layerBacked = YES;
    _background.backgroundColor = [UIColor whiteColor];
    _background.flexGrow = YES;
    
    _emberDetailsNode = [[EmberDetailsNode alloc] initWithEvent:snapShot];
    
    
//    _orgProfilePhoto = [[ASNetworkImageNode alloc] init];
//    _orgProfilePhoto.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
//    _orgProfilePhoto.preferredFrameSize = CGSizeMake(kOrgPhotoWidth, kOrgPhotoHeight);
//    _orgProfilePhoto.cornerRadius = kOrgPhotoWidth / 2;
//    _orgProfilePhoto.imageModificationBlock = ^UIImage *(UIImage *image) {
//        
//        UIImage *modifiedImage;
//        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
//        
//        UIGraphicsBeginImageContextWithOptions(image.size, false, [[UIScreen mainScreen] scale]);
//        
//        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kOrgPhotoWidth] addClip];
//        [image drawInRect:rect];
//        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
//        
//        UIGraphicsEndImageContext();
//        
//        return modifiedImage;
//        
//    };
//    
//    [_orgProfilePhoto addTarget:self action:@selector(orgPhotoClicked) forControlEvents:ASControlNodeEventTouchDown];
//    
//    _snapShot = snapShot;
//    NSDictionary *eventDetails = [snapShot getPostDetails];
//    
//   [self fetchOrgProfilePhotoUrl:eventDetails[[BounceConstants firebaseEventsChildOrgId]]];
    
     _videoNode = [[Video alloc] init];
    _videoNode.delegate = self;
    _videoNode.shouldRenderProgressImages = YES;
    _videoNode.shouldAutorepeat = YES;
//    _videoNode.shouldAutoplay = YES;
    
//    _userName = [[ASTextNode alloc] init];
//    _caption = [ASTextNode new];
//    
//    uuid = nil;
//
//    
//    if(!eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]]){
//        if([eventDetails[[BounceConstants firebaseHomefeedMediaInfo]] isKindOfClass:[NSDictionary class]]){
//            NSArray *values = [eventDetails[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
//            if ([values count] != 0){
//                NSDictionary *first = [values objectAtIndex:0];
//                uuid = first[@"userID"];
//                
//                if(![first[@"mediaCaption"] isEqualToString:@"(null)"]){
//                    _caption.attributedString = [[NSAttributedString alloc] initWithString:first[@"mediaCaption"]
//                                                                                attributes:[self textStyleLeft]];
//                }
//                
//            }
//            
//        }else{
//            NSArray *values = eventDetails[[BounceConstants firebaseHomefeedMediaInfo]];
//            NSDictionary *first = [values objectAtIndex:0];
//            uuid = first[@"userID"];
//            if(![first[@"mediaCaption"] isEqualToString:@"(null)"]){
//                _caption.attributedString = [[NSAttributedString alloc] initWithString:first[@"mediaCaption"]
//                                                                            attributes:[self textStyleLeft]];
//            }
//            
//        }
//        
//        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//        
//        
//        _caption.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _caption.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _caption.attributedString.size.height)));
//        
//        
//        _userName.attributedString = [[NSAttributedString alloc] initWithString:@" "
//                                                                     attributes:[self textStyleLeft]];
//        
//        _userName.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _userName.attributedString.size.height)), ASRelativeSizeMakeWithCGSize(CGSizeMake(screenWidth, _userName.attributedString.size.height)));
//        
//        [self fetchUserName];
//        
//    }else{
//        _userName.hidden = YES;
//        _caption.hidden = YES;
//    }
//    
//    _fire = [[ASButtonNode alloc] init];
//    [_fire setImage:[UIImage imageNamed:@"homeFeedFireUnselected"] forState:ASControlStateNormal];
//    [_fire setImage:[UIImage imageNamed:@"homeFeedFireSelected"] forState:ASControlStateSelected];
//    
//    [_fire addTarget:self
//              action:@selector(fireButtonTapped)
//    forControlEvents:ASControlNodeEventTouchDown];
//    
//    _fireCount = [[ASTextNode alloc] init];
//    
//    if(![([snapShot getData][@"fireCount"]) isEqual:[NSNull null]]){
//        
//        NSString *fireCountString = [NSString stringWithFormat:@"+%@", [snapShot getData][@"fireCount"]];
//        NSUInteger fireCountNum = [fireCountString integerValue];
//        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", fireCountNum]
//                                                                      attributes:[self textStyleFireUnselected]];
//    }
//    
//    
//    _userName.maximumNumberOfLines = 1;
//    _userName.truncationMode = NSLineBreakByTruncatingTail;
//    
//    _caption.maximumNumberOfLines = 2;
//    _caption.truncationMode = NSLineBreakByTruncatingTail;
//    
//    _textNode = [[ASTextNode alloc] init];
//    _textNode.attributedString = [[NSAttributedString alloc] initWithString:eventDetails[[BounceConstants firebaseEventsChildEventName]]
//                                                                              attributes:[self textStyleEventName]];
//    _textNode.maximumNumberOfLines = 1;
//    _textNode.truncationMode = NSLineBreakByTruncatingTail;
//    
//    _dateTextNode = [[ASTextNode alloc] init];
//    _dateTextNode.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", eventDetails[[BounceConstants firebaseEventsChildEventDate]], eventDetails[[BounceConstants firebaseEventsChildEventTime]]]
//                                                                     attributes:[self textStyleItalic]];
//    
//    _dateTextNode.maximumNumberOfLines = 1;
//    _dateTextNode.truncationMode = NSLineBreakByTruncatingTail;
    
    
    [self addSubnode:_background];
    [self addSubnode:_videoNode];
    [self addSubnode:_emberDetailsNode];
//    [self addSubnode:_userName];
//    [self addSubnode:_textNode];
//    [self addSubnode:_caption];
//    [self addSubnode:_orgProfilePhoto];
//    [self addSubnode:_dateTextNode];
//    [self addSubnode:_fire];
//    [self addSubnode:_fireCount];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;;
    // hairline cell separator
    _divider = [[ASDisplayNode alloc] init];
    _divider.backgroundColor = [UIColor lightGrayColor];
    _divider.spacingAfter = 5.0f;
    CGFloat pixelHeight = 1.0f;
    _divider.preferredFrameSize = CGSizeMake(screenWidth, pixelHeight);
    [self addSubnode:_divider];
    
    return self;
}

-(void)didLoad{
    [super didLoad];
    
        // Enabling long press only for videos on homefeed
        UILongPressGestureRecognizer *longPressGestureRecognizer=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressRecognizer)];
        
        longPressGestureRecognizer.numberOfTouchesRequired = 1;
        longPressGestureRecognizer.minimumPressDuration = 0.2;
        //            [longPressGestureRecognizer requireGestureRecognizerToFail:[self getButtonTap]];
        //            if([self getImageTap]){
        //                [longPressGestureRecognizer requireGestureRecognizerToFail:[self getImageTap]];
        //            }
        
        longPressGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:longPressGestureRecognizer];
    
}

-(void)handleLongPressRecognizer{
//    NSLog(@"long press detected");
    id<VideoLongPressDelegate> strongDelegate = self.videolongPressDelegate;
    if ([strongDelegate respondsToSelector:@selector(longPressDetected:)]) {
        [strongDelegate videolongPressDetected:_snapShot];
    }
}


-(void)fireButtonTapped{
    
    NSString *uid = [FIRAuth auth].currentUser.uid;
    
    if(_fire.selected){
        
        
        NSUInteger count = [[[_fireCount attributedString] string] integerValue];
        count--;
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", count]
                                                                      attributes:[self textStyleFireUnselected]];
        
        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_snapShot.key];
        [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:uid] child:@"postsFired"] child:_snapShot.key] removeValue];
        
        [_fire setSelected:NO];
        
        
        
    }
    else{
        
        
        NSUInteger count = [[[_fireCount attributedString] string] integerValue];
        count++;
        _fireCount.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"+%lu", count]
                                                                      attributes:[self textStyleFire]];
        
        [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:uid] child:@"postsFired"] child:_snapShot.key] setValue:[NSNumber numberWithBool:YES]];
        [_fire setSelected:YES];
        
        
    }
    
}

-(void)orgPhotoClicked{

    NSDictionary *eventDetails = [_snapShot getPostDetails];
    NSString* orgId = eventDetails[[BounceConstants firebaseEventsChildOrgId]];
    id<OrgImageInVideoNodeClickedDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(bounceVideoOrgImageClicked:)]) {
        [strongDelegate bounceVideoOrgImageClicked:orgId];
    }
    
    
}

- (NSDictionary *)textStyleFire{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular];
    }else{
        font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
    }
    
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor colorWithRed: 213.0/255.0 green: 29.0/255.0 blue: 36.0/255.0 alpha: 1.0], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleFireUnselected{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightRegular];
    }else{
        font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentCenter;
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyle
{
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentRight;

    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: style};
}

- (NSDictionary *)textStyleEventName
{
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentLeft;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}


- (NSDictionary *)textStyleItalic{
    
    UIFont *font  = nil;
    
    if(IS_IPHONE_5){
        font = [UIFont systemFontOfSize:12.0f];
    }else{
        font = [UIFont systemFontOfSize:14.0f];
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    style.alignment = NSTextAlignmentRight;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: style};
}

//-(void)videoNodeWasTapped:(ASVideoNode *)videoNode{
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = [UIScreen mainScreen].bounds.size.height;
//    _videoNode.frame = CGRectMake(0, 0, width, height);
//    
//}


//#if UseAutomaticLayout
- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
//    _videoNode.contentMode = UIViewContentModeScaleAspectFill;
    _videoNode.preferredFrameSize = CGSizeMake(_screenWidth, _screenWidth);
    _emberDetailsNode.flexGrow = YES;
    _emberDetailsNode.preferredFrameSize = CGSizeMake(_screenWidth, constrainedSize.min.height);
    
    ASLayoutSpec *horizontalSpacer =[ASLayoutSpec new];
    horizontalSpacer.flexGrow = YES;
    ASStackLayoutSpec *vert = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical spacing:1.0 justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsStretch children:@[_divider,_videoNode, _emberDetailsNode]];
    
    return vert;
}

- (void)layout
{
    [super layout];
    
    // Manually layout the divider.
    CGFloat pixelHeight = 1.0f / [[UIScreen mainScreen] scale];
    _divider.frame = CGRectMake(0.0f, 0.0f, self.calculatedSize.width, pixelHeight);
}

- (void)toggleNodesSwap
{
    _swappedTextAndImage = !_swappedTextAndImage;
    
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.15 animations:^{
            self.alpha = 1;
        }];
    }];
}

- (void)updateBackgroundColor
{
    if (self.highlighted) {
        self.backgroundColor = [UIColor lightGrayColor];
    } else if (self.selected) {
        self.backgroundColor = [UIColor blueColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateBackgroundColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateBackgroundColor];
}

@end
