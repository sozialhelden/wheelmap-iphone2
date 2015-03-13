//
//  WMNodeTypeTableViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 12.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMNodeTypeTableViewController.h"
#import "NodeType.h"
#import "WMEditPOIViewController.h"

@interface WMNodeTypeTableViewController ()

@end

@implementation WMNodeTypeTableViewController

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
 	// Do any additional setup after loading the view.
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"NavBarTitleSetNodeType", nil);
    self.navigationBarTitle = self.title;
    
    long highlightedCellRow = -1;
    for (NodeType* c in self.nodeArray) {
        NSNumber* ID = c.id;
        if ([ID intValue] == [[self.currentNodeType id] intValue]) {
            highlightedCellRow = [[self.nodeArray allObjects] indexOfObject:c];
        }
    }
    
    if (highlightedCellRow >= 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:highlightedCellRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.nodeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NodeType *nodeType = [self.nodeArray.allObjects objectAtIndex:indexPath.row];
                          //objectAtIndex:indexPath.row];
    NSString *nodeString = nodeType.localized_name;
    static NSString *CellIdentifier = @"NodeTypeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = nodeString;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NodeType *nodeType = [self.nodeArray.allObjects objectAtIndex:indexPath.row];
    [self.delegate nodeTypeChosen:nodeType];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
