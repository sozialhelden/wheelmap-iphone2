//
//  WMAcceptTermsViewController.h
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"

@interface WMAcceptTermsViewController : WMViewController

@property (nonatomic, weak) IBOutlet UILabel* textLabel;
@property (nonatomic, weak) IBOutlet UIButton* interceptButton;
@property (nonatomic, weak) IBOutlet UITextView* linkTextView;
@property (nonatomic, weak) IBOutlet UIButton* acceptButton;
@property (nonatomic, weak) IBOutlet UIButton* declineButton;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;

-(IBAction)pressedAcceptButton:(id)sender;
-(IBAction)pressedDeclineButton:(id)sender;
-(IBAction)pressedInterceptButton:(id)sender;

@end
