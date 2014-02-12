//
//  WMLogoutViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMLogoutViewController.h"
#import "WMDataManager.h"
#import "WMNavigationControllerBase.h"

@interface WMLogoutViewController ()
{
    WMDataManager* dataManager;
}
@end

@implementation WMLogoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    dataManager = [[WMDataManager alloc] init];
    
    self.titleLabel.text = NSLocalizedString(@"Sign Out", nil);
    self.topTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Signed In As", nil), dataManager.currentUserName];
    
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.logoutButton setTitle:NSLocalizedString(@"Sign Out", nil) forState:UIControlStateNormal];
    
    [self.logoutButton setBackgroundImage:[[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 10)] forState:UIControlStateNormal];
    self.logoutButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.logoutButton sizeToFit];
    self.logoutButton.frame = CGRectMake(320.0f - self.logoutButton.frame.size.width - 10.0f, self.logoutButton.frame.origin.y, self.logoutButton.frame.size.width, self.logoutButton.frame.size.height);
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedCancelButton:)];
    [self.view addGestureRecognizer:tapGR];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressedLogoutButton:(id)sender
{
    
    [dataManager removeUserAuthentication];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [(WMToolBar_iPad *)((WMNavigationControllerBase *)self.baseController).customToolBar updateLoginButton];
    }
    
    [self dismissModalViewControllerAnimated: YES];
    
}
-(IBAction)pressedCancelButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
