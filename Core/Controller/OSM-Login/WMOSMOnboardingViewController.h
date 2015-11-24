//
//  WMOSMOnboardingViewController.h
//  Wheelmap
//
//  Created by Dirk Tech on 30.04.15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMDataManagerDelegate.h"

@interface WMOSMOnboardingViewController : WMViewController <UITextFieldDelegate, WMDataManagerDelegate> {
    
    WMDataManager *dataManager;
}

@property (nonatomic, weak) IBOutlet UIButton *				doneButton;
@property (nonatomic, weak) IBOutlet UILabel *				stepsLabel;
@property (nonatomic, weak) IBOutlet UITextView *			stepsTextView;
@property (nonatomic, weak) IBOutlet WMStandardButton *		loginButton;
@property (nonatomic, weak) IBOutlet UIButton *				registerButton;
@property (nonatomic, weak) IBOutlet UIButton *				whyButton;
@property (nonatomic, weak) IBOutlet UILabel *				topTextLabel;

@property (nonatomic, retain) WMDataManager *				dataManager;

- (IBAction)registerPressed:(id)sender;
- (IBAction)loginPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (IBAction)whyOSMPressed:(id)sender;
- (void)dataManagerDidAuthenticateUser:(WMDataManager *)aDataManager;

@end
