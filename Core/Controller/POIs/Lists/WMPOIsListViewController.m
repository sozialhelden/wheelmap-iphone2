//
//  WMListViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMPOIsListViewController.h"
#import "WMNodeListCell.h"
#import "Node.h"
#import "NodeType.h"
#import "WMNavigationControllerBase.h"
#import <CoreLocation/CoreLocation.h>
#import "WMDataManager.h"
#import "WMPOIIPadNavigationController.h"
#import "WMNodeListView.h"
#import "WMResourceManager.h"
#import "WMMapViewController.h"

@implementation WMPOIsListViewController
{
    NSArray *nodes;
    
    UIImageView* accesoryHeader;
    BOOL isAccesoryHeaderVisible;
    
    BOOL shouldShowNoResultIndicator;
    
    WMDataManager *dataManager;
    WMMapViewController *mapView;
    WMLabel* headerLabel;
    
    BOOL searching;
    BOOL receivedClearList;
    
    dispatch_queue_t backgroundQueue;
}

@synthesize dataSource, delegate;

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if(self = [super initWithCoder:aDecoder]){
        backgroundQueue = dispatch_queue_create("de.sozialhelden.wheelmap.list", NULL);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // correct cell separator insets
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    // set the constraint that was not defined although connected in storyboard
    if(!self.tableViewTopVerticalSpaceConstraint){
        for(NSLayoutConstraint *c in self.tableView.superview.constraints){
            if(c.secondAttribute == NSLayoutAttributeTop){
                self.tableViewTopVerticalSpaceConstraint = c;
            }
        }
    }
    
    self.view.backgroundColor = [UIColor wmGreyColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WMNodeListCell" bundle:nil] forCellReuseIdentifier:@"WMNodeListCell"];
    self.tableView.scrollsToTop = YES;
    dataManager = [[WMDataManager alloc] init];
    
    searching = NO;
    
    if (self.useCase == kWMPOIsListViewControllerUseCaseSearchOnDemand || self.useCase == kWMPOIsListViewControllerUseCaseGlobalSearch) {
        searching = YES;
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    shouldShowNoResultIndicator = YES;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self initNodeType];
    
    
}

-(void) initNodeType{
    
    if (self.useCase == kWMPOIsListViewControllerUseCaseContribute && !isAccesoryHeaderVisible) {
        [((WMNavigationControllerBase *)self.navigationController).customToolBar hideButton:kWMToolBarButtonSearch];
        
        isAccesoryHeaderVisible = YES;
        
        accesoryHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-20, 60)];
        accesoryHeader.image = [[UIImage imageNamed:@"misc_position-info.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        accesoryHeader.center = CGPointMake(self.view.center.x, accesoryHeader.center.y);
        
        headerLabel = [[WMLabel alloc] initWithFrameByNodeType:CGRectMake(10, 0, accesoryHeader.frame.size.width-20, 60) nodeType:self.useCase];
        [accesoryHeader addSubview:headerLabel];
        
        accesoryHeader.alpha = 0.0;
        [self.view addSubview:accesoryHeader];
        
        self.tableViewTopVerticalSpaceConstraint.constant += 80;
        [UIView animateWithDuration:0.3 animations:^(void)
         {
             [self.view layoutIfNeeded];
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.5 animations:^(void)
              {
                  accesoryHeader.alpha = 1.0;
              }
                              completion:nil
              ];
         }];
        
        [(WMNavigationControllerBase*)dataSource updateNodesWithCurrentUserLocation];
        [self loadNodes];
        
    } else if (self.useCase == kWMPOIsListViewControllerUseCaseSearchOnDemand) {
        [self.tableView reloadData];
        [self loadNodes];
        [((WMNavigationControllerBase *)self.navigationController).customToolBar selectSearchButton];
    } else if (self.useCase == kWMPOIsListViewControllerUseCaseGlobalSearch) {
        [self.tableView reloadData];
        [self loadNodes];
        [((WMNavigationControllerBase *)self.navigationController).customToolBar selectSearchButton];
        [((WMNavigationControllerBase *)self.navigationController).customToolBar hideButton:kWMToolBarButtonCurrentLocation];
    }
    else {
        
        NSNumber* lastMapVisibleCenterLat = [((WMNavigationControllerBase *)self.navigationController) lastVisibleMapCenterLat];
        if (!lastMapVisibleCenterLat) {
            // there is no stored bbox. we update nodes from the user location.
            [(WMNavigationControllerBase*)dataSource updateNodesWithCurrentUserLocation];
        }
        [self loadNodes];
        
        if (self.useCase == kWMPOIsListViewControllerUseCaseCategory) {
            [((WMNavigationControllerBase *)self.navigationController).customToolBar hideButton:kWMToolBarButtonSearch];
        }
    }
}

- (void) loadNodes
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (self.useCase == kWMPOIsListViewControllerUseCaseContribute && !isAccesoryHeaderVisible) {
            isAccesoryHeaderVisible = YES;
            
            accesoryHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-20, 60)];
            accesoryHeader.image = [[UIImage imageNamed:@"misc_position-info.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            accesoryHeader.center = CGPointMake(self.view.center.x, accesoryHeader.center.y);
            
            headerLabel = [[WMLabel alloc] initWithFrameByNodeType:CGRectMake(10, 0, accesoryHeader.frame.size.width-20, 60) nodeType:self.useCase];
            [accesoryHeader addSubview:headerLabel];
            
            accesoryHeader.alpha = 0.0;
            [self.view addSubview:accesoryHeader];
            
            self.tableViewTopVerticalSpaceConstraint.constant += 80;
            [UIView animateWithDuration:0.3 animations:^(void)
             {
                 [self.view layoutIfNeeded];
             }
                             completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:0.5 animations:^(void)
                  {
                      NSLog(@"accesoryHeader frame: %@", NSStringFromCGRect(accesoryHeader.frame));
                      accesoryHeader.alpha = 1.0;
                  }
                                  completion:nil
                  ];
             }];
            
        } else {
            
            if (self.useCase != kWMPOIsListViewControllerUseCaseContribute) {
                
                isAccesoryHeaderVisible = NO;
                
                self.tableViewTopVerticalSpaceConstraint.constant = 0;
                [UIView animateWithDuration:0.3 animations:^(void)
                 {
                     [self.view layoutIfNeeded];
                 }
                                 completion:^(BOOL finished)
                 {
                     [UIView animateWithDuration:0.5 animations:^(void)
                      {
                          accesoryHeader.alpha = 0.0;
                      }
                                      completion:nil
                      ];
                 }];
            }
        }
    }
    
    if (self.useCase == kWMPOIsListViewControllerUseCaseContribute) {
        NSArray* unfilteredNodes = [self.dataSource filteredNodeListForUseCase:self.useCase];
        NSMutableArray* newNodeList = [[NSMutableArray alloc] init];
        
        if(unfilteredNodes.count > 0){
            for (Node* node in unfilteredNodes) {
                if ([node.wheelchair caseInsensitiveCompare:K_WHEELCHAIR_STATE_UNKNOWN] == NSOrderedSame) {
                    [newNodeList addObject:node];
                }
            }
        }
        nodes = newNodeList;
    } else {
        nodes = [self.dataSource filteredNodeListForUseCase:self.useCase];
    }
    
    if (nodes.count > 0) {
        
        dispatch_async(backgroundQueue, ^(void) {
            
            __block NSArray *nodesTemp = [self sortNodesByDistance:[nodes copy]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                nodes = nodesTemp;
                nodesTemp = nil;
                
                [self.tableView reloadData];
                
                NSLog(@"NUMBER OF NODES = %lu", (unsigned long)nodes.count);
            });
        });
    }
    
}

- (NSArray*)sortNodesByDistance:(NSArray*)nodesTemp
{
    CLLocation* userLocation = ((WMNavigationControllerBase*)dataSource).currentLocation;
    
    nodesTemp = [nodesTemp sortedArrayUsingComparator:^NSComparisonResult(Node* n1, Node* n2) {
        
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:[n1.lat doubleValue] longitude:[n1.lon doubleValue]];
        CLLocationDistance d1 = [userLocation distanceFromLocation:loc1];
        
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[n2.lat doubleValue] longitude:[n2.lon doubleValue]];
        CLLocationDistance d2 = [userLocation distanceFromLocation:loc2];
        
        if (d1 > d2) return NSOrderedDescending;
        if (d1 < d2) return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    return nodesTemp;
}

#pragma mark - Node View Protocol

- (void) nodeListDidChange
{
    if (self.useCase == kWMPOIsListViewControllerUseCaseSearchOnDemand || self.useCase == kWMPOIsListViewControllerUseCaseGlobalSearch) {
        if (receivedClearList) {
            searching = NO;
            receivedClearList = NO;
        } else {
            searching = YES;
            receivedClearList = YES;
        }}
    shouldShowNoResultIndicator = YES;
    [self loadNodes];
}

- (void) selectNode:(Node *)node
{
    if (node) {
        NSUInteger row = [nodes indexOfObject:node];
        if (row != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
        
    } else {
        // deselect node
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nodes && nodes.count == 0 && shouldShowNoResultIndicator) {
        // no search result!
        return 1;   // to infrom user about this
    }
    
    return [nodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nodes && nodes.count == 0 && shouldShowNoResultIndicator) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"WMNodeListCellNoResult"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WMNodeListCellNoResult"];
            cell.textLabel.font = [UIFont fontWithName:@"HeleticaNeue-Bold" size:15.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (searching) {
            cell.textLabel.text = NSLocalizedString(@"Loading Places", nil);
        } else {
            cell.textLabel.text = NSLocalizedString(@"NoPOIsFound", nil);
        }
        return cell;
    }
    
    WMNodeListCell *cell = (WMNodeListCell*)[tableView dequeueReusableCellWithIdentifier:@"WMNodeListCell"];
    Node *node = nodes[indexPath.row];
    
    // show wheelchair status
    
    for (UIView *subview in cell.iconImage.subviews) {
        if ([subview isKindOfClass:UIImageView.class]) {
            [subview removeFromSuperview];
        }
    }
    
    cell.iconImage.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
    UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 20, 16)];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.backgroundColor = [UIColor clearColor];
    icon.image = [[WMResourceManager sharedManager] iconForName:node.node_type.icon]; // node.node_type.iconPath is sometimes null. this is a hot fix.
    [cell.iconImage addSubview:icon];
    
    // show name
    cell.titleLabel.text = node.name ?: @"";
    
    // show node type
    cell.nodeTypeLabel.text = node.node_type.localized_name ?: @"";
    
    // show node distance
    CLLocation *nodeLocation = [[CLLocation alloc] initWithLatitude:[node.lat doubleValue] longitude:[node.lon doubleValue]];
    CLLocation* userLocation = ((WMNavigationControllerBase*)dataSource).currentLocation;
    CLLocationDistance distance = [userLocation distanceFromLocation:nodeLocation];
    cell.distanceLabel.text = [NSString localizedDistanceStringFromMeters:distance];
    
    return cell;
}

- (void) showDetailPopoverForNode:(Node *)node
{
    
    if (node == nil) {
        NSLog(@"NODE IS NIL");
        return;
    }
    
    
    
    WMPOIViewController *detailViewController = [UIStoryboard instantiatedDetailViewController];
    detailViewController.title = detailViewController.navigationBarTitle = NSLocalizedString(@"NavBarTitleDetail", nil);
    detailViewController.node = node;
    detailViewController.baseController = self.controllerBase;
    
    WMPOIIPadNavigationController *detailNavController = [[WMPOIIPadNavigationController alloc] initWithRootViewController:detailViewController];
    detailNavController.listViewController = self;
    detailNavController.customNavigationBar.title = detailViewController.navigationBarTitle;
    
    detailViewController.popover = [[WMPopoverController alloc] initWithContentViewController:detailNavController];
    
    CGRect myRect = [self.tableView rectForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    
    [detailViewController.popover presentPopoverFromRect:myRect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(nodeListView:didSelectNode:)]) {
        if (nodes.count > indexPath.row) {
            [self.delegate nodeListView:self didSelectNode:nodes[indexPath.row]];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(nodeListView:didSelectNode:)]) {
        [self.delegate nodeListView:self didSelectNode:nil];
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.delegate nodeListView:self didSelectDetailsForNode:nodes[indexPath.row]];
}

@end