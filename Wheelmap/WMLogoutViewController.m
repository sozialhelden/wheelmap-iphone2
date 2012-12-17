//
//  WMLogoutViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMLogoutViewController.h"
#import "WMDataManager.h"

@interface WMLogoutViewController ()
{
    WMDataManager* dataManager;
}
@end

@implementation WMLogoutViewController

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
    
    
    dataManager = [[WMDataManager alloc] init];
    
    self.titleLabel.text = NSLocalizedString(@"Abmelden", nil);
    self.topTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Angemeldet", nil), dataManager.currentUserName];

    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.logoutButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressedLogoutButton:(id)sender
{
    
    [dataManager removeUserAuthentication];
    
    [self dismissModalViewControllerAnimated: YES];
    
}
-(IBAction)pressedCancelButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end