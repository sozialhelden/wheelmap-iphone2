//
//  WMCommentViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 03.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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
    
    self.navigationBarTitle = self.title;

    self.commentLabel.text = NSLocalizedString(@"CommentViewLabel", @"");
    self.commentText.layer.borderWidth = 1.0f;
    self.commentText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.commentText.layer setCornerRadius:5.0f];
}

- (void) viewDidAppear:(BOOL)animated {
    self.commentText.text = self.currentNode.wheelchair_description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCommentText:nil];
    [self setCommentLabel:nil];
    [super viewDidUnload];
}
@end
