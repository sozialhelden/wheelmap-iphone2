//
//  WMEditPOIViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WMEditPOIViewController.h"
#import "WMWheelchairStatusViewController.h"

@interface WMEditPOIViewController ()

@end

@implementation WMEditPOIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"BEARBEITEN";
    self.navigationBarTitle = self.title;
    
    [self setAccessState];
    
    [self styleInputView:self.nameInputView];
    [self styleInputView:self.categoryInputView];
    [self styleInputView:self.positionInputView];
    [self styleInputView:self.infoInputView];
    [self styleInputView:self.addressInputView];
    [self styleInputView:self.websiteInputView];
    [self styleInputView:self.phoneInputView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.wheelAccessButton setBackgroundImage: self.accessImage forState: UIControlStateNormal];
    [self.wheelAccessButton setTitle:self.wheelchairAccess forState:UIControlStateNormal];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setNameInputView:nil];
    [self setCategoryInputView:nil];
    [self setPositionInputView:nil];
    [self setInfoInputView:nil];
    [self setAddressInputView:nil];
    [self setAddressInputView:nil];
    [self setWebsiteInputView:nil];
    [self setWebsiteInputView:nil];
    [self setPhoneInputView:nil];
    [self setWheelAccessButton:nil];
    [super viewDidUnload];
}

- (void) setAccessState {
    
    // WHEEL ACCESS BUTTON
    
    if ([self.node.wheelchair isEqualToString:@"yes"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-yes.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessYes", @"");
    } else if ([self.node.wheelchair isEqualToString:@"no"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-no.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessNo", @"");
    } else if ([self.node.wheelchair isEqualToString:@"limited"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-limited.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessLimited", @"");
    } else if ([self.node.wheelchair isEqualToString:@"unknown"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-unknown.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessUnknown", @"");
    }
    
    self.wheelAccessButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.wheelAccessButton.titleLabel.textColor = [UIColor whiteColor];
    [self.wheelAccessButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.wheelAccessButton setContentEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
    
}

- (void) styleInputView: (UIView*) inputView {
    [inputView.layer setCornerRadius:5.0f];
    [inputView.layer setMasksToBounds:YES];
    inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    inputView.layer.borderWidth = 1.0f;
    
}


- (IBAction)accessButtonPressed:(UIButton*)button {
  
    if (button.tag == 0) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-yes.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessYes", @"");
      //  self.node.wheelchair = @"yes";
    } else if (button.tag == 1) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-limited.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessLimited", @"");
      //  self.node.wheelchair = @"limited";
    } else if (button.tag == 2) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-no.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessNo", @"");
       // self.node.wheelchair = @"no";
    }
  
}

- (IBAction)showAccesOptions:(id)sender {
    WMWheelchairStatusViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMWheelchairStatusViewController"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
