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

@property (weak, nonatomic) WMEditPOIStateButtonView *					yesButtonView;
@property (weak, nonatomic) WMEditPOIStateButtonView *					limitedButtonView;
@property (weak, nonatomic) WMEditPOIStateButtonView *					noButtonView;

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
	if (UIDevice.isIPad == YES) {
		self.scrollViewContentWidthConstraint.constant = K_POPOVER_VIEW_WIDTH;
	} else {
		self.scrollViewContentWidthConstraint.constant = self.view.frameWidth;
	}
	self.scrollViewContentHeightConstraint.constant = self.noButtonContainerView.frame.origin.y + self.noButtonContainerView.frame.size.height + 10;
	self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"EditPOIStateHeadline", nil);
    self.navigationBarTitle = self.title;

	if (self.statusType == WMPOIStateTypeWheelchair) {
		self.currentState = self.node.wheelchair;
	} else if (self.statusType == WMPOIStateTypeToilet) {
		self.currentState = self.node.wheelchair_toilet;
	}
    [self updateViewContent];
}

#pragma mark - Initialization

- (void)addStateButtons {
	self.yesButtonView = (WMEditPOIStateButtonView *) [[WMEditPOIStateButtonView alloc] initFromNibToView:self.yesButtonContainerView];
	self.yesButtonView.statusType = self.statusType;
	self.yesButtonView.statusString = K_STATE_YES;
	self.yesButtonView.editStateDelegate = self;

	self.limitedButtonView = (WMEditPOIStateButtonView *) [[WMEditPOIStateButtonView alloc] initFromNibToView:self.limitedButtonContainerView];
	self.limitedButtonView.statusType = self.statusType;
	self.limitedButtonView.statusString = K_STATE_LIMITED;
	self.limitedButtonView.editStateDelegate = self;

	self.noButtonView = (WMEditPOIStateButtonView *) [[WMEditPOIStateButtonView alloc] initFromNibToView:self.noButtonContainerView];
	self.noButtonView.statusType = self.statusType;
	self.noButtonView.statusString = K_STATE_NO;
	self.noButtonView.editStateDelegate = self;
}

#pragma mark - Public methods

- (void)setStatusType:(WMPOIStateType)statusType {
	_statusType = statusType;

	[self updateViewContent];
}

- (void)setOriginalState:(NSString *)originalState {
	_originalState = originalState;
	self.currentState = originalState;
}

- (void)saveCurrentState {
	[self.delegate didSelectStatus:self.currentState forStatusType:self.statusType];

	if (self.statusType == WMPOIStateTypeWheelchair) {
		[dataManager updateWheelchairStatusOfNode:self.node];
	} else 	if (self.statusType == WMPOIStateTypeToilet) {
		[dataManager updateToiletStateOfNode:self.node];
	}

	self.progressWheel.hidden = NO;
}

#pragma mark -

- (void)updateViewContent {
	[self.yesButtonView setSelected:[self.currentState isEqualToString:K_STATE_YES]];
	[self.limitedButtonView setSelected:[self.currentState isEqualToString:K_STATE_LIMITED]];
	[self.noButtonView setSelected:[self.currentState isEqualToString:K_STATE_NO]];

	if (self.statusType == WMPOIStateTypeToilet) {
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
	DKLog(K_VERBOSE_EDIT_POI, @"Update of the wheelchair status failed! Error: %@", error.localizedDescription);

	[self didUpdateStateFailed];
}

- (void)dataManager:(WMDataManager *)dataManager didUpdateToiletStatusOfNode:(Node *)node {
	DKLog(K_VERBOSE_EDIT_POI, @"Updated the toilet status successfully.");

	[self didUpdateStateSucceeded];
}

- (void)dataManager:(WMDataManager *)dataManager updateToiletStatusOfNode:(Node *)node failedWithError:(NSError *)error {
	DKLog(K_VERBOSE_EDIT_POI, @"Update of the toilet status failed! Error: %@", error.localizedDescription);

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

	[self.delegate didSelectStatus:self.originalState forStatusType:self.statusType];

	[[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"POIStatusChangeFailed", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - WMEditPOIStateButtonViewDelegate

- (void)didSelectStatus:(NSString *)state {
	self.currentState = state;
	[self updateViewContent];
	if (self.useCase == WMEditPOIStateUseCasePOICreation) {
		[self.delegate didSelectStatus:self.currentState forStatusType:self.statusType];
	}
}

@end
