//
//  WMRootViewController_iPad.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMNodeListView.h"
#import "WMNodeListViewController.h"
#import "WMMapViewController.h"

@class WMNodeListViewController, WMMapViewController;

@interface WMRootViewController_iPad : UIViewController<WMNodeListView,WMNodeListDataSource, WMNodeListDelegate>

@property (nonatomic) IBOutlet UIView<WMNodeListView> *listContainerView;
@property (nonatomic) IBOutlet UIView<WMNodeListView> *mapContainerView;

@property (nonatomic) WMNodeListViewController *listViewController;
@property (nonatomic) WMMapViewController *mapViewController;

- (IBAction)toggleListButtonTouched:(id)sender;

-(void)updateNodesNear:(CLLocationCoordinate2D)coord;
-(void)updateNodesWithRegion:(MKCoordinateRegion)region;
@end
