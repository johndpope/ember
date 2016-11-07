//
//  MyEventsViewController.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/19/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import "MyEventsViewController.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASAssert.h>

#import "TitleNode.h"
#import "EmberVideoNode.h"
#import "OrgProfileViewController.h"
#import "EventViewController.h"
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import "MyEventsNode.h"
#import "MyEventsPostDetailsNode.h"

#import "Ember-Swift.h"


@import Firebase;
@import FirebaseStorage;

@interface MyEventsViewController () <ASTableDataSource, ASTableDelegate, MyEventsNodeDelegate, MyEventsOrgImageClickedDelegate, MyEventsImageClickedDelegate, MyEventsCameraClickedDelegate>
{
    ASTableNode *_tableNode;
    FIRDataSnapshot *_snapShot;
    BOOL _dataSourceLocked;
    NSIndexPath *_noEventsFollowedNodeIndexPath;
    int *count;
    dispatch_queue_t _previewQueue;
    NSString *_url;
    int _lastFireCount;
    EmberSnapShot *_data;
    BOOL _reloadCalled;
    
    
}
@property (nonatomic, strong) NSString *marker;
@property (nonatomic, strong) NSArray *contents;
@property (atomic, assign) BOOL dataSourceLocked;
@property (strong, nonatomic) FIRDatabaseReference *eventRef;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *comments;
@property (strong, nonatomic) FIRStorage *storage;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) FIRDatabaseReference *userRef;

@property(nonatomic, strong) NSMutableDictionary *headers;

@end

@implementation MyEventsViewController

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
    
    
    
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                    FIRUser *_Nullable user) {
        if (user != nil) {
            // User is signed in.
            NSLog(@"user is signed in");
        } else {
            // No user is signed in.
            NSLog(@"user is NOT signed in");
        }
    }];
    
    _reloadCalled = NO;
    
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _userRef = [[FIRDatabase database] reference];

    _data = [[EmberSnapShot alloc] init];
    
    _storage = [FIRStorage storage];
    _storageRef = [_storage referenceForURL:[BounceConstants firebaseStorageUrl]];
    
    _previewQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _noEventsFollowedNodeIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    _comments = [[NSMutableArray alloc] init];
    
    _headers = [[NSMutableDictionary alloc] init];
    
    [self fetchData];
  
}

-(FIRDatabaseReference*)getHomeFeedPostReference:(NSString*)key{
    return [[[_ref child:[BounceConstants firebaseHomefeed]] child:key] child:@"fireCount"];
}

-(void)decreaseFireCount:(NSString*)key{
    
    [[self getHomeFeedPostReference:key] runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSMutableDictionary *post = currentData.value;
        if (!post || [post isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        
        int starCount = [currentData.value intValue];
        starCount--;
        
        // Set value and report transaction success
        [currentData setValue:[NSNumber numberWithInt:starCount]];
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError * _Nullable error,
                           BOOL committed,
                           FIRDataSnapshot * _Nullable snapshot) {
        // Transaction completed
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

-(void)myEventsImageClicked:(EmberSnapShot *)snap{
    NSDictionary *eventDetails = [snap getPostDetails];
//    NSLog(@"snap: %@", eventDetails);
    NSString *url = eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]];
    if(![url containsString:@"mp4"]  || [url containsString:@"mov"] ){
        EventViewController *_myViewController = [EventViewController new];
        _myViewController.eventNode = snap;
        [[self navigationController] pushViewController:_myViewController animated:YES];
    }
    
}

-(void)orgClicked:(NSString *)orgId{
    OrgProfileViewController *_myViewController = [OrgProfileViewController new];
    _myViewController.orgId = orgId;
//    _myViewController.orgId = @"-KKUoplzAOneZ0AqbpxA";
    [[self navigationController] pushViewController:_myViewController animated:YES];
    
}

-(void)unfollow:(NSString*)snapshotKey{
    
    NSLog(@"unfollow: %@", snapshotKey);
    
    FIRUser *user = [FIRAuth auth].currentUser;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAppSettingsChanged" object:self userInfo:nil];
    
    [[[[[_userRef child:[BounceConstants firebaseUsersChild]] child:user.uid] child:[BounceConstants firebaseUsersChildEventsFollowed]] child:snapshotKey] removeValue];
    
    [self decreaseFireCount:snapshotKey];

    
}

-(void)openCamera:(NSString *)eventId eventDate:(NSString *)eventDate eventTime:(NSString *)eventTime orgId:(NSString *)orgId homefeedMediaKey:(NSString *)homefeedMediaKey orgProfileImage:(NSString *)orgProfileImage eventDateObject:(NSNumber*)eventDateObject eventName:(NSString *)eventName{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CameraViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [myViewController initWithEventID:eventId mEventDate:eventDate mEventName:eventName mEventTime:eventTime mOrgID:orgId mHomefeedMediaKey:homefeedMediaKey mOrgProfImage:orgProfileImage mEventDateObject:eventDateObject];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:myViewController];
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)unfollowClicked:(NSString *)snapshotKey{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"Are you sure you want to unfollow?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:@"Yes"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [self unfollow:snapshotKey];
                          }];
    
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:@"No"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    
    [alert addAction:yes];
    [alert addAction:no];
    
    if([self presentedViewController] == nil){
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(FIRDatabaseReference*)getUsersReference{
    return [_userRef child:[BounceConstants firebaseUsersChild]];
}


-(void)fetchData{
    
    FIRUser *user = [FIRAuth auth].currentUser;
    
    NSDate *now = [NSDate date];
    NSString *nowInMillis = [NSString stringWithFormat:@"%f",[now timeIntervalSince1970]];
    NSNumber *numNowInMillis = [NSNumber numberWithDouble:[nowInMillis doubleValue]];
    
    [[[[_userRef child:[BounceConstants firebaseUsersChild]] child:user.uid] child:[BounceConstants firebaseUsersChildEventsFollowed]]
     observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *firstSnap){
         
//         NSLog(@"first: %@", firstSnap);
         FIRDatabaseQuery *query = [[self.ref child:[BounceConstants firebaseHomefeed]] child:firstSnap.key];
         [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *second){
             
             NSDictionary *val = second.value;
//             NSLog(@"first: %@", second);
             NSDictionary *postDetails = val[@"postDetails"];
             NSNumber *time = postDetails[@"eventDateObject"];
             NSString *orgID = postDetails[@"orgID"];
             
             NSNumber *endTime  = nil;
             if(postDetails[@"endEventDateObject"]){
                 endTime = postDetails[@"endEventDateObject"];
             }
             // Only adding UPCOMING events
             if(-[endTime doubleValue] < [numNowInMillis doubleValue]){
                 
                 // NOTE: If one selects, deselects and reselects an event in the homefeed, the below NSLog shows that
                 // the fireCount is not obtained due to a transaction update happening on the fireCount child
                 // Therefore, the count is not displayed in MyEvents
//                 NSLog(@"second: %@", second);
                 [_data addMyEventsSnapShot:second key:firstSnap.key];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //                 NSLog(@"reload");
                     _reloadCalled = YES;
                     [_tableNode.view reloadData];
                 });
             }
             
         }];
         
     }];
    
    // NOTE: Needed since the event type above (child added) only fires if a value exists in the tree
    if(_data.getNoOfBounceSnapShots == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            _reloadCalled = YES;
            [_tableNode.view reloadData];
        });
    }
    

    
    // Listen for deleted comments in the Firebase database
    [[[[_userRef child:[BounceConstants firebaseUsersChild]] child:user.uid] child:[BounceConstants firebaseUsersChildEventsFollowed]]
     observeEventType:FIRDataEventTypeChildRemoved
     withBlock:^(FIRDataSnapshot *snapshot) {
         int counter = 0;
         
         if([snapshot.value isEqual:[NSNull null]]){
             return;
         }
         
         for(int i = 0; i < _data.getNoOfBounceSnapShots; i++){
             counter++;
             EmberSnapShot *snap = [_data getBounceSnapShotAtIndex:i];
             if([snap.key isEqualToString:snapshot.key]){
                 break;
             }
         }
 
         dispatch_async(dispatch_get_main_queue(), ^{
              [_data removeSnapShotAtIndex:counter - 1];
             [_tableNode.view reloadData];
         });
 
     }];
    

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)toggleEditingMode
{
//    [_tableView setEditing:!_tableView.editing animated:YES];
}

-(void)FIRDownload:(MyEventsNode*)node url:(NSString*)url{
    
    if(![url containsString:@"http"]){
        
        FIRStorageReference *ref = [_storageRef child:url];
        
        // Fetch the download URL
        [ref downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (error != nil) {
                
            } else {
                // Get the download URL
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    node.getImageNode.URL = URL;
                    
                });
                
            }
        }];
    }else{
        
        node.getImageNode.URL = [NSURL URLWithString:url];
    }
    
}


#pragma mark -
#pragma mark ASTableView.


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    id key = @(section);
    
    HomeFeedHeaderNode *node = nil;
    
        node = _headers[key];
        if (!node) {
            node = [[HomeFeedHeaderNode alloc] initWithOrgInfo:@"UPCOMING"];
            _headers[key] = node;
        }
    
    
    [node measure:CGSizeMake(tableView.bounds.size.width, FLT_MAX)];
    
    return node.view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmberSnapShot *snap = [_data getBounceSnapShotAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self myEventsImageClicked:snap];
    
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
    
    if([_noEventsFollowedNodeIndexPath compare:indexPath] == NSOrderedSame && _reloadCalled && _data.getNoOfBounceSnapShots == 0){
        ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
            return [[NoEventsFollowedNode alloc] init];
        };
        
        return cellNodeBlock;
    }
    
    EmberSnapShot *snap = [_data getBounceSnapShotAtIndex:indexPath.row];
    NSDictionary *eventDetails = snap.getFirebaseSnapShot.value[[BounceConstants firebaseHomefeedPostDetails]];
    
//    NSLog(@"details: %@", eventDetails);
    
    ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
        MyEventsNode *bounceNode = [[MyEventsNode alloc] initWithEvent:snap];
        
        bounceNode.getDetailsNode.myEventsNodeDelegate = self;
        bounceNode.getDetailsNode.myEventsOrgImageDelegate = self;
        bounceNode.myEventsImageDelegate = self;
        bounceNode.getDetailsNode.myEventsCamerClickedDelegate = self;
        
        [self FIRDownload:bounceNode url: eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]]];
        
        return bounceNode;
    };
    
    return cellNodeBlock;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(_data.getNoOfBounceSnapShots != 0){
        return _data.getNoOfBounceSnapShots;
    }
    if(_reloadCalled){
        return 1;
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return false;
}

@end
