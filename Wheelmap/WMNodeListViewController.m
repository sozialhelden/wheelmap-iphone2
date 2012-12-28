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


@implementation WMNodeListViewController
{
    NSArray *nodes;
    
    BOOL isAccesoryHeaderVisible;
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

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (self.useCase == kWMNodeListViewControllerUseCaseContribute && !isAccesoryHeaderVisible) {
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
        
        [(WMNavigationControllerBase*)dataSource updateUserLocation];
        [self loadNodes];
        
    } else if (self.useCase == kWMNodeListViewControllerUseCaseSearch) {
        // do nothing!
        [((WMNavigationControllerBase *)self.navigationController).customToolBar selectSearchButton];
    } else {
    
        NSValue* lastMapVisibleCenter = [((WMNavigationControllerBase *)self.navigationController) lastVisibleMapCenter];
        if (!lastMapVisibleCenter) {
            // there is no stored bbox. we update nodes from the user location.
            [(WMNavigationControllerBase*)dataSource updateUserLocation];
        }
        [self loadNodes];
    }
}

- (void) loadNodes
{
    nodes = [self.dataSource filteredNodeList];
    
    
    [self sortNodesByDistance];
    
    [self.tableView reloadData];
}

- (void)sortNodesByDistance {
    
    for (Node *node in nodes) {
        CLLocation *nodeLocation = [[CLLocation alloc] initWithLatitude:[node.lat doubleValue] longitude:[node.lon doubleValue]];
        
        CLLocation* currentUserLocation = [(WMNavigationControllerBase*)dataSource currentUserLocation];
        CLLocationDistance distance = [currentUserLocation distanceFromLocation:nodeLocation];
        node.distance = [NSNumber numberWithFloat:distance];
    }
    
    NSArray *sortedArray;
    sortedArray = [nodes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Node*)a distance];
        NSNumber *second = [(Node*)b distance];
        return [first compare:second];
    }];
    
    nodes = sortedArray;
}

#pragma mark - Node View Protocol

- (void) nodeListDidChange
{
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
    return [nodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMNodeListCell *cell = (WMNodeListCell*)[tableView dequeueReusableCellWithIdentifier:@"WMNodeListCell"];
    Node *node = nodes[indexPath.row];
    
    // show wheelchair status
    cell.iconImage.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
    UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(1, 3, 20, 16)];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.backgroundColor = [UIColor clearColor];
    icon.image = [UIImage imageWithContentsOfFile:node.node_type.iconPath];
    [cell.iconImage addSubview:icon];
    
    // show name
    cell.titleLabel.text = node.name ?: @"?";
    
    // show node type
    cell.nodeTypeLabel.text = node.node_type.localized_name ?: @"?";
    
    
    // show node distance
    if (node.distance.floatValue > 999) {
        cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", node.distance.floatValue/1000.0f];
    } else {
        cell.distanceLabel.text = [NSString stringWithFormat:@"%.0f m", node.distance.floatValue];
    }

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





