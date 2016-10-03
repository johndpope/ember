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

#import "HomefeedController.h"
#import "EventViewController.h"
#import "OrgProfileViewController.h"
#import "EmberDetailsNode.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASAssert.h>

#import "Ember-Swift.h"

#import "TitleNode.h"
#import "EmberVideoNode.h"
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import "EmberNode.h"
#import "EmberSnapShot.h"


@import Firebase;
@import FirebaseStorage;


@interface HomefeedController () <ASTableDataSource, ASTableDelegate, ImageClickedDelegate, OrgImageClickedDelegate,  OrgImageInVideoNodeClickedDelegate, BounceImageClickedDelegate,LongPressDelegate ,VideoLongPressDelegate,ShowAlertDelegate,UIGestureRecognizerDelegate>
{
    ASTableNode *_tableNode;
    FIRDataSnapshot *_snapShot;
    BOOL _dataSourceLocked;
    NSIndexPath *_titleNodeIndexPath;
    dispatch_queue_t _previewQueue;
    NSString *_url;
    ASImageNode *_fullview;
    ASImageNode *_temp;
    EmberSnapShot *_data;
    EmberSnapShot *_dataSection2;
    NSMutableArray *_dataValues;
    UIActivityIndicatorView *_activityIndicatorView;
    EmberUser *_user;
    UIRefreshControl *_refreshControl;
    UILabel *_messageLabel;
    BOOL _reloadCalled;
    
    
}
@property (nonatomic, strong) NSString *marker;
@property (nonatomic, strong) NSArray *contents;
@property (atomic, assign) BOOL dataSourceLocked;
@property (strong, nonatomic) FIRStorage *storage;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) FIRDatabaseReference *userRef;


@end

@implementation HomefeedController

FIRDatabaseHandle _refHandle;

#pragma mark -
#pragma mark UIViewController.

- (instancetype)init
{
    _tableNode = [[ASTableNode alloc] init];
    self = [super initWithNode:_tableNode];
    
    if (self) {
        
        _tableNode.dataSource = self;
        _tableNode.delegate = self;
        
    }
    
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];

    
    CGSize boundSize = self.view.bounds.size;
    
    CGRect refreshRect = _activityIndicatorView.frame;
    refreshRect.origin = CGPointMake((boundSize.width - _activityIndicatorView.frame.size.width) / 2.0,
                                     (boundSize.height - _activityIndicatorView.frame.size.height) / 2.0);
    
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    
    [_activityIndicatorView sizeToFit];
    
    _activityIndicatorView.frame = refreshRect;
    
    [self.view addSubview:_activityIndicatorView];
    
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.tintColor = [BounceConstants primaryAppColor];
    [_tableNode.view addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    
    _tableNode.view.allowsSelection = NO;
    
    
    _user = [[EmberUser alloc] init];
    
    [_user isSignedIn:^(BOOL completionHandler){
        
        if (completionHandler) {
            // User is signed in.
            NSLog(@"user is signed in");
        } else {
            // No user is signed in.
            NSLog(@"user is NOT signed in");
        }
        
    }];
    
    //    [user isAdminOf:@"test" completionHandler:^(BOOL completionHandler){
    //
    //    }];
    
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _userRef = [[FIRDatabase database] reference];
  
    
    _data = [[EmberSnapShot alloc] init];
    _dataSection2 = [[EmberSnapShot alloc] init];
    
    _storage = [FIRStorage storage];
    _storageRef = [_storage referenceForURL:[BounceConstants firebaseStorageUrl]];
    _previewQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _titleNodeIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(toggleEditingMode)];
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppSettingsChanged:) name:@"MyAppSettingsChanged" object:nil];
    
    _headers = [[NSMutableDictionary alloc] init];
    
    _reloadCalled = NO;

   
    //[self loadMoreContents];
   // [self loadEvents];
    [self fetchData];
//    [self deleteDefaults];
//    [self fetchOrgsFollowed];
    
   
}


-(void) onAppSettingsChanged:(NSNotification*)notification
{
    // TODO : can be improved to only update changed node instead of reloading entire table
    [self fetchData];
}

// TODO gallery functionality when item is a video in homefeed


/**
 *  Delegate method called when user clicks on gallery
 *
 *  @param childImage First node with the associated info. Used for acquiring view for first image
 *  @param image      First image clicked
 *  @param array      Array with all the info under 'mediaInfo' of firebase tree
 */
- (void)childNode:(EmberNode *)childImage didClickImage:(UIImage *)image withLinks:(NSArray*) array withHomeFeedID:(NSString *)homefeedID{
    
//    id<PassedDelegate> strongDelegate = self.delegate;
//    
//    if ([strongDelegate respondsToSelector:@selector(childController:imagePassed:)]) {
//        [strongDelegate childController:self imagePassed:image];
//    }
    
//    NSLog(@"array: %@", array);
    
    GalleryImageProvider *provider = [[GalleryImageProvider alloc] init];
 
    [provider setUrls:array];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 24);
    
    CounterView *headerView = [[CounterView alloc] initWithFrame:frame node:childImage currentIndex:0 count:array.count index:0 mediaInfo : array];
    CounterView *footerView = [[CounterView alloc] initWithFrame:frame node:childImage currentIndex:0 count:array.count index:1 mediaInfo:array];
    
    GalleryViewController *galleryViewController  = [[GalleryViewController alloc] init];
    [galleryViewController setImageProvider:provider];
    [galleryViewController setHomeFeedID: homefeedID];
    [galleryViewController setDisplacedView:childImage.getSubImageNode.view];
    [galleryViewController setImageCount:array.count];
    [galleryViewController setStartIndex:0];
    [galleryViewController intializeTransitions];
    [galleryViewController completeInit];
    galleryViewController.headerView = headerView;
    galleryViewController.footerView = footerView;
    
    galleryViewController.getInitialImageController.showAlertDelegate = self;
//        galleryViewController.launchedCompletion = { print("LAUNCHED") }
//        galleryViewController.closedCompletion = { print("CLOSED") }
//        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }

    [self presentImageGallery:galleryViewController completion:nil];
   
    galleryViewController.landedPageAtIndexCompletion = ^(NSInteger index){
        
//        NSLog(@"index: %lu", index);
        headerView.currentIndex = index;
        footerView.currentIndex = index;
        
        
    };
    
}

-(void)deleteDefaults{
    
    NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    
    for(NSString* key in keys){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    
}

-(void)fetchOrgsFollowed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    FIRUser *user = [FIRAuth auth].currentUser;
    [[[[[_userRef child:[BounceConstants firebaseUsersChild]] child:user.uid] child:[BounceConstants firebaseUsersChildEventsFollowed]] queryOrderedByKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        
        for(FIRDataSnapshot* child in snapShot.children){

            NSDictionary *dict = child.value;

            [defaults setValue:@"eventID" forKey:dict[@"EventID"]];
            
        }

    }];
}

-(void)fetchData{
    
    [_activityIndicatorView startAnimating];
    
    if(![InternetConnection isConnectedToNetwork]){
        [_refreshControl endRefreshing];
        [_activityIndicatorView stopAnimating];
    }
    
    if([_refreshControl isRefreshing]){
        [_data removeAllSnapShots];
        [_dataSection2 removeAllSnapShots];
        [_data resetPrefsLastIndex];
        [_dataSection2 resetPrefsLastIndex];
        
    }

    
    // TODO : maybe save prefs locally for faster retrieval rather than querying db everytime app is launched
    [_user loadPreferences:^(NSDictionary* completion){
        
//        NSLog(@"array: %@", completion);
        
        NSDate *now = [NSDate date];
        NSDate *oneDayAgo = [now dateByAddingTimeInterval:-[BounceConstants maxNumberPastDays] * 24 * 60 * 60];
//        NSDate *oneDayAgo = [now dateByAddingTimeInterval:-200 * 24 * 60 * 60];
        
        NSString *nowInMillis = [NSString stringWithFormat:@"%f",[now timeIntervalSince1970]];
        NSString *oneDayInMillis = [NSString stringWithFormat:@"%f",[oneDayAgo timeIntervalSince1970]];
        
        NSNumber *numNowInMillis = [NSNumber numberWithDouble:[nowInMillis doubleValue]];
        NSNumber *numOneDayAgoInMillis = [NSNumber numberWithDouble:-[oneDayInMillis doubleValue]];
        
        FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:[BounceConstants firebaseHomefeed]] queryOrderedByChild:@"timeStamp"] queryEndingAtValue:numOneDayAgoInMillis];
        [recentPostsQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
//                    NSLog(@"%@  %@", snapShot.key, snapShot.value);
            
            NSUInteger *prefsCount  = 0;
            
            for(FIRDataSnapshot* child in snapShot.children){
                
                NSDictionary *val = child.value;
                NSDictionary *postDetails = val[@"postDetails"];
                NSNumber *time = postDetails[@"eventDateObject"];
                NSString *orgID = postDetails[@"orgID"];
                if(-[time doubleValue] < [numNowInMillis doubleValue]){
                    
//                    [_data addSnapShot:child];
                    
                    if(val[@"orgTags"]){
                        
                        NSArray *prefs = nil;
                        
                        if([val[@"orgTags"] isKindOfClass:[NSDictionary class]]){
                            prefs = [val[@"orgTags"] allKeys];
                        }else{ // IS OF TYPE NSARRAY
                            prefs = val[@"orgTags"];
   
                        }

                        if([_user matchesUserPreferences:prefs] || [_user userFollowsOrg:orgID] || [_user isUserPost:child]){
                            [_data addSnapShotToIndex:child user:_user]; // Past Events
                        }else{
                            [_data addSnapShotToEnd:child user: _user];
                        }
                    }
                    
                    
                }else{
                    //                NSLog(@"upcoming: %@", time);
                    
//                    [_dataSection2 addSnapShot:child];
                    
                    if(val[@"orgTags"]){
                        
                        NSArray *prefs = nil;
                        
                        if([val[@"orgTags"] isKindOfClass:[NSDictionary class]]){
                            prefs = [val[@"orgTags"] allKeys];
//                            NSLog(@"%@", [val[@"orgTags"] allKeys]);
                            
                            
                        }else{ // IS OF TYPE NSARRAY
                            prefs = [val[@"orgTags"] allKeys];
//                            NSLog(@"%@", [val[@"orgTags"] allKeys]);
                            
                            
                        }
                        
//                        NSLog(@"%@", prefs);
                        
//                        NSDictionary *prefs = val[@"orgTags"];
                        if([_user matchesUserPreferences:prefs] || [_user userFollowsOrg:orgID] || [_user isUserPost:child]){
                            [_dataSection2 addSnapShotToIndex:child user:_user]; // Upcoming Events
                        }else{
                            [_dataSection2 addSnapShotToEnd:child user:_user];
                        }
                    }
                    
                }

            }

            [_activityIndicatorView stopAnimating];
            
            if(_refreshControl.isRefreshing){
                [_refreshControl endRefreshing];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _reloadCalled = YES;
                [_tableNode.view reloadData];
  
            });
        }withCancelBlock:^(NSError *_Nonnull error){
            NSLog(@"%@", error.localizedDescription);
        }];
        
    }];
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_refreshControl.superview sendSubviewToBack:_refreshControl];
}

-(void)FIRDownload:(EmberNode*)node post:(NSDictionary*)post{
    
    NSString *url = nil;
    
    // TODO - reason behind class type changing from dictionary to array and back
    if(post[[BounceConstants firebaseHomefeedEventPosterLink]] != nil){
        url = post[[BounceConstants firebaseHomefeedEventPosterLink]];
    }else{
        
        if([post[[BounceConstants firebaseHomefeedMediaInfo]] isKindOfClass:[NSDictionary class]]){
            NSArray *values = [post[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
            if ([values count] != 0){
                NSDictionary *first = [values objectAtIndex:0];
                //            NSLog(@"first: %@", first);
                url = first[@"mediaLink"];
            }

        }else{ // IS OF TYPE NSARRAY
            NSArray *values = post[[BounceConstants firebaseHomefeedMediaInfo]];
            NSDictionary *first = [values objectAtIndex:0];
            //            NSLog(@"first: %@", first);
            url = first[@"mediaLink"];
           
        }

    }
    
    if(![url containsString:@"http"]){
        
        FIRStorageReference *ref = [_storageRef child:url];
        
        // Fetch the download URL
        [ref downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (error != nil) {
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([[URL absoluteString] containsString:@"mp4"]  || [[URL absoluteString] containsString:@"mov"] ){
                        node.getSubVideoNode.asset = [AVAsset assetWithURL:URL];
                        
                    }else{
//                        NSLog(@"url %@", URL);
                        node.getSubImageNode.URL = URL;
                        
                    }
                    
                    
                });
                
            }
        }];
    }else{
        
        if([url containsString:@"mp4"]  || [url containsString:@"mov"] ){
            node.getSubVideoNode.asset = [AVAsset assetWithURL:[NSURL URLWithString:url]];
            
        }else{
           node.getSubImageNode.URL = [NSURL URLWithString:url];
            
        }
        
    }
    
    
}

-(void)orgClicked:(NSString*)orgId{
    OrgProfileViewController *_myViewController = [OrgProfileViewController new];
    _myViewController.orgId = orgId;
    [[self navigationController] pushViewController:_myViewController animated:YES];
}

// Using this delegate instead of 'didSelectRowAtIndexPath' since table rows are
// dynamically created when media links exceed max number per gallery

-(void)bounceImageClicked:(EmberSnapShot *)snap{

    NSDictionary *eventDetails = [snap getPostDetails];
    NSString *url = eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]];
    if(![url containsString:@"mp4"]  || [url containsString:@"mov"] ){
        EventViewController *_myViewController = [EventViewController new];
        _myViewController.eventNode = snap;
        [[self navigationController] pushViewController:_myViewController animated:YES];
    }
}

-(void)bounceVideoOrgImageClicked:(NSString *)orgId{
    OrgProfileViewController *_myViewController = [OrgProfileViewController new];
    _myViewController.orgId = orgId;
    [[self navigationController] pushViewController:_myViewController animated:YES];
}

-(void)videolongPressDetected:(EmberSnapShot *)snap{
    
    NSArray *mediaInfo = snap.getMediaInfo.allValues;
    NSString *myUserid = [FIRAuth auth].currentUser.uid;
    NSString *snapShotid = [[mediaInfo valueForKey:@"userID"] objectAtIndex:0];
    
    NSLog(@"mine: %@, reported: %@", myUserid,snapShotid);
    
   
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Select Action"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction* blockUser = [UIAlertAction
                                actionWithTitle:@"Block User"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                    [self blockUser:snap userToBlockId:snapShotid myUserId:myUserid];
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    
    UIAlertAction* report = [UIAlertAction
                             actionWithTitle:@"Report"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self sendReport:snap];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    // Users should not be able to report themselves
    if(![myUserid isEqualToString:snapShotid]){
        [alert addAction:report];
        [alert addAction:blockUser];
    }
    [alert addAction:cancel];
    
    
    if([self presentedViewController] == nil){
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)blockUser:(EmberSnapShot*)snap userToBlockId:(NSString*) usertoblockid myUserId:(NSString*)myuserid{
    
    [[[[[_userRef child:@"users"] child:myuserid] child:@"usersBlocked"] child:usertoblockid] setValue:[NSNumber numberWithBool:YES]];
    
}
-(void)longPressDetected:(EmberSnapShot *)snap{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Select Action"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
  
    UIAlertAction* report = [UIAlertAction
                             actionWithTitle:@"Report"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                [self sendReport:snap];
                                [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    NSDictionary *mediaInfo = snap.getMediaInfo;
    NSString *myUserid = [FIRAuth auth].currentUser.uid;
    NSString *reportedUserid = mediaInfo[@"userID"];
    
    // Users should not be able to report themselves
    if(![myUserid isEqualToString:reportedUserid]){
        [alert addAction:report];
    }
    
    [alert addAction:cancel];
    
    
    if([self presentedViewController] == nil){
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)presentSuccessFulAlert{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"Report Sent Successfully"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    
    [alert addAction:ok];
    
    if([self presentedViewController] == nil){
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)presentUserBlockedSuccessfullyAlert{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"User blocked"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    
    [alert addAction:ok];
    
    if([self presentedViewController] == nil){
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)sendReport:(EmberSnapShot*)snap{
    
    NSString* key = snap.key;
//    NSLog(@"key: %@", key);
    
    NSString *timeStamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
    FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:@"Reports"] child:key] queryLimitedToFirst:100];
    [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
//                NSLog(@"%@  %@", snapShot.key, snapShot.value);
        if([snapShot.value isEqual:[NSNull null]]){
//            NSLog(@"not found");
            [[[self.ref child:@"Reports"] child:key] setValue:@{@"timeStamp" : timeStamp, @"count" : @1}];
            
            [self presentSuccessFulAlert];
            
            
        }else{
//            NSLog(@"found");
            
                [[[[self.ref child:@"Reports"] child:key] child:@"count"] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
                    NSMutableDictionary *post = currentData.value;
                    //        NSLog(@"post: %@", post);
                    if (!post || [post isEqual:[NSNull null]]) {
            //            [[[_ref  child:@"Reports"] child:key]setValue:@{@"timeStamp" : timeStamp, @"count" : @0}];
                        return [FIRTransactionResult successWithValue:currentData];
                    }
            
            
                    int starCount = [currentData.value intValue];
                    starCount++;
                    [currentData setValue:[NSNumber numberWithInt:starCount]];
                    // Set value and report transaction success
                    return [FIRTransactionResult successWithValue:currentData];
                } andCompletionBlock:^(NSError * _Nullable error,
                                       BOOL committed,
                                       FIRDataSnapshot * _Nullable snapshot) {
                    // Transaction completed
                    
                    if (error) {
                        NSLog(@"%@", error.localizedDescription);
                    }else{
                        [self presentSuccessFulAlert];
                    }
                }];
        }
        
        
    }withCancelBlock:^(NSError *_Nonnull error){
        NSLog(@"%@", error.localizedDescription);
    }];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
#pragma mark -
#pragma mark ASTableView.

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
 
    id key = @(section);
    
    HomeFeedHeaderNode *node = nil;
    
        if(section == 0){
            node = _headers[key];
            if (!node) {
                node = [[HomeFeedHeaderNode alloc] initWithOrgInfo:@"UPCOMING"];
                _headers[key] = node;
            }
            
        }else{
            node = _headers[key];
            if (!node) {
                node = [[HomeFeedHeaderNode alloc] initWithOrgInfo:@"PAST"];
                _headers[key] = node;
            }

        }
    
    [node measure:CGSizeMake(tableView.bounds.size.width, FLT_MAX)];
    
    return node.view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    UILabel *noNewPostsLabel = nil;
    
    if(![InternetConnection isConnectedToNetwork] && _data.getNoOfBounceSnapShots == 0 && _dataSection2.getNoOfBounceSnapShots == 0){
        
        if([_activityIndicatorView isAnimating]){
            [_activityIndicatorView stopAnimating];
        }
        // Display a message when the table is empty
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        _messageLabel.text = @"No Internet Connection. Pull down when connected.";
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:20.0f];
        [_messageLabel sizeToFit];
        
        _tableNode.view.backgroundView = _messageLabel;
        _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }else if(_data.getNoOfBounceSnapShots == 0 && _dataSection2.getNoOfBounceSnapShots == 0 && _reloadCalled){
        
        // Display a message when there are no upcoming events or posts for the past week
        
        noNewPostsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        noNewPostsLabel.text = @"No new posts in the past week. Go ahead and make a post!";
        noNewPostsLabel.textColor = [UIColor blackColor];
        noNewPostsLabel.numberOfLines = 0;
        noNewPostsLabel.textAlignment = NSTextAlignmentCenter;
        noNewPostsLabel.font = [UIFont systemFontOfSize:20.0f];
        [noNewPostsLabel sizeToFit];
        
        _tableNode.view.backgroundView = noNewPostsLabel;
        _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    else{
        
        if(_messageLabel != nil){
            _tableNode.view.backgroundView = nil;
            [_messageLabel removeFromSuperview];
            _messageLabel = nil;
        }
        
        if(noNewPostsLabel != nil){
            _tableNode.view.backgroundView = nil;
            [noNewPostsLabel removeFromSuperview];
            noNewPostsLabel = nil;
        }
    }
 
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        // whatever height you'd want for a real section header
        return 22;
    }
    
}

- (ASCellNodeBlock)tableView:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){ // Upcoming Events
 
        EmberSnapShot *snap = [_dataSection2 getBounceSnapShotAtIndex:indexPath.row];
        NSDictionary *eventDetails = [snap getPostDetails];
        
        ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
            EmberNode *bounceNode = [[EmberNode alloc] initWithEvent:snap past:false];
            
            [self setDelegates:bounceNode];
            [self FIRDownload:bounceNode post: eventDetails];
            return bounceNode;
        };
        
        return cellNodeBlock;
        
    }else{
        // Past Events
        EmberSnapShot *snap = [_data getBounceSnapShotAtIndex:indexPath.row];
        NSDictionary *eventDetails = [snap getPostDetails];
        
        ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
            EmberNode *bounceNode = [[EmberNode alloc] initWithEvent:snap past:true];
            
            [self setDelegates:bounceNode];
            [self FIRDownload:bounceNode post: eventDetails];
            return bounceNode;
        };
        
        return cellNodeBlock;
    }


}

-(void)setDelegates:(EmberNode*)bounceNode{
    
    bounceNode.getSuperVideoNode.videolongPressDelegate = self;
    bounceNode.getSuperImageNode.getDetailsNode.delegate = self;
    bounceNode.getSuperVideoNode.delegate = self;
    bounceNode.delegate = self;
    bounceNode.imageDelegate = self;
    bounceNode.longPressDelegate = self;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == 0){
//        NSLog(@"section 1 rows: %lu", _dataSection2.getNoOfBounceSnapShots);
        if([_dataSection2 getNoOfBounceSnapShots] != 0){
            return [_dataSection2 getNoOfBounceSnapShots];
        }
        return 0;
    }else{
//        NSLog(@"section 2 rows: %lu", _data.getNoOfBounceSnapShots);
        if([_data getNoOfBounceSnapShots] != 0){
            return [_data getNoOfBounceSnapShots];
        }
        return 0;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

- (void)tableViewLockDataSource:(ASTableView *)tableView
{
    self.dataSourceLocked = YES;
}

- (void)tableViewUnlockDataSource:(ASTableView *)tableView
{
    self.dataSourceLocked = NO;
}

- (BOOL)shouldBatchFetchForTableView:(UITableView *)tableView
{
    return false;
}

- (void)tableView:(UITableView *)tableView willBeginBatchFetchWithContext:(ASBatchContext *)context{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(1);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            // populate a new array of random-sized kittens
//            NSArray *moarKittens = [self createLitterWithSize:kCageBatchSize];
//            
//            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//            
//            // find number of kittens in the data source and create their indexPaths
//            NSInteger existingRows = _kittenDataSource.count + 1;
//            
//            for (NSInteger i = 0; i < moarKittens.count; i++) {
//                [indexPaths addObject:[NSIndexPath indexPathForRow:existingRows + i inSection:0]];
//            }
//            
//            // add new kittens to the data source & notify table of new indexpaths
//            [_kittenDataSource addObjectsFromArray:moarKittens];
//            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//            
//            [context completeBatchFetching:YES];
//        });
//    });
}

@end

