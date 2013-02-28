//
//  WMFirstStartViewController.h
//  Wheelmap
//
//  Created by Michael Thomas on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"

@interface WMFirstStartViewController : WMViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton* cancelButton;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;

-(IBAction)pressedCancelButton:(id)sender;

@end
