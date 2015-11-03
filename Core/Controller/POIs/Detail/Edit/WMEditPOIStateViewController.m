//
//  WMEditPOIStateViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMEditPOIStateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WMPOIIPadNavigationController.h"
#import "WMNavigationControllerBase.h"
#import "WMPOIsListViewController.h"

@interface WMEditPOIStateViewController ()

@property (weak, nonatomic) IBOutlet UIView *							yesButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *							limitedButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *				limitedButtonViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *							noButtonContainerView;

@property (weak, nonatomic) WMEditPOIStatusButtonView *					yesButtonView;
@property (weak, nonatomic) WMEditPOIStatusButtonView *					limitedButtonView;
@property (weak, nonatomic) WMEditPOIStatusButtonView *					noButtonView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *				scrollViewContentWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *				scrollViewContentHeightConstraint;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *			progressWheel;

@end

@implementation WMEditPOIStateViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;

	[self addStateButtons];

	self.statusType = self.statusType;

	// Set the preferred content size to make sure the popover controller has the right size.
	self.scrollViewContentHeightConstraint.constant = self.noButtonContainerView.frame.origin.y + self.noButtonContainerView.frame.size.height + 10;
	self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"EditPOIStateHeadline", nil);
    self.navigationBarTitle = self.title;

	if (self.statusType == WMEditPOIStatusTypeWheelchair) {
		self.currentState = self.node.wheelchair;
	} else if (self.statusType == WMEditPOIStatusTypeToilet) {
		self.currentState = self.node.wheelchair_toilet;
	}
    [self updateViewContent];
}

#pragma mark - Initialization

- (void)addStateButtons {
	self.yesButtonView = (WMEditPOIStatusButtonView *) [[WMEditPOIStatusButtonView alloc] initFromNibToView:self.yesButtonContainerView];
	self.yesButtonView.statusType = self.statusType;
	[self.yesButtonView setCurrentStatus:K_STATE_YES];
	self.yesButtonView.delegate = self;

	self.limitedButtonView = (WMEditPOIStatusButtonView *) [[WMEditPOIStatusButtonView alloc] initFromNibToView:self.limitedButtonContainerView];
	self.limitedButtonView.statusType = self.statusType;
	[self.limitedButtonView setCurrentStatus:K_STATE_LIMITED];
	self.limitedButtonView.delegate = self;

	self.noButtonView = (WMEditPOIStatusButtonView *) [[WMEditPOIStatusButtonView alloc] initFromNibToView:self.noButtonContainerView];
	self.noButtonView.statusType = self.statusType;
	[self.noButtonView setCurrentStatus:K_STATE_NO];
	self.noButtonView.delegate = self;
}

#pragma mark - Public methods

- (void)setStatusType:(WMEditPOIStatusType)statusType {
	_statusType = statusType;

	[self updateViewContent];
}

- (void)saveCurrentState {
	[self.delegate didSelectStatus:self.currentState forStatusType:self.statusType];

	if (self.statusType == WMEditPOIStatusTypeWheelchair) {
		[dataManager updateWheelchairStatusOfNode:self.node];
	} else 	if (self.statusType == WMEditPOIStatusTypeToilet) {
		[dataManager updateToiletStateOfNode:self.node];
	}

	self.progressWheel.hidden = NO;
}

#pragma mark -

- (void)updateViewContent {
	[self.yesButtonView setSelected:[self.currentState isEqualToString:K_STATE_YES]];
	[self.limitedButtonView setSelected:[self.currentState isEqualToString:K_STATE_LIMITED]];
	[self.noButtonView setSelected:[self.currentState isEqualToString:K_STATE_NO]];

	if (self.statusType == WMEditPOIStatusTypeToilet) {
		self.limitedButtonViewContainerHeightConstraint.constant = 0;
		[self.limitedButtonContainerView layoutIfNeeded];
	}
}

#pragma mark - Data Manager Delegate

- (void)dataManager:(WMDataManager *)dataManager didUpdateWheelchairStatusOfNode:(Node *)node {
	DKLog(K_VERBOSE_EDIT_POI, @"Updated the wheelchair status successfully.");

	[self didUpdateStateSucceeded];
}

- (void)dataManager:(WMDataManager *)dataManager updateWheelchairStatusOfNode:(Node *)node failedWithError:(NSError *)error {
	DKLog(K_VERBOSE_EDIT_POI, @"Update of the wheelchair status failed! Error: %@", error);

	[self didUpdateStateFailed];
}

- (void)dataManager:(WMDataManager *)dataManager didUpdateToiletStatusOfNode:(Node *)node {
	DKLog(K_VERBOSE_EDIT_POI, @"Updated the toilet status successfully.");

	[self didUpdateStateSucceeded];
}

- (void)dataManager:(WMDataManager *)dataManager updateToiletStatusOfNode:(Node *)node failedWithError:(NSError *)error {
	DKLog(K_VERBOSE_EDIT_POI, @"Update of the toilet status failed! Error: %@", error);

	[self didUpdateStateFailed];
}

#pragma mark - Data Manager Delegate Helper

- (void)didUpdateStateSucceeded {
	self.progressWheel.hidden = YES;

	if (UIDevice.isIPad == YES) {
		if ([self.navigationController isKindOfClass:[WMPOIIPadNavigationController class]]) {
			if (((WMPOIIPadNavigationController *)self.navigationController).listViewController.controllerBase != nil) {
				[((WMPOIIPadNavigationController *)self.navigationController).listViewController.controllerBase updateNodesWithCurrentUserLocation];
			}
		}
	}

	[self.delegate didSelectStatus:self.currentState forStatusType:self.statusType];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didUpdateStateFailed {
	self.progressWheel.hidden = YES;

	[[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"POIStatusChangeFailed", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - WMEditPOIStatusButtonViewDelegate

- (void)didSelectStatus:(NSString *)state {
	self.currentState = state;
	[self updateViewContent];
	if (self.useCase == WMEditPOIStatusUseCasePOICreation) {
		[self.delegate didSelectStatus:self.currentState forStatusType:self.statusType];
	}
}

@end
