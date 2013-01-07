//
//  WMCreditsViewController.h
//  Wheelmap
//
//  Created by Taehun Kim on 1/7/13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"

@interface WMCreditsViewController : WMViewController

@property (nonatomic, strong) IBOutlet WMButton *doneButton;
@property (nonatomic, strong) IBOutlet WMLabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *scroller;

- (IBAction)donePressed:(id)sender;

@end
