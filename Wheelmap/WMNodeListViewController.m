//
//  WMListViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMNodeListViewController.h"
#import "WMNodeListCell.h"
#import "Node.h"
#import "NodeType.h"    
#import "WMNavigationControllerBase.h" 
#import <CoreLocation/CoreLocation.h>
#import "WMStringUtilities.h"
#import "WMDataManager.h"


@implementation WMNodeListViewController
{
    NSArray *nodes;
    
    BOOL isAccesoryHeaderVisible;
    
    BOOL shouldShowNoResultIndicator;

    WMDataManager *dataManager;
}

@synthesize dataSource, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WMNodeListCell" bundle:nil] forCellReuseIdentifier:@"WMNodeListCell"];
    self.tableView.scrollsToTop = YES;
    
    dataManager = [[WMDataManager alloc] init];
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
    
    if (self.useCase == kWMNodeListViewControllerUseCaseContribute && !isAccesoryHeaderVisible) {
        [((WMNavigationControllerBase *)self.navigationController).customToolBar hideButton:kWMToolBarButtonSearch];
        
        isAccesoryHeaderVisible = YES;
        
        UIImageView* accesoryHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-20, 60)];
        accesoryHeader.image = [[UIImage imageNamed:@"misc_position-info.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        accesoryHeader.center = CGPointMake(self.view.center.x, accesoryHeader.center.y);
        
        WMLabel* headerTextLabel = [[WMLabel alloc] initWithFrame:CGRectMake(10, 0, accesoryHeader.frame.size.width-20, 60)];
        headerTextLabel.fontSize = 13.0;
        headerTextLabel.textAlignment = UITextAlignmentLeft;
        headerTextLabel.numberOfLines = 3;
        headerTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        headerTextLabel.textColor = [UIColor whiteColor];
        headerTextLabel.text = NSLocalizedString(@"HelpByMarking", nil);
        [accesoryHeader addSubview:headerTextLabel];
        
        accesoryHeader.alpha = 0.0;
        [self.view addSubview:accesoryHeader];
        
        [UIView animateWithDuration:0.3 animations:^(void)
         {
             self.tableView.frame = CGRectMake(0, 80, self.tableView.frame.size.width, self.tableView.frame.size.height-80);
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.5 animations:^(void)
              {
                  accesoryHeader.alpha = 1.0;
              }
                              completion:^(BOOL finished)
              {
                  
              }
              ];
             
         }
         ];
        
        [(WMNavigationControllerBase*)dataSource updateNodesWithCurrentUserLocation];
        [self loadNodes];
        
    } else if (self.useCase == kWMNodeListViewControllerUseCaseSearchOnDemand) {
        [self loadNodes];
        [((WMNavigationControllerBase *)self.navigationController).customToolBar selectSearchButton];
    } else if (self.useCase == kWMNodeListViewControllerUseCaseGlobalSearch) {
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
        
        if (self.useCase == kWMNodeListViewControllerUseCaseCategory) {
            [((WMNavigationControllerBase *)self.navigationController).customToolBar hideButton:kWMToolBarButtonSearch];
        }
    }
}

- (void) loadNodes
{
    if (self.useCase == kWMNodeListViewControllerUseCaseContribute) {
        NSArray* unfilteredNodes = [self.dataSource nodeList];
        NSMutableArray* newNodeList = [[NSMutableArray alloc] init];
       
        for (Node* node in unfilteredNodes) {
            if ([node.wheelchair caseInsensitiveCompare:@"unknown"] == NSOrderedSame) {
                [newNodeList addObject:node];
            }
        }
        nodes = newNodeList;
    } else {
        nodes = [self.dataSource filteredNodeList];
    }
    [self sortNodesByDistance];
    
    [self.tableView reloadData];
}

- (void)sortNodesByDistance
{
    CLLocation* userLocation = [(WMNavigationControllerBase*)dataSource currentUserLocation];
    
    nodes = [nodes sortedArrayUsingComparator:^NSComparisonResult(Node* n1, Node* n2) {
        
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:[n1.lat doubleValue] longitude:[n1.lon doubleValue]];
        CLLocationDistance d1 = [userLocation distanceFromLocation:loc1];
        
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[n2.lat doubleValue] longitude:[n2.lon doubleValue]];
        CLLocationDistance d2 = [userLocation distanceFromLocation:loc2];
        
        if (d1 > d2) return NSOrderedDescending;
        if (d1 < d2) return NSOrderedAscending;
        return NSOrderedSame;
    }];
}

#pragma mark - Node View Protocol

- (void) nodeListDidChange
{
    shouldShowNoResultIndicator = YES;
    [self loadNodes];
}

- (void) selectNode:(Node *)node
{
    if (node) {
        NSUInteger row = [nodes indexOfObject:node];
        if (row != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
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
            cell.textLabel.text = NSLocalizedString(@"NoPOIsFound", nil);
            cell.textLabel.font = [UIFont fontWithName:@"HeleticaNeue-Bold" size:15.0];
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
    UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(2, 3, 20, 16)];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.backgroundColor = [UIColor clearColor];
    icon.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",dataManager.iconImageRootPath, node.node_type.icon]];  // node.node_type.iconPath is sometimes null. this is a hot fix.
    [cell.iconImage addSubview:icon];
    
    // show name
    cell.titleLabel.text = node.name ?: @"";
    
    // show node type
    cell.nodeTypeLabel.text = node.node_type.localized_name ?: @"";
    
    // show node distance
    CLLocation *nodeLocation = [[CLLocation alloc] initWithLatitude:[node.lat doubleValue] longitude:[node.lon doubleValue]];
    CLLocation* userLocation = [(WMNavigationControllerBase*)dataSource currentUserLocation];
    CLLocationDistance distance = [userLocation distanceFromLocation:nodeLocation];
    cell.distanceLabel.text = [WMStringUtilities localizedDistanceFromMeters:distance];

    return cell;
}       

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(nodeListView:didSelectNode:)]) {
        [self.delegate nodeListView:self didSelectNode:nodes[indexPath.row]];
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





