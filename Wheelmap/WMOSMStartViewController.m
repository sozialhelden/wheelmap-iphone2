//
//  WMOSMStartViewController.m
//  Wheelmap
//
//  Created by Dirk Tech on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMOSMStartViewController.h"
#import "WMDataManager.h"
#import "WMNavigationControllerBase.h"
#import "WMDetailNavigationController.h"
#import "WMNodeListViewController.h"
#import "WMOSMDescribeViewController.h"
#import "Constants.h"
//#import "WMRegisterViewController.h"
#import "WMOSMLoginViewController.h"

@implementation WMOSMStartViewController

@synthesize dataManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController != nil) {
        self.headerView.hidden = YES;
        self.contentScrollView.frame = CGRectMake(self.contentScrollView.frame.origin.x, 0.0f, self.contentScrollView.frame.size.width, self.view.frame.size.height);
    }
    
    self.contentScrollView.scrollsToTop = YES;
    
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAuthenticationData:)
                                                 name:@"didReceiveAuthenticationData"
                                               object:nil];
    /*
    self.titleLabel.text = NSLocalizedString(@"Sign In", nil);
    self.topTextLabel.text = NSLocalizedString(@"Sign In Prompt", nil);
    self.forgotPasswordTextView.text = NSLocalizedString(@"LoginScreenForgotPassword", nil);
    self.middleTextLabel.text = NSLocalizedString(@"LoginScreenNoWheelmapAccount", nil);
    self.webLoginLabel.text = NSLocalizedString(@"Sign In Button", nil);
    self.bottomTextLabel.text = NSLocalizedString(@"Sign Up Prompt", nil);
     */
    [self.doneButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    /*
    [self.loginButton setTitle:NSLocalizedString(@"Sign In Button", nil) forState:UIControlStateNormal];
    [self.registerButton setTitle:NSLocalizedString(@"RegisterNew", nil) forState:UIControlStateNormal];
    self.usernameTextField.placeholder = NSLocalizedString(@"UsernamePlaceholder", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
    */
    // adjust labels and buttons according to content
//    [self adjustLabelHeightToText:self.topTextLabel];

    self.topTextLabel.text = NSLocalizedString(@"LoginOverOSMText", nil);
    self.stepsLabel.text = NSLocalizedString(@"OSMAccount", nil);
    
    self.stepsTextView.frame = CGRectMake(self.stepsTextView.frame.origin.x, self.stepsTextView.frame.origin.y + self.stepsTextView.frame.size.height + 10.0f, self.stepsTextView.frame.size.width, self.stepsTextView.contentSize.height);
    
    self.stepsTextView.frame = self.stepsTextView.frame;
    self.stepsTextView.text = NSLocalizedString(@"StepsToOSMAccount", nil);
    
    
    [self.loginButton setBackgroundImage:[[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 10)] forState:UIControlStateNormal];
    self.loginButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.loginButton sizeToFit];
    self.loginButton.frame = CGRectMake(320.0f - self.loginButton.frame.size.width - 10.0f, self.stepsTextView.frame.origin.y + self.stepsTextView.frame.size.height + 10.0f, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
    [self.loginButton setTitle:NSLocalizedString(@"LoginOverOSM", nil) forState:UIControlStateNormal];
    
    self.registerButton.frame = CGRectMake(self.registerButton.frame.origin.x, self.loginButton.frame.origin.y + self.loginButton.frame.size.height + 25.0f, self.registerButton.frame.size.width, self.registerButton.frame.size.height);
    [self.registerButton setTitle:@"OSMRegistration" forState:UIControlStateNormal];
    
    [self.whyButton setTitle:@"WhyOSMAccount" forState:UIControlStateNormal];
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, self.registerButton.frame.origin.y + self.registerButton.frame.size.height + 20.0f);
    
}

- (void)adjustLabelHeightToText:(UILabel *)label {
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text boundingRectWithSize:maximumLabelSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:label.font}
                                                        context:nil].size;
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self showFirstStartScreen];
}

- (void)showFirstStartScreen {
    if ([dataManager isFirstLaunch]) {
        /*
        WMFirstStartViewController *firstStartViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMFirstStart"];
         */
        WMOSMDescribeViewController *firstStartViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMOSMDescribe"];
        [self presentViewController:firstStartViewController animated:YES];
        
        [dataManager firstLaunchOccurred];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)registerPressed:(id)sender
{
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", baseURL, WEB_LOGIN_LINK]]];
}

- (IBAction)loginPressed:(id)sender
{
    WMOSMLoginViewController *osmLoginViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMOSMLoginVC"];
    [osmLoginViewController loadLoginUrl];
    [self presentViewController:osmLoginViewController animated:YES];
}

- (void)dataManager:(WMDataManager *)dataManager userAuthenticationFailedWithError:(NSError *)error
{
    // TODO: handle error
    NSLog(@"Login failed! %@", error);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"User Credentials Error", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [(WMToolBar_iPad *)((WMNavigationControllerBase *)self.baseController).customToolBar updateLoginButton];
    }
}

- (void)dataManagerDidAuthenticateUser:(WMDataManager *)aDataManager
{
    // TODO: handle success, dismiss view controller
    NSLog(@"Login success!");
    
    if ([dataManager areUserTermsAccepted]) {
        
        if (self.navigationController != nil) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES];
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (self.navigationController != nil) {
                [((WMDetailNavigationController *)self.navigationController).listViewController.controllerBase showAcceptTermsViewController];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [(WMNavigationControllerBase *)self.baseController showAcceptTermsViewController];
                [self dismissViewControllerAnimated:YES];
            }
        } else {
            [(WMNavigationControllerBase *)self.presentingViewController showAcceptTermsViewController];
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [(WMToolBar_iPad *)((WMNavigationControllerBase *)self.baseController).customToolBar updateLoginButton];
    }
}

- (IBAction)donePressed:(id)sender {
    
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES];
    }
}

- (IBAction)whyOSMPressed:(id)sender {
    
    WMOSMDescribeViewController *osmDescribeViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMOSMDescribeViewController"];
    [self presentViewController:osmDescribeViewController animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // unregister for keyboard notifications while not visible.
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
    [super viewDidDisappear:animated];
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320.0f, 550.0f);
}

- (void) didReceiveAuthenticationData:(NSNotification*)n{
    NSLog(@"auth Data:%@", n);
    
    NSDictionary *userData = [[n userInfo] objectForKey:@"authData"];
    
    NSString *email = @"Wheelmap over OSM";
    if([userData valueForKey:@"email"]){
        email = [userData valueForKey:@"email"];
    }
    [self.dataManager didReceiveAuthenticationData:userData forAccount:email];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end