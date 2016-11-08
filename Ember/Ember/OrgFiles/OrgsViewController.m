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
#import "FollowNode.h"

#import "Ember-Swift.h"


@import Firebase;

@interface OrgsViewController () <ASTableDataSource, ASTableDelegate, FindOrgsImageClickedDelegate, FindOrgsFollowButtonClickedDelegate>
{
    ASTableNode *_tableNode;
    dispatch_queue_t _previewQueue;
    FIRDataSnapshot *_snapShot;
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
    
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    _user = [[EmberUser alloc] init];
    
    _orgs = [[EmberSnapShot alloc] init];

    [self fetchData];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Create" style: UIBarButtonItemStylePlain target:self action:@selector(openCreateOrgViewController)];
    
    self.navigationItem.rightBarButtonItem = btn;
}

-(void)openCreateOrgViewController
{
    CreateOrgViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"createOrg"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)findOrgsFollowButtonClicked:(EmberSnapShot *)snap{
    
    NSUInteger count = 0;
    
    for(NSUInteger i = 0; i < _orgs.getNoOfBounceSnapShots; i++){
        if([snap isEqual:[_orgs getBounceSnapShotAtIndex:i]]){
            
            [_tableNode.view beginUpdates];
            [_orgs removeSnapShotAtIndex:count];
            NSIndexPath *path = [NSIndexPath indexPathForRow:count inSection:0];
            [_tableNode.view deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
            [_tableNode.view endUpdates];
            return;
        }
        count++;
    }
}


-(void)findOrgsImageClicked:(NSString *)orgId{
    OrgProfileViewController *_myViewController = [OrgProfileViewController new];
    _myViewController.orgId = orgId;
    [[self navigationController] pushViewController:_myViewController animated:YES];
}

-(void)fetchData{
    
    [_activityIndicatorView startAnimating];
    
    [_user loadUserInfo:^(NSDictionary* completion){
        
        NSDictionary *userPrefs = completion[@"userPreferences"];
        _user.userPreferences = [userPrefs allKeys];
        
        if(completion[@"orgsFollowed"]){
            _user.orgsFollowed = [completion[@"orgsFollowed"] allKeys];
        }
        
        FIRDatabaseQuery *orgsQuery = [self.ref child:[BounceConstants firebaseOrgsChild]];
        [[orgsQuery queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapShot){
            
            NSDictionary *val = snapShot.value;
            
            NSInteger count = 0;
            
            NSUInteger prefsCount = 0;
            
            for(FIRDataSnapshot* child in snapShot.children){
                
                if([_orgs shouldAddOrgsSnapShot:child user:_user]){
                    
                    [_activityIndicatorView stopAnimating];
                    
                    if(val[@"preferences"]){
                        //                    NSLog(@"past: %@", val[@"preferences"]);
                        NSArray *prefs = [val[@"preferences"] allKeys];
                        
                        if([_user matchesUserPreferences:prefs]){ // Add orgs that match prefs at top of list
                            
                            [self updateTableAtIndex:prefsCount count:count snap:child];
                            prefsCount++;
 
                            
                        }else{
                            [self updateTable:count snap:child];
                            
                        }
                        
                       
                    }else{
                        [self updateTable:count snap:child];
                       
                    }
                    
                    count++;
                }
 
                
            }
            
            if(_activityIndicatorView.isAnimating){
                [_activityIndicatorView stopAnimating];
            }
            
            
        }];
        
    }];
    
}

-(void)updateTableAtIndex:(NSUInteger)index count:(NSUInteger)count snap:(FIRDataSnapshot*)child{
    
    [_tableNode.view beginUpdates];
    [_orgs addOrgToIndex:child index:index];
    NSIndexPath *path = [NSIndexPath indexPathForRow:count inSection:0];
    [_tableNode.view insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
    [_tableNode.view endUpdates];
}

-(void)updateTable:(NSUInteger)count snap:(FIRDataSnapshot*)child{
    
    [_tableNode.view beginUpdates];
    [_orgs addOrgSnap:child];
    NSIndexPath *path = [NSIndexPath indexPathForRow:count inSection:0];
    [_tableNode.view insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
    [_tableNode.view endUpdates];
    
}


- (ASCellNodeBlock)tableView:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EmberSnapShot* snapShot = [_orgs getBounceSnapShotAtIndex:indexPath.row];
    ASCellNode *(^cellNodeBlock)() = ^ASCellNode *() {
        EmberOrgNode *bounceOrgNode = [[EmberOrgNode alloc] initWithOrg:snapShot];
        bounceOrgNode.findOrgsImageClickedDelegate = self;
        bounceOrgNode.getFollowNode.findOrgsFollowButtonClickedDelegate = self;
        return bounceOrgNode;
    };
    
    return cellNodeBlock;
    
}

#pragma mark -
#pragma mark ASTableView.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_orgs.getNoOfBounceSnapShots != 0){
//        NSLog(@"count: %lu", _orgs.getNoOfBounceSnapShots);
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

@end
