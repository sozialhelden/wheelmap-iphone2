//
//  WMDashboardViewController.h
//  Wheelmap
//
//  Created by npng on 12/2/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDataManager.h"
#import "WMDataManagerDelegate.h"

@interface WMDashboardViewController : WMViewController <UITextFieldDelegate, WMDataManagerDelegate> {

	WMDataManager* dataManager;

    BOOL isUIObjectsReadyToInteract;
}

- (void)showUIObjectsAnimated:(BOOL)animated;

@end
