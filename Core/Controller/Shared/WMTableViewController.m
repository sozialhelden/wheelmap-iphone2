//
//  WMTableViewController.m
//  Wheelmap
//
//  Created by npng on 12/1/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMTableViewController.h"

@interface WMTableViewController ()

@end

@implementation WMTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.title = @"";

	// Set the preferred content size to make sure the popover controller has the right size.
	self.preferredContentSize = CGSizeMake(320.0f, 590.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
