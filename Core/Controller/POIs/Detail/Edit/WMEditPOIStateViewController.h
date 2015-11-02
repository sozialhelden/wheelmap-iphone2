//
//  WMEditPOIStateViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "WMDataManager.h"
#import "WMEditPOIStatusButtonView.h"

@interface WMEditPOIStateViewController : WMViewController <WMDataManagerDelegate, WMEditPOIStatusButtonViewDelegate> {

	WMDataManager* dataManager;
    
}

@property (strong, nonatomic) id<WMEditPOIStatusDelegate>		delegate;

@property (nonatomic, strong) Node *							node;

@property (nonatomic, strong) NSString *						currentState;
@property (nonatomic) WMEditPOIStatusUseCase					useCase;
@property (nonatomic) WMEditPOIStatusType						statusType;

@property (nonatomic) BOOL										hideSaveButton;

- (void)saveCurrentState;

@end
