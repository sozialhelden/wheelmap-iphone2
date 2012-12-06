//
//  WMListViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMNodeListView.h"
#import <CoreLocation/CoreLocation.h>

typedef enum {
    kWMNodeListViewControllerUseCaseNormal,
    kWMNodeListViewControllerUseCaseContribute,
    kWMNodeListViewControllerUseCaseCategory
} WMNodeListViewControllerUseCase;

@interface WMNodeListViewController : WMViewController <WMNodeListView, CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSNumber* selectedCategoryID;
@property (nonatomic) WMNodeListViewControllerUseCase useCase;
@end
