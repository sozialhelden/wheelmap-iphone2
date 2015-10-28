//
//  WMCreditsViewController.h
//  Wheelmap
//
//  Created by Taehun Kim on 1/7/13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

@interface WMCreditsViewController : WMViewController

@property (nonatomic,strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) IBOutlet WMButton *doneButton;
@property (nonatomic, strong) IBOutlet WMLabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;

- (IBAction)donePressed:(id)sender;

@end