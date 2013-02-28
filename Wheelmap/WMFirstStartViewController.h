//
//  WMFirstStartViewController.h
//  Wheelmap
//
//  Created by Michael Thomas on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"

@interface WMFirstStartViewController : WMViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UILabel* firstTextLabel;
@property (nonatomic, weak) IBOutlet UILabel* secondTextLabel;
@property (nonatomic, weak) IBOutlet UILabel* registerLabel;
@property (nonatomic, weak) IBOutlet UILabel* thirdtextLabel;
@property (nonatomic, weak) IBOutlet UILabel* loginLabel;

@property (nonatomic, weak) IBOutlet UIButton* okButton;
@property (nonatomic, weak) IBOutlet UIButton* registerButton;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;

@end
