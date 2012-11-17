//
//  WMRootViewController_iPad.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMNodeListView.h"

@class WMNodeListViewController, WMMapViewController;

@interface WMRootViewController_iPad : UIViewController<WMNodeListView,WMNodeListDataSource, WMNodeListDelegate>

@property (nonatomic) IBOutlet UIView<WMNodeListView> *listContainerView;
@property (nonatomic) IBOutlet UIView<WMNodeListView> *mapContainerView;

@property (nonatomic) WMNodeListViewController *listViewController;
@property (nonatomic) WMMapViewController *mapViewController;

- (IBAction)toggleListButtonTouched:(id)sender;

@end
