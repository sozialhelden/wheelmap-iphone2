//
//  WMOSMStartViewController.h
//  Wheelmap
//
//  Created by Dirk Tech on 30.04.15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMDataManagerDelegate.h"


@interface WMOSMStartViewController : WMViewController <UITextFieldDelegate, WMDataManagerDelegate> {
    
    WMDataManager *dataManager;
}

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UILabel *stepsLabel;
@property (nonatomic, weak) IBOutlet UITextView *stepsTextView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet UIButton *whyButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *topTextLabel;
@property (nonatomic, retain) WMDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;

- (IBAction)registerPressed:(id)sender;
- (IBAction)loginPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (IBAction)whyOSMPressed:(id)sender;
- (void)dataManagerDidAuthenticateUser:(WMDataManager *)aDataManager;

@end
