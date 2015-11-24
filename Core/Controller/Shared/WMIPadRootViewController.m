//
//  WMIPadRootViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMIPadRootViewController.h"
#import "WMPOIViewController.h"
#import "WMNavigationControllerBase.h"
#import <QuartzCore/QuartzCore.h>
#import "WMIntroViewController.h"

@implementation WMIPadRootViewController


@synthesize dataSource, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

	[self showIntroViewControllerIfNecessary];

	if (self.listShadowImageView.isRightToLeftDirection == YES) {
		self.listShadowImageView.image = self.listShadowImageView.image.rightToLeftMirrowedImage;
	}

    self.listViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"listViewController"];
    self.listViewController.dataSource = (WMNavigationControllerBase*)self.dataSource;
    self.listViewController.delegate = (WMNavigationControllerBase*)self.dataSource;
    [self addChildViewController:self.listViewController];
    [self.listViewController didMoveToParentViewController:self];
    self.listViewController.view.frame = self.listContainerView.bounds;
    [self.listContainerView addSubview:self.listViewController.view];
    self.listViewController.controllerBase = self.controllerBase;
    
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    self.mapViewController.dataSource = (WMNavigationControllerBase*)self.dataSource;
    self.mapViewController.delegate = (WMNavigationControllerBase*)self.dataSource;
    self.mapViewController.baseController = (WMNavigationControllerBase*)self.dataSource;
    [self addChildViewController:self.mapViewController];
    [self.mapViewController didMoveToParentViewController:self];
    self.mapViewController.view.frame = self.mapContainerView.bounds;
    [self.mapContainerView addSubview:self.mapViewController.view];
    
    self.controllerBase.mapViewController = self.mapViewController;
}

- (void)showIntroViewControllerIfNecessary {
	if (WMHelper.shouldShowIntroViewController == YES) {
		WMIntroViewController *introViewController = UIStoryboard.instantiatedIntroViewController;
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:introViewController];
		introViewController.popoverController = popoverController;
		[popoverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:0 animated:YES];
	}
}

#pragma mark -

- (void)nodeListDidChange {
    [self.listViewController nodeListDidChange];
    [self.mapViewController nodeListDidChange];
}

- (void)gotNewUserLocation:(CLLocation *)location {
    [self.mapViewController relocateMapTo:location.coordinate andSpan:MKCoordinateSpanMake(0.004, 0.004)];
}

- (void)pressedSearchButton:(BOOL)selected {
    self.listViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
    self.mapViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
}

- (void)toggleMapTypeChanged:(UIButton *)sender {
    [self.mapViewController toggleMapTypeChanged:sender];
}

#pragma mark - Node List Data Source

- (NSArray*)nodeList {
    return [self.dataSource nodeList];
}

- (NSArray*)filteredNodeListForUseCase:(WMPOIsListViewControllerUseCase)useCase {
    return [self.dataSource filteredNodeListForUseCase:useCase];
}

-(void)updateNodesWithRegion:(MKCoordinateRegion)region {
    [(WMNavigationControllerBase*)self.dataSource updateNodesWithRegion:region];
}

#pragma mark - Node List Delegate

- (void)nodeListView:(id<WMPOIsListViewDelegate>)nodeListView didSelectDetailsForNode:(Node *)node {
    if (node == nil) {
        return;
    }
    [self.listViewController selectNode:node];
    [self.listViewController showDetailPopoverForNode:node];
}

- (void)nodeListView:(id<WMPOIsListViewDelegate>)nodeListView didSelectNode:(Node *)node {
    if (node == nil) {
        return;
    }
    // highlight node in both views
    [self.listViewController selectNode:node];
    [self.listViewController showDetailPopoverForNode:node];
    [self.mapViewController zoomInForNode:node];
}

#pragma mark - Node List Protocol

- (void)selectNode:(Node *)node {
}

- (BOOL)shouldAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end


