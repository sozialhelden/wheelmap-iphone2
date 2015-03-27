//
//  WMOSMDescribeViewController.h
//  Wheelmap
//
//  Created by Dirk Tech on 04/30/15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"

@interface WMOSMDescribeViewController : WMViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIButton* okButton;

@end
