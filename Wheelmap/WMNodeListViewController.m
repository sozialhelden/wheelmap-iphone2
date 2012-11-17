//
//  WMListViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMNodeListViewController.h"
#import "WMNodeListCell.h"


@implementation WMNodeListViewController
{
    NSArray *nodes;
}

@synthesize dataSource, delegate;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
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
    [self loadNodes];
}

- (void) loadNodes
{
    nodes = [self.dataSource nodeList];
    
    [self.tableView reloadData];
}


#pragma mark - Node View Protocol

- (void) nodeListDidChange
{
    [self loadNodes];
}

- (void) selectNode:(NSDictionary *)node
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
    NSDictionary *node = nodes[indexPath.row];
    NSArray *keys = [node allKeys];
    
    // check wheelchair status
    NSString *wheelchair = [keys indexOfObject:@"wheelchair"]==NSNotFound || node[@"wheelchair"]==[NSNull null] ? @"unknown" : node[@"wheelchair"];
    cell.iconImage.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:wheelchair]];
    
    // check name
    cell.titleLabel.text = [keys indexOfObject:@"name"]==NSNotFound || node[@"name"]==[NSNull null] ? @"?" : node[@"name"];
    
    // check node type
    NSDictionary *nodeType = [keys indexOfObject:@"node_type"]==NSNotFound || node[@"node_type"]==[NSNull null] ? nil : node[@"node_type"];
    NSString *nodeTypeIdentifier = nil;
    if (nodeType) {
        nodeTypeIdentifier = [[nodeType allKeys] indexOfObject:@"identifier"]==NSNotFound || nodeType[@"identifier"]==[NSNull null] ? nil : nodeType[@"identifier"];
    }
    cell.nodeTypeLabel.text = nodeTypeIdentifier;
    
    return cell;
}


#pragma mark - Table view delegate

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





