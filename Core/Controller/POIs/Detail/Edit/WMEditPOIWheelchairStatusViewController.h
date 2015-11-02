//
//  WMEditPOIWheelchairStatusViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "WMDataManager.h"
#import "WMEditPOIStatusButtonView.h"

typedef enum {
    kWMWheelChairStatusViewControllerUseCasePutWheelChairStatus,
    kWMWheelChairStatusViewControllerUseCasePutNode
} WMWheelChairStatusViewControllerUseCase;

@interface WMEditPOIWheelchairStatusViewController : WMViewController <WMDataManagerDelegate, WMEditPOIStatusButtonViewDelegate> {

	WMDataManager* dataManager;
    
}

@property (nonatomic, strong) Node *						node;

@property WMWheelChairStatusViewControllerUseCase			useCase;

@property (strong, nonatomic) id<WMEditPOIStatusDelegate>	delegate;

@property (nonatomic, strong) NSString *					currentState;

@property (nonatomic) BOOL									hideSaveButton;

- (void)saveAccessStatus;

@end
