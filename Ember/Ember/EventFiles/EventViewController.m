//
//  EventViewController.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/20/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import "EventViewController.h"
#import "OrgProfileViewController.h"
#import "EmberOrgNode.h"
#import "FinalEventTitleNode.h"
#import "OrgNode.h"
#import "EmberSnapShot.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASAssert.h>

#import "TitleNode.h"
#import "EmberVideoNode.h"
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import "EmberNode.h"
#import "Ember-Swift.h"


@import Firebase;
@import FirebaseStorage;


@interface EventViewController () <ASTableDataSource, ASTableDelegate, ImageClickedDelegate>
{
    ASTableNode *_tableNode;
    BOOL _dataSourceLocked;
    NSIndexPath *_titleNodeIndexPath;
    NSIndexPath *_orgNodeIndexPath;
    int *count;
    dispatch_queue_t _previewQueue;
    NSString *_orgID;
    NSString *_url;
}
@property (nonatomic, strong) NSString *marker;
@property (nonatomic, strong) NSArray *contents;
@property (atomic, assign) BOOL dataSourceLocked;
@property (strong, nonatomic) FIRDatabaseReference *eventRef;
@property (strong, nonatomic) NSMutableArray<EmberSnapShot *> *snapShots;
@property (strong, nonatomic) FIRStorage *storage;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) FIRDatabaseReference *orgsRef;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *orgs;


@end

@implementation EventViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Event Details";
    self.navigationController.navigationBar.tintColor = [BounceConstants primaryAppColor];
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openOrgProfile:)
                                                 name:@"OrgPhotoClicked"
                                               object:nil];
    
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    self.eventRef = [[self.ref child:@"Bounce"] child:@"Events"];
    
    _storage = [FIRStorage storage];
    _storageRef = [_storage referenceForURL:@"gs://ember-beaa6.appspot.com"];
    _previewQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
   
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableNode.view.allowsSelection = NO;
    
    _titleNodeIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    _orgNodeIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    
    
    _snapShots = [[NSMutableArray alloc] init];
    
//    NSLog(@"eventNode: %@", self.eventNode.getPostDetails);
    
    
    [self fetchData];
    
}


-(void)fetchData{
//    NSLog(@"eventID: %@", self.eventNode.getPostDetails);
    
    NSString *homefeedKey = self.eventNode.key;
    
    FIRDatabaseQuery *recentPostsQuery = [[self.ref child:[BounceConstants firebaseHomefeed]] child:homefeedKey];
    [recentPostsQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
        
        EmberSnapShot *newSnap = [[EmberSnapShot alloc] initWithSnapShot:snapShot];
        
        [_snapShots addObject:newSnap];
        
        NSString *eventID = self.eventNode.getPostDetails[@"eventID"];
        FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:[BounceConstants firebaseHomefeed]] queryOrderedByChild:@"postDetails/eventID"] queryEqualToValue:eventID];
        [recentPostsQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
            //        NSLog(@"%@  %@", snapShot.key, snapShot.value);
            
            for(FIRDataSnapshot* child in snapShot.children){
                
                
                EmberSnapShot *snap = [[EmberSnapShot alloc] initWithSnapShot:child];
                
                // Assumption is that there is only one event poster so any poster matching this event ID is the poster that
                // was clicked from the homefeed and whose details are populating the first node of this page i.e. self.eventNode
                
                if(![snap isEventPoster]){
                    [self.snapShots addObject:snap];
                }
                
            }
            
            // TODO : reloading is causing jitter
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableNode.view reloadData];
            });
        }];
        
        
    }];
    
    
    
    
   
}

-(void)openOrgProfile:(NSNotification *) notification{
        FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:@"Organizations"] child:_orgID]  queryLimitedToFirst:100];
        [[recentPostsQuery queryOrderedByKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
            NSDictionary * org = snapShot.value;
            //NSLog(@"this is the name %@", org[@"orgName"]);
            NSLog(@"My dictionary is %@", org);
            OrgProfileViewController *_orgController = [OrgProfileViewController new];
            _orgController.orgId = _orgID;
            [[self navigationController] pushViewController:_orgController animated:YES];
            }];
}


-(void)childNode:(EmberNode *)childImage didClickImage:(UIImage *)image withLinks:(NSArray *)array{
    GalleryImageProvider *provider = [[GalleryImageProvider alloc] init];
    
    [provider setUrls:array];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 24);
    
    CounterView *headerView = [[CounterView alloc] initWithFrame:frame node:childImage currentIndex:0 count:array.count index:0 mediaInfo : array];
    CounterView *footerView = [[CounterView alloc] initWithFrame:frame node:childImage currentIndex:0 count:array.count index:1 mediaInfo:array];
    
    GalleryViewController *galleryViewController  = [[GalleryViewController alloc] init];
    
    [galleryViewController setImageProvider:provider];
    [galleryViewController setDisplacedView:childImage.getSubImageNode.view];
    [galleryViewController setImageCount:array.count];
    [galleryViewController setStartIndex:0];
    [galleryViewController intializeTransitions];
    [galleryViewController completeInit];
    galleryViewController.headerView = headerView;
    galleryViewController.footerView = footerView;
    
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)toggleEditingMode
{
    [_tableNode.view setEditing:!_tableNode.view.editing animated:YES];
}

- (NSDictionary *)textStyle{
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.5 * font.lineHeight;
    style.alignment = NSTextAlignmentRight;
    
    
    return @{ NSFontAttributeName: font,
              NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: style};
}

-(void)fetchOrgProfilePhotoUrl:(NSString*) orgId node:(FinalEventTitleNode*) node{
    
    FIRDatabaseQuery *recentPostsQuery = [[[self.ref child:@"Organizations"] child:orgId]  queryLimitedToFirst:100];
    [[recentPostsQuery queryOrderedByKey] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
//        NSLog(@"%@  %@", snapShot.key, snapShot.value);
        NSDictionary * event = snapShot.value;
//        NSLog(@"%@", event[@"smallImageLink"]);
     
        dispatch_async(dispatch_get_main_queue(), ^{
            node.getTitleNode.getOrgNameNode.attributedString = [[NSAttributedString alloc] initWithString:event[@"orgName"] attributes:[self textStyle]];
            node.getLocalNode.URL = [NSURL URLWithString:event[@"smallImageLink"]];
            
            
        });
    }];
}


-(void)FIRTitleDownload:(FinalEventTitleNode*)node url:(NSString*)url orgId:(NSString*)orgId event:(NSDictionary *)event{
    
    if(![url containsString:@"http"]){
        
        FIRStorageReference *ref = [_storageRef child:url];
        
        // Fetch the download URL
        [ref downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (error != nil) {
                
            } else {
                // Get the download URL
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    node.getTitleNode.getImageNode.URL = URL;
//                    node.getLocalNode.URL = [NSURL URLWithString:url];
                });
                
            }
        }];
    }else{
        
        node.getTitleNode.getImageNode.URL = [NSURL URLWithString:url];
//        node.getLocalNode.URL = [NSURL URLWithString:url];
    }
    
    [self fetchOrgProfilePhotoUrl:orgId node:node];
    
    
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


#pragma mark -
#pragma mark ASTableView.


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

- (ASCellNodeBlock)tableView:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_titleNodeIndexPath compare:indexPath] == NSOrderedSame) {
        EmberSnapShot* snapShot = _snapShots[indexPath.row];
        NSDictionary *eventDetails = [snapShot getPostDetails];
        
        ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
            FinalEventTitleNode *bounceNode = [[FinalEventTitleNode alloc] initWithEvent:snapShot];
            _orgID = eventDetails[@"orgID"];
            [self FIRTitleDownload:bounceNode url: eventDetails[@"eventPosterLink"] orgId: eventDetails[@"orgID"] event:eventDetails];
            return bounceNode;
        };
        
        return cellNodeBlock;
    }
    
    EmberSnapShot* snapShot = _snapShots[indexPath.row];
    NSDictionary *event = [snapShot getPostDetails];
    
    ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
        EmberNode *bounceNode = [[EmberNode alloc] initWithEvent:snapShot past:false];
        bounceNode.delegate = self;
        [self FIRDownload:bounceNode post: event];
        
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
    return false;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
