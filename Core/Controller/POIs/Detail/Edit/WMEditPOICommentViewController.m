//
//  WMEditPOICommentViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 03.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WMEditPOICommentViewController.h"


@interface WMEditPOICommentViewController ()

@end

@implementation WMEditPOICommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.dataManager = [[WMDataManager alloc] init];
    self.dataManager.delegate = self;
    
    self.containerView.backgroundColor = [UIColor wmGreyColor];
    
    // progress wheel
    progressWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    progressWheel.frame = CGRectMake(0, 0, 50, 50);
    progressWheel.backgroundColor = [UIColor blackColor];
    progressWheel.center = CGPointMake(self.view.center.x, self.view.center.y-40);
    progressWheel.hidden = YES;
    progressWheel.layer.cornerRadius = 5.0;
    progressWheel.layer.masksToBounds = YES;
    [self.view addSubview:progressWheel];
    
    self.commentText.layer.borderWidth = 1.0f;
    self.commentText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.commentText.layer setCornerRadius:5.0f];
    
    self.commentLabel.text = NSLocalizedString(@"CommentViewLabel", nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ((self.currentNode.wheelchair_description != nil) && (![self.currentNode.wheelchair_description isEqualToString:@""])) {
        self.commentText.text = self.currentNode.wheelchair_description;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"NavBarTitleComment", nil);
    self.navigationBarTitle = self.title;
}

- (void)saveEditedData {
    if (!self.currentNode.lat || !self.currentNode.lon) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PleaseSetMarker", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    self.currentNode.wheelchair_description = self.commentText.text;
    
    [self.dataManager updateNode:self.currentNode];
    
    progressWheel.hidden = NO;
    [progressWheel startAnimating];
}

- (void)viewDidUnload {
    [self setCommentText:nil];
    [self setCommentLabel:nil];
    [super viewDidUnload];
}

- (void) dataManager:(WMDataManager *)dataManager didUpdateNode:(Node *)node {
    progressWheel.hidden = YES;
    [progressWheel stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dataManager:(WMDataManager *)dataManager updateNode:(Node *)node failedWithError:(NSError *)error {
    progressWheel.hidden = YES;
    [progressWheel stopAnimating];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SaveNodeFailed", nil) message:error.wheelmapErrorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
}

@end
