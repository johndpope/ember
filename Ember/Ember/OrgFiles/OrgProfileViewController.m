//
//  OrgProfileViewController.m
//  bounceapp
//
//  Created by Michael Umenta on 7/11/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import "OrgProfileViewController.h"
#import "EventViewController.h"

#import "Ember-Swift.h"

#import "SubOrgTitleNode.h"
#import "FinalOrgTitleNode.h"
#import "OrgNode.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASAssert.h>

#import "TitleNode.h"
#import "EmberVideoNode.h"
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import "EmberNode.h"



@import Firebase;
@import FirebaseStorage;


@interface OrgProfileViewController () <ASTableDataSource, ASTableDelegate, OpenCreateEventDelegate, ImageClickedDelegate, BounceImageClickedDelegate>
{
    ASTableNode *_tableNode;
    BOOL _dataSourceLocked;
    NSIndexPath *_titleNodeIndexPath;
    dispatch_queue_t _previewQueue;
    NSString *_url;
    EmberSnapShot *_orgInfo;
    BOOL isAdmin;
    FIRDatabaseReference *_usersRef;

}

@property (atomic, assign) BOOL dataSourceLocked;
@property (strong, nonatomic) NSMutableArray<EmberSnapShot *> *snapShots;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) FIRStorage *storage;

@end

@implementation OrgProfileViewController


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
    
    self.navigationController.navigationBar.tintColor = [BounceConstants primaryAppColor];
    
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    _usersRef = [[FIRDatabase database] reference];
    
    _storage = [FIRStorage storage];
    _storageRef = [_storage referenceForURL:[BounceConstants firebaseStorageUrl]];
    _previewQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
 
    _tableNode.view.allowsSelection = NO;
    
    _titleNodeIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    EmberUser *user = [EmberUser new];
    
    isAdmin = NO;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
//                                                                                           target:self
//                                                                                           action:@selector(toggleEditingMode)];
//    isAdmin = YES;
    
    _snapShots = [[NSMutableArray alloc] init];
    //        [self fetchData];
    
    [user isAdminOf:self.orgId completionHandler:^(BOOL completionHandler){
       
        
        if(completionHandler){
            isAdmin = YES;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                                   target:self
                                                                                                   action:@selector(openEditOrgViewController)];
            
            [self fetchOrgProfilePhotoUrl:self.orgId];
        }else{
            [self fetchOrgProfilePhotoUrl:self.orgId];
        }
    }];
    
    
}

-(void)bounceImageClicked:(EmberSnapShot *)snap{
    NSDictionary *eventDetails = [snap getPostDetails];
    NSString *url = eventDetails[[BounceConstants firebaseHomefeedEventPosterLink]];
    if(![url containsString:@"mp4"]  || [url containsString:@"mov"] ){
        EventViewController *_myViewController = [EventViewController new];
        _myViewController.eventNode = snap;
        [[self navigationController] pushViewController:_myViewController animated:YES];
    }
}

/**
 *  Delegate method called when user clicks on gallery
 *
 *  @param childImage First node with the associated info. Used for acquiring view for first image
 *  @param image      First image clicked
 *  @param array      Array with all the info under 'mediaInfo' of firebase tree
 */
-(void)childNode:(EmberNode *)childImage didClickImage:(UIImage *)image withLinks:(NSArray *)array withHomeFeedID:(NSString *)homefeedID{
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


-(void)openCreateEventViewController:(NSString *)orgID orgName:(NSString *)orgName orgProfileImage:(NSString *)orgProfileImage{

    CreateEventViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"createEvent"];
        vc.orgID = orgID;
        vc.orgName = orgName;
        vc.orgProfileImage = orgProfileImage;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)openEditOrgViewController
{
    EditOrgViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"editOrg"];
    vc.orgId = self.orgId;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)fetchOrgProfilePhotoUrl:(NSString*) orgId{
    
//    FIRDatabaseReference *reference = [[FIRDatabase database] reference];
//    NSLog(@"orgid: %@", orgId);
    // TODO change this to school root
    FIRDatabaseQuery *recentPostsQuery = [[_ref child:[BounceConstants firebaseOrgsChild]] child:orgId];
    [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
//        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        EmberSnapShot *snap = [[EmberSnapShot alloc] initWithSnapShot:snapShot];
        _orgInfo = snap;
      
        [self.snapShots addObject:_orgInfo];
        self.navigationController.navigationBar.topItem.title = @"Org Details";
        [self fetchData];
        
    }withCancelBlock:^(NSError *_Nonnull error){
        NSLog(@"%@", error.localizedDescription);
    }];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)toggleEditingMode
{
    [_tableNode.view setEditing:!_tableNode.view.editing animated:YES];
    
}

-(void)FIRDownload:(EmberNode*)node url:(NSString*)url orgId:(NSString*)orgId event:(NSDictionary *)event{
    
    
    if(![url containsString:@"http"]){
        
        FIRStorageReference *ref = [_storageRef child:url];
        
        // Fetch the download URL
        [ref downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (error != nil) {
                
            } else {
                // Get the download URL
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([[url pathExtension] isEqualToString:@"mp4"] || [[url pathExtension] isEqualToString:@"mov"]){
                        node.getSubVideoNode.asset = [AVAsset assetWithURL:URL];
                        
                    }else{
                        
                        node.getSubImageNode.URL = URL;
                        
                    }
                    
                    
                });
                
            }
        }];
    }else{
        
        node.getSubImageNode.URL = [NSURL URLWithString:url];
    }
    
    
}

- (NSDictionary *)textStyle{
    
    UIFont *font = nil;
    
    if(Iphone5Test.isIphone5){
        font = [UIFont systemFontOfSize:8.0f];
    }else{
        font = [UIFont systemFontOfSize:10.0f];
    }

    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentRight;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: style};
}

-(void)fetchOrgEvents{
    
}

-(void)fetchData{
    
    FIRDatabaseQuery *recentPostsQuery = [[[_ref child:[BounceConstants firebaseHomefeed]] queryOrderedByChild:@"postDetails/orgID"]  queryEqualToValue:self.orgId];
    [recentPostsQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
//        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        dispatch_async(dispatch_get_main_queue(), ^{
            for(FIRDataSnapshot* child in snapShot.children){
                EmberSnapShot *snap = [[EmberSnapShot alloc] initWithSnapShot:child];
                [self.snapShots addObject:snap];
            }
            
            [_tableNode.view reloadData];
//            NSLog(@"passed reload");
        });
        
    }];
    
}

-(void)FIRDownload:(EmberNode*)node post:(NSDictionary*)post{
    
    NSString *url = nil;
    
    if(post[[BounceConstants firebaseHomefeedEventPosterLink]] != nil){
        url = post[[BounceConstants firebaseHomefeedEventPosterLink]];
    }else{
        NSArray *values = [post[[BounceConstants firebaseHomefeedMediaInfo]] allValues];
        if ([values count] != 0){
            NSDictionary *first = [values objectAtIndex:0];
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

-(void)FIRTitleDownload:(FinalOrgTitleNode*)node url:(NSString*)url{
    
    if(![url containsString:@"http"]){
        
        FIRStorageReference *ref = [_storageRef child:url];
        
        // Fetch the download URL
        [ref downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (error != nil) {
                
            } else {
                // Get the download URL
                dispatch_async(dispatch_get_main_queue(), ^{
                    node.getSubOrgTitleNode.getImageNode.URL = URL;
                });
                
            }
        }];
    }else{
        node.getSubOrgTitleNode.getImageNode.URL = [NSURL URLWithString:url];
    }
   
}

// TODO: allow deletion of individual gallery items
-(void)deletePost:(NSUInteger)row{
    
    NSString *key = _snapShots[row].key;
    NSString *userId = [[[FIRAuth auth] currentUser] uid];
    
    NSDictionary *snap = _snapShots[row].getPostDetails;
    
    // If event poster
    if(snap[[BounceConstants firebaseHomefeedEventPosterLink]]){
        
        // Get event ID for deleting event from Event Tree
        FIRDatabaseQuery *eventIdQuery = [[[[_ref child:[BounceConstants firebaseHomefeed]] child:key] child:@"postDetails"] child:@"eventID"];
        [eventIdQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
            //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
            
            
            NSString *eventID = snapShot.value;
            [[[_ref child:[BounceConstants firebaseEventsChild]] child:eventID] removeValue]; // delete from Events Tree
            [[[_ref child:[BounceConstants firebaseHomefeed]] child:key] removeValue]; // delete from HomeFeed
            [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:userId] child:@"eventsFollowed"] child:key] removeValue]; // delete from current user's (admin) eventsFollowed tree
            
        }];
    }else{ // Is gallery image or video
        
        [[[_ref child:[BounceConstants firebaseHomefeed]] child:key] removeValue]; // delete entire gallery or video from HomeFeed
        [[[[[_usersRef child:[BounceConstants firebaseUsersChild]] child:userId] child:@"HomeFeedPosts"] child:key] removeValue]; // delete from current user's HomeFeedPosts. Only works if user made post
    }
    
    
}

#pragma mark -
#pragma mark ASTableView.

- (ASCellNodeBlock)tableView:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_titleNodeIndexPath compare:indexPath] == NSOrderedSame) {
        NSDictionary *orgDetails = [_snapShots[indexPath.row] getData];
        
        ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
            FinalOrgTitleNode *bounceNode = [[FinalOrgTitleNode alloc] initWithEvent:_snapShots[indexPath.row]];
            //        NSLog(@"key: %@", _snapShots[indexPath.row].key);
            bounceNode.orgID = self.orgId;
            bounceNode.getSubOrgTitleNode.getOrgDetailsNode.delegate = self;
            [bounceNode.getSubOrgTitleNode.getOrgDetailsNode setAdminStatus:isAdmin];
            [bounceNode.getSubOrgTitleNode setAdminStatus:isAdmin];
            [self FIRTitleDownload:bounceNode url: orgDetails[[BounceConstants firebaseOrgsChildLargeImageLink]]];
            return bounceNode;
        };
        
        return cellNodeBlock;
        
        
    }
    
    
   
    EmberSnapShot* snapShot = _snapShots[indexPath.row];
    NSDictionary *eventDetails = [snapShot getPostDetails];
    
    NSDate *now = [NSDate date];
    
    NSString *nowInMillis = [NSString stringWithFormat:@"%f",[now timeIntervalSince1970]];
    NSNumber *numNowInMillis = [NSNumber numberWithDouble:[nowInMillis doubleValue]];
    
    NSDictionary *val = [snapShot getData];
    
    
    ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
        NSDictionary *postDetails = val[@"postDetails"];
        NSNumber *time = postDetails[@"eventDateObject"];
        
        EmberNode *bounceNode = nil;
        
        if(-[time doubleValue] < [numNowInMillis doubleValue]){
            
            bounceNode = [[EmberNode alloc] initWithEvent:snapShot];
            bounceNode.delegate = self;
            bounceNode.imageDelegate = self;
            
            
        }else{
            bounceNode = [[EmberNode alloc] initWithEvent:snapShot];
            bounceNode.delegate = self;
            bounceNode.imageDelegate = self;
            
        }
        
        [self FIRDownload:bounceNode post: eventDetails];
        
        return bounceNode;
    };
    
    return cellNodeBlock;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(_snapShots.count != 0){
        return _snapShots.count;
        
    }
    return 0;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_titleNodeIndexPath compare:indexPath] != NSOrderedSame && isAdmin;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController * alert =   [UIAlertController
                                       alertControllerWithTitle:@"Are you sure you want to delete this post?"
                                       message:nil
                                       preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* yes = [UIAlertAction
                              actionWithTitle:@"Yes"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self deletePost:indexPath.row];
                                  [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                              }];
        
        UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:yes];
        [alert addAction:cancel];
        
        if([self presentedViewController] == nil){
            [self presentViewController:alert animated:YES completion:nil];
        }

    }
}
@end
