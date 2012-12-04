//
//  WMCommentViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 03.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCommentViewController.h"

@interface WMCommentViewController ()

@end

@implementation WMCommentViewController

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
    
    self.title = @"COMMENT";
    self.navigationBarTitle = self.title;
    self.commentText.text = self.currentNode.wheelchair_description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCommentText:nil];
    [super viewDidUnload];
}
@end
