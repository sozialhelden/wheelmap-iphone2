//
//  WMRootViewController_iPad.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMRootViewController_iPad.h"
#import "WMNodeListViewController.h"
#import "WMMapViewController.h"
#import "WMDetailViewController.h"



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
    self.listViewController.dataSource = self;
    self.listViewController.delegate = self;
    [self addChildViewController:self.listViewController];
    [self.listViewController didMoveToParentViewController:self];
    self.listViewController.view.frame = self.listContainerView.bounds;
    [self.listContainerView addSubview:self.listViewController.view];
    
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    self.mapViewController.dataSource = self;
    self.mapViewController.delegate = self;
    [self addChildViewController:self.mapViewController];
    [self.mapViewController didMoveToParentViewController:self];
    self.mapViewController.view.frame = self.mapContainerView.bounds;
    [self.mapContainerView addSubview:self.mapViewController.view];
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


#pragma mark - Node List Data Source

- (NSArray*)nodeList
{
    return [self.dataSource nodeList];
}


#pragma mark - Node List Delegate

- (void)nodeListView:(id<WMNodeListView>)nodeListView didSelectDetailsForNode:(NSDictionary *)node
{
    [self.mapViewController showDetailPopoverForNode:node];
}

- (void)nodeListView:(id<WMNodeListView>)nodeListView didSelectNode:(NSDictionary *)node
{
    // highlight node in both views
    [self.listViewController selectNode:node];
    [self.mapViewController selectNode:node];
    
}


#pragma mark - Node List Protocol

- (void)selectNode:(NSDictionary *)node
{    
}

@end


