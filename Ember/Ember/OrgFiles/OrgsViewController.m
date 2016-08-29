//
//  OrgsViewController.m
//  bounceapp
//
//  Created by Gabriel Wamunyu on 6/17/16.
//  Copyright © 2016 Anthony Wamunyu Maina. All rights reserved.
//

#import "OrgsViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "EmberOrgNode.h"
#import "EmberSnapShot.h"

#import "Ember-Swift.h"


@import Firebase;

@interface OrgsViewController () <ASTableDataSource, ASTableDelegate>
{
    ASTableNode *_tableNode;
    dispatch_queue_t _previewQueue;
    FIRDataSnapshot *_snapShot;
    BOOL _dataSourceLocked;
    EmberSnapShot*_orgs;
    EmberUser *_user;
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (strong, nonatomic) FIRDatabaseReference *orgsRef;
@property (atomic, assign) BOOL dataSourceLocked;

@end

@implementation OrgsViewController

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

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] referenceWithPath:[BounceConstants firebaseSchoolRoot]];
    self.orgsRef = [self.ref child:[BounceConstants firebaseOrgsChild]];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGSize boundSize = self.view.bounds.size;
    
    [_activityIndicatorView sizeToFit];
    
    CGRect refreshRect = _activityIndicatorView.frame;
    refreshRect.origin = CGPointMake((boundSize.width - _activityIndicatorView.frame.size.width) / 2.0,
                                     (boundSize.height - _activityIndicatorView.frame.size.height) / 2.0);
    _activityIndicatorView.frame = refreshRect;
    
    [self.view addSubview:_activityIndicatorView];
    
    _previewQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
  
    _user = [[EmberUser alloc] init];
    
    _orgs = [[EmberSnapShot alloc] init];

    [self fetchData];
}

-(void)fetchData{
    
    [_activityIndicatorView startAnimating];
    
    [_user loadPreferences:^(NSDictionary* completion){
        
        FIRDatabaseQuery *recentPostsQuery = [[self.ref child:[BounceConstants firebaseOrgsChild]] queryLimitedToFirst:100];
        [[recentPostsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
            
            NSInteger count = 0;
            for(FIRDataSnapshot* child in snapShot.children){
                
                
                if([_orgs addOrgsSnapShot:child user:_user]){
                    
                    [_activityIndicatorView stopAnimating];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableNode.view beginUpdates];
                        [_tableNode.view insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        [_tableNode.view endUpdates];
                    });
                    
                     count++;
                }
 
 
            }
            
            if(_activityIndicatorView.isAnimating){
               [_activityIndicatorView stopAnimating]; 
            }
            
            
        }];
    }];
    
}


- (ASCellNodeBlock)tableView:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EmberSnapShot* snapShot = [_orgs getBounceSnapShotAtIndex:indexPath.row];
    ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
        EmberOrgNode *bounceOrgNode = [[EmberOrgNode alloc] initWithOrg:snapShot];
        return bounceOrgNode;
    };
    
    return cellNodeBlock;
    
}

#pragma mark -
#pragma mark ASTableView.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_orgs.getNoOfBounceSnapShots != 0){
        NSLog(@"count: %lu", _orgs.getNoOfBounceSnapShots);
//        NSLog(@"count_2: %lu", [_orgs objectAtIndex:0].childrenCount);
        return _orgs.getNoOfBounceSnapShots;
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return false;
}

- (BOOL)shouldBatchFetchForTableView:(UITableView *)tableView
{
    return false;
}
- (void)tableViewLockDataSource:(ASTableView *)tableView
{
    self.dataSourceLocked = YES;
}

- (void)tableViewUnlockDataSource:(ASTableView *)tableView
{
    self.dataSourceLocked = NO;
}

@end
