//
//  WMEditPOICommentViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 03.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WMEditPOICommentViewController.h"
#import "WMNavigationControllerBase.h"
#import "WMPOIIPadNavigationController.h"


@interface WMEditPOICommentViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *						commentLabel;
@property (weak, nonatomic) IBOutlet UITextView *					commentText;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *		activityIndicator;

@end

@implementation WMEditPOICommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataManager = [[WMDataManager alloc] init];
    self.dataManager.delegate = self;

	self.commentLabel.text = L(@"CommentViewLabel");

	// Setting up the comment text view
	self.commentText.delegate = self;
    self.commentText.layer.borderWidth = 1.0f;
    self.commentText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.commentText.layer setCornerRadius:5.0f];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ((self.currentNode.wheelchair_description != nil) && (![self.currentNode.wheelchair_description isEqualToString:@""])) {
        self.commentText.text = self.currentNode.wheelchair_description;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = L(@"NavBarTitleComment");
    self.navigationBarTitle = self.title;
}

- (void)saveEditedData {

	// In case the user is not autheticated, the SignUp invitation will popup
	if (self.dataManager.userIsAuthenticated == NO) {
		[self presentSignup];
		return;
	}

    if (!self.currentNode.lat || !self.currentNode.lon) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:L(@"Alert.Message.SetMarker") delegate:nil cancelButtonTitle:L(@"OK") otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    self.currentNode.wheelchair_description = self.commentText.text;
    
    [self.dataManager updateNode:self.currentNode];
    
    self.activityIndicator.hidden = NO;
}

- (void) dataManager:(WMDataManager *)dataManager didUpdateNode:(Node *)node {
    self.activityIndicator.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dataManager:(WMDataManager *)dataManager updateNode:(Node *)node failedWithError:(NSError *)error {
    self.activityIndicator.hidden = YES;

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:L(@"SaveNodeFailed") message:error.wheelmapErrorDescription delegate:nil cancelButtonTitle:L(@"OK") otherButtonTitles:nil];
    
    [alert show];
}

- (void)presentSignup {
	WMNavigationControllerBase *navigationController = (WMNavigationControllerBase*) self.navigationController;
	if ([navigationController isKindOfClass:[WMPOIIPadNavigationController class]]) {
		[(WMPOIIPadNavigationController*)navigationController showLoginViewController];
	} else {
		[navigationController presentLoginScreenWithButtonFrame:CGRectZero];
	}
}

#pragma mark - UITextViewDelegate

/**
 *  This method is called as soon as the user tries to write a comment by tapping on it, it will validate wether the user is loggedin and react accordinly
 *
 *  @param textView The textView tapped by the user
 *
 *  @return If the user is logged in, it will return TRUE, otherwise will return NO and will popup the onBoard ciew
 */
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

	if (self.dataManager.userIsAuthenticated == NO) {
		[self presentSignup];
		return NO;
	} else {
		return YES;
	}
}

@end
