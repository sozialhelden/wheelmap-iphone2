//
//  WMEditPOIWheelchairStatusViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMEditPOIWheelchairStatusViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WMPOIIPadNavigationController.h"
#import "WMNavigationControllerBase.h"
#import "WMPOIsListViewController.h"

@interface WMEditPOIWheelchairStatusViewController ()

@property (weak, nonatomic) IBOutlet UIView *							yesButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *							limitedButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *							noButtonContainerView;

@property (weak, nonatomic) WMEditPOIStatusButtonView *					yesButtonView;
@property (weak, nonatomic) WMEditPOIStatusButtonView *					limitedButtonView;
@property (weak, nonatomic) WMEditPOIStatusButtonView *					noButtonView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *				scrollViewContentWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *				scrollViewContentHeightConstraint;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *			progressWheel;

@end

@implementation WMEditPOIWheelchairStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;

	self.yesButtonView = (WMEditPOIStatusButtonView *) [[WMEditPOIStatusButtonView alloc] initFromNibToView:self.yesButtonContainerView];
	[self.yesButtonView setStatus:K_STATE_YES];
	self.yesButtonView.delegate = self;

	self.limitedButtonView = (WMEditPOIStatusButtonView *) [[WMEditPOIStatusButtonView alloc] initFromNibToView:self.limitedButtonContainerView];
	[self.limitedButtonView setStatus:K_STATE_LIMITED];
	self.limitedButtonView.delegate = self;

	self.noButtonView = (WMEditPOIStatusButtonView *) [[WMEditPOIStatusButtonView alloc] initFromNibToView:self.noButtonContainerView];
	[self.noButtonView setStatus:K_STATE_NO];
	self.noButtonView.delegate = self;

	self.scrollViewContentWidthConstraint.constant = 320.0f;

	// Set the preferred content size to make sure the popover controller has the right size.
	self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"WheelAccessStatusViewHeadline", nil);
    self.navigationBarTitle = self.title;
    
    self.currentState = self.node.wheelchair;
    [self updateCheckMarks];
}

- (void)updateCheckMarks {

	[self.yesButtonView setSelected:[self.currentState isEqualToString:K_STATE_YES]];
	[self.limitedButtonView setSelected:[self.currentState isEqualToString:K_STATE_LIMITED]];
	[self.noButtonView setSelected:[self.currentState isEqualToString:K_STATE_NO]];
}

- (UIImageView*)createCheckMarkImageView {
    UIImage *checkMark = [UIImage imageNamed:@"details_label-checked.png"];
    UIImageView *checkMarkView = [[UIImageView alloc] initWithFrame:CGRectMake(270, 8, checkMark.size.width, checkMark.size.height)];
    checkMarkView.image = checkMark;
    
    return checkMarkView;
}

- (void)saveAccessStatus {
    [self.delegate didSelectStatus:self.currentState];
    [dataManager updateWheelchairStatusOfNode:self.node];
    
    self.progressWheel.hidden = NO;
}

#pragma mark - Data Manager Delegate

- (void)dataManager:(WMDataManager *)dataManager didUpdateWheelchairStatusOfNode:(Node *)node {
    self.progressWheel.hidden = YES;

    if (UIDevice.isIPad == YES) {
        if ([self.navigationController isKindOfClass:[WMPOIIPadNavigationController class]]) {
            if (((WMPOIIPadNavigationController *)self.navigationController).listViewController.controllerBase != nil) {
                [((WMPOIIPadNavigationController *)self.navigationController).listViewController.controllerBase updateNodesWithCurrentUserLocation];
            }
        }
    }
    
    [self.delegate didSelectStatus:self.currentState];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dataManager:(WMDataManager *)dataManager updateWheelchairStatusOfNode:(Node *)node failedWithError:(NSError *)error {
    self.progressWheel.hidden = YES;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"WheelchairStatusChangeFailed", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    DKLog(K_VERBOSE_EDIT_POI, @"PUT THE NODE WHEELCHAIR STATUS FAILED! %@", error);
}

#pragma mark - WMEditPOIStatusButtonViewDelegate

- (void)didSelectStatus:(NSString *)state {
	self.currentState = state;
	[self updateCheckMarks];
	if (self.useCase == kWMWheelChairStatusViewControllerUseCasePutNode) {
		[self.delegate didSelectStatus:self.currentState];
	}
}

@end
