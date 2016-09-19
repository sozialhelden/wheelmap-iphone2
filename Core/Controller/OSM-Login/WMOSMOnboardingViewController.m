//
//  WMOSMOnboardingViewController.m
//  Wheelmap
//
//  Created by Dirk Tech on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMOSMOnboardingViewController.h"
#import "WMDataManager.h"
#import "WMNavigationControllerBase.h"
#import "WMPOIIPadNavigationController.h"
#import "WMPOIsListViewController.h"
#import "WMOSMDescriptionViewController.h"
#import "WMOSMLoginViewController.h"
#import "WMWheelmapAPI.h"
#import "WMAnalytics.h"

@interface WMOSMOnboardingViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		scrollViewContentWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		scrollViewContentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint	*		whyButtonBottomConstraint;

@end

@implementation WMOSMOnboardingViewController

@synthesize dataManager;


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAuthenticationData:)
                                                 name:@"didReceiveAuthenticationData"
                                               object:nil];

    [self.doneButton setTitle:L(@"Cancel") forState:UIControlStateNormal];
    self.topTextLabel.text = L(@"LoginOverOSMText");
    self.stepsLabel.text = L(@"OSMAccount");
	self.stepsTextView.text = L(@"StepsToOSMAccount");
    [self.loginButton setTitle:L(@"LoginOverOSM") forState:UIControlStateNormal];
    [self.registerButton setTitle:L(@"OSMRegistration") forState:UIControlStateNormal];
    [self.whyButton setTitle:L(@"WhyOSMAccount") forState:UIControlStateNormal];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	[WMAnalytics trackScreen:K_OSM_ONBOARDING_SCREEN];
    [self showDescriptionViewController];
}

- (void)viewDidLayoutSubviews {
	if (UIDevice.currentDevice.isIPad == YES) {
		self.scrollViewContentWidthConstraint.constant = K_POPOVER_VIEW_WIDTH;
	} else {
		self.scrollViewContentWidthConstraint.constant = self.view.frameWidth;
	}
	CGRect whyButtonFrame = [self.view convertRect:self.whyButton.frame fromView:self.view];
	self.scrollViewContentHeightConstraint.constant = whyButtonFrame.origin.y + self.whyButton.frameHeight + self.whyButtonBottomConstraint.constant;

	self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant);
}

- (void)viewDidDisappear:(BOOL)animated {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	// unregister for keyboard notifications while not visible.
	if (UIDevice.currentDevice.isIPad == NO){

		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIKeyboardWillShowNotification
													  object:nil];

		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIKeyboardWillHideNotification
													  object:nil];
	}
	[super viewDidDisappear:animated];
}

#pragma mark - Helper

- (void)showDescriptionViewController {
	if ([dataManager isFirstLaunch]) {
		WMOSMDescriptionViewController *osmDescriptionViewController = [UIStoryboard instantiatedDescriptionViewController];
		[self presentViewController:osmDescriptionViewController animated:YES];

		[dataManager firstLaunchOccurred];
	}
}

#pragma mark - IBActions

- (IBAction)registerPressed:(id)sender {
	NSString *urlPath = WM_REGISTER_LINK;
	if (WMWheelmapAPI.isStagingBackend == YES) {
		// The direct register link isn't working in the staging environment. We use the login link here.
		urlPath = WEB_LOGIN_LINK;
	}
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WMWheelmapAPI.baseUrl, urlPath]]];
}

- (IBAction)loginPressed:(id)sender {
    WMOSMLoginViewController *osmLoginViewController = [UIStoryboard instantiatedOSMLoginViewController];
    [osmLoginViewController loadLoginUrl];
    [self presentViewController:osmLoginViewController animated:YES];
}

- (IBAction)donePressed:(id)sender {
	if (self.navigationController != nil) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self dismissViewControllerAnimated:YES];
	}
}

- (IBAction)whyOSMPressed:(id)sender {
	WMOSMDescriptionViewController *osmDescriptionViewController = [UIStoryboard instantiatedDescriptionViewController];
	[self presentViewController:osmDescriptionViewController animated:YES];
}

#pragma mark - DataManager Delegate

- (void)dataManager:(WMDataManager *)dataManager userAuthenticationFailedWithError:(NSError *)error {
    // TODO: handle error
    DKLog(K_VERBOSE_ONBOARDING, @"Login failed! %@", error);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"User Credentials Error", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
    
    if (UIDevice.currentDevice.isIPad == YES) {
        [(WMToolbar_iPad *)((WMNavigationControllerBase *)self.baseController).customToolBar updateLoginButton];
    }
}

- (void)dataManagerDidAuthenticateUser:(WMDataManager *)aDataManager {
    // TODO: handle success, dismiss view controller
    DKLog(K_VERBOSE_ONBOARDING, @"Login success!");
    
    if ([dataManager areUserTermsAccepted]) {
        
        if (self.navigationController != nil) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES];
        }
    } else {
        if (UIDevice.currentDevice.isIPad == YES) {
            if (self.navigationController != nil) {
                [((WMPOIIPadNavigationController *)self.navigationController).listViewController.controllerBase showAcceptTermsViewController];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [(WMNavigationControllerBase *)self.baseController showAcceptTermsViewController];
                [self dismissViewControllerAnimated:YES];
            }
        } else {
            [(WMNavigationControllerBase *)self.presentingViewController showAcceptTermsViewController];
        }
    }
    
    if (UIDevice.currentDevice.isIPad == YES) {
        [(WMToolbar_iPad *)((WMNavigationControllerBase *)self.baseController).customToolBar updateLoginButton];
    }
}

- (void)didReceiveAuthenticationData:(NSNotification*)n {
    DKLog(K_VERBOSE_ONBOARDING, @"auth Data:%@", n);
    
    NSDictionary *userData = [[n userInfo] objectForKey:@"authData"];
    
    NSString *email = @"Wheelmap over OSM";
    if([userData valueForKey:@"email"]){
        email = [userData valueForKey:@"email"];
    }
    [self.dataManager didReceiveAuthenticationData:userData forAccount:email];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end