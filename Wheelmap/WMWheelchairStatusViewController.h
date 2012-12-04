//
//  WMWheelchairStatusViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WMWheelchairStatusViewController : WMViewController

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *limitedButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (strong, nonatomic) id delegate;

- (IBAction)accessButtonPressed:(id)sender;


@end
