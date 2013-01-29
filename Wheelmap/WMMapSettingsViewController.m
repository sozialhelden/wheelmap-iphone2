//
//  WMMapSettingsViewController.m
//  Wheelmap
//
//  Created by Michael Thomas on 11.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMMapSettingsViewController.h"
#import "WMNavigationControllerBase.h"
#import "WMMapViewController.h"
#import "WMRootViewController_iPad.h"

@interface WMMapSettingsViewController ()

@end

@implementation WMMapSettingsViewController

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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.buttonsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.wheelmapLogo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    [self.standardButton setTitle:NSLocalizedString(@"MapStandard", nil) forState:UIControlStateNormal];
    [self.hybridButton setTitle:NSLocalizedString(@"MapHybrid", nil) forState:UIControlStateNormal];
    [self.satelliteButton setTitle:NSLocalizedString(@"MapSatellite", nil) forState:UIControlStateNormal];
    
    switch (selectedMapType) {
        case 0:
            self.standardButton.selected = YES;
            self.hybridButton.selected = NO;
            self.satelliteButton.selected = NO;
            break;
        case 1:
            self.standardButton.selected = NO;
            self.hybridButton.selected = YES;
            self.satelliteButton.selected = NO;
            break;
        case 2:
            self.standardButton.selected = NO;
            self.hybridButton.selected = NO;
            self.satelliteButton.selected = YES;
            break;
            
        default:
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Curl_screen.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlButtonPressed:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            self.standardButton.selected = YES;
            self.hybridButton.selected = NO;
            self.satelliteButton.selected = NO;
            break;
        case 1:
            self.standardButton.selected = NO;
            self.hybridButton.selected = YES;
            self.satelliteButton.selected = NO;
            break;
        case 2:
            self.standardButton.selected = NO;
            self.hybridButton.selected = NO;
            self.satelliteButton.selected = YES;
            break;
            
        default:
            break;
    }
    
    selectedMapType = sender.tag;
    
    if ([self.presentingViewController isKindOfClass:WMNavigationControllerBase.class]) {
        UIViewController *topController = [(WMNavigationControllerBase *)self.presentingViewController topViewController];
        if ([topController isKindOfClass:WMMapViewController.class]) {
            [(WMMapViewController *)topController toggleMapTypeChanged:sender];
        } else if ([topController isKindOfClass:WMRootViewController_iPad.class]) {
            [(WMRootViewController_iPad *)topController toggleMapTypeChanged:sender];
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
