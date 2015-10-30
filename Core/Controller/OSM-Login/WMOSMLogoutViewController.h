//
//  WMOSMLogoutViewController.h
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

@interface WMOSMLogoutViewController : WMViewController

@property (nonatomic, weak) IBOutlet WMStandardButton *		logoutButton;
@property (nonatomic, weak) IBOutlet UIButton *				cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *				titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *				topTextLabel;

@property(nonatomic,strong)IBOutlet UIView* containerView;

-(IBAction)pressedLogoutButton:(id)sender;
-(IBAction)pressedCancelButton:(id)sender;

@end
