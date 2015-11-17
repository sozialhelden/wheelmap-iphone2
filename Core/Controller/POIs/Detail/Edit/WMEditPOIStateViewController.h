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
#import "WMEditPOIStateButtonView.h"

@interface WMEditPOIStateViewController : WMViewController <WMDataManagerDelegate, WMEditPOIStateButtonViewDelegate> {

	WMDataManager* dataManager;
    
}

@property (strong, nonatomic) id<WMEditPOIStateDelegate>		delegate;

@property (nonatomic, strong) Node *							node;

@property (nonatomic, strong) NSString *						currentState;
@property (nonatomic, strong) NSString *						originalState;

@property (nonatomic) WMEditPOIStateUseCase						useCase;
@property (nonatomic) WMPOIStateType							statusType;

@property (nonatomic) BOOL										hideSaveButton;

- (void)saveCurrentState;

@end
