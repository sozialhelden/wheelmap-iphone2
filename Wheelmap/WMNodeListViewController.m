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
    
    // show name
    cell.titleLabel.text = node.name ?: @"?";
    
    // show node type
    cell.nodeTypeLabel.text = node.node_type.localized_name ?: @"?";
    
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





