//
//  WMRootViewController_iPad.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMRootViewController_iPad.h"
#import "WMDetailViewController.h"
#import "WMNavigationControllerBase.h"

@implementation WMRootViewController_iPad


@synthesize dataSource, delegate;

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
//    [(WMNavigationControllerBase *)self.navigationController updateUserLocation];
}

- (void)nodeListDidChange
{
    [self.listViewController nodeListDidChange];
    [self.mapViewController nodeListDidChange];
}

-(IBAction)toggleListButtonTouched:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint center = self.listContainerView.center;
        center.x = -center.x;
        self.listContainerView.center = center;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)gotNewUserLocation:(CLLocation *)location {
    NSLog(@"...NEW USER LOCATION...");
    [self.mapViewController relocateMapTo:location.coordinate andSpan:MKCoordinateSpanMake(0.004, 0.004)];
}

- (void)pressedSearchButton:(BOOL)selected {
    self.listViewController.useCase = kWMNodeListViewControllerUseCaseNormal;
    self.mapViewController.useCase = kWMNodeListViewControllerUseCaseNormal;
}

- (void)toggleMapTypeChanged:(UIButton *)sender {
    [self.mapViewController toggleMapTypeChanged:sender];
}

#pragma mark - Node List Data Source

- (NSArray*)nodeList
{
    return [self.dataSource nodeList];
}

-(NSArray*)filteredNodeList
{
    return [self.dataSource filteredNodeList];
}

-(void)updateNodesNear:(CLLocationCoordinate2D)coord
{
    [(WMNavigationControllerBase*)self.dataSource updateNodesNear:coord];
    
}

-(void)updateNodesWithRegion:(MKCoordinateRegion)region
{
    [(WMNavigationControllerBase*)self.dataSource updateNodesWithRegion:region];
}



#pragma mark - Node List Delegate

- (void)nodeListView:(id<WMNodeListView>)nodeListView didSelectDetailsForNode:(Node *)node
{
    if (node == nil) {
        return;
    }
//    [self.mapViewController showDetailPopoverForNode:node];
    [self.listViewController selectNode:node];
    [self.listViewController showDetailPopoverForNode:node];
}

- (void)nodeListView:(id<WMNodeListView>)nodeListView didSelectNode:(Node *)node
{
    if (node == nil) {
        return;
    }
    // highlight node in both views
    [self.listViewController selectNode:node];
    [self.listViewController showDetailPopoverForNode:node];
//    [self.mapViewController selectNode:node];
    [self.mapViewController zoomInForNode:node];

}


#pragma mark - Node List Protocol

- (void)selectNode:(Node *)node
{    
}

-(BOOL)shouldAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end


