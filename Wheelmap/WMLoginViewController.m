//
//  WMLoginViewController.m
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMLoginViewController.h"
#import "WMDataManager.h"
//#import "WMTermsViewController.h"
#import "WMNavigationControllerBase.h"
#import "WMDetailNavigationController.h"
#import "WMNodeListViewController.h"
#import "WMFirstStartViewController.h"
#import "Constants.h"
#import "WMRegisterViewController.h"

@interface WMLoginViewController()

@property(nonatomic,strong)UITextField* activeTextField;

@end

@implementation WMLoginViewController

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
	
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    // register for keyboard notifications (not necessary on ipad, as theres enough space)
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:self.view.window];
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:self.view.window];
    }
    
    // register to dismiss keyboard when background touched
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    self.titleLabel.text = NSLocalizedString(@"Sign In", nil);
    self.topTextLabel.text = NSLocalizedString(@"Sign In Prompt", nil);
    self.forgotPasswordTextView.text = NSLocalizedString(@"LoginScreenForgotPassword", nil);
    self.middleTextLabel.text = NSLocalizedString(@"LoginScreenNoWheelmapAccount", nil);
    self.webLoginLabel.text = NSLocalizedString(@"Sign In Button", nil);
    self.bottomTextLabel.text = NSLocalizedString(@"Sign Up Prompt", nil);
    [self.doneButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"Sign In Button", nil) forState:UIControlStateNormal];
    [self.registerButton setTitle:NSLocalizedString(@"RegisterNew", nil) forState:UIControlStateNormal];
    self.usernameTextField.placeholder = NSLocalizedString(@"UsernamePlaceholder", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
    
    // adjust labels and buttons according to content
    [self adjustLabelHeightToText:self.topTextLabel];
    self.usernameTextField.frame = CGRectMake(self.usernameTextField.frame.origin.x, self.topTextLabel.frame.origin.y + self.topTextLabel.frame.size.height + 20.0f,
                                              self.usernameTextField.frame.size.width, self.usernameTextField.frame.size.height);
    self.passwordTextField.frame = CGRectMake(self.passwordTextField.frame.origin.x, self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 20.0f,
                                              self.passwordTextField.frame.size.width, self.passwordTextField.frame.size.height);
    
    
    self.forgotPasswordTextView.frame = CGRectMake(self.forgotPasswordTextView.frame.origin.x, self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height + 10.0f, self.forgotPasswordTextView.frame.size.width, self.forgotPasswordTextView.contentSize.height);
    
    self.forgotPasswordButton.frame = self.forgotPasswordTextView.frame;
    
    [self.loginButton setBackgroundImage:[[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 10)] forState:UIControlStateNormal];
    self.loginButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.loginButton sizeToFit];
    self.loginButton.frame = CGRectMake(320.0f - self.loginButton.frame.size.width - 10.0f, self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height + 10.0f, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
    
    
    self.middleTextLabel.frame = CGRectMake(self.middleTextLabel.frame.origin.x, self.loginButton.frame.origin.y + self.loginButton.frame.size.height + 15.0f, self.middleTextLabel.frame.size.width, self.middleTextLabel.frame.size.height);
    [self adjustLabelHeightToText:self.middleTextLabel];
    
    self.webLoginLabel.frame = CGRectMake(self.webLoginLabel.frame.origin.x, self.middleTextLabel.frame.origin.y + self.middleTextLabel.frame.size.height, self.webLoginLabel.frame.size.width, self.webLoginLabel.frame.size.height);
    [self adjustLabelHeightToText:self.webLoginLabel];
    
    self.webLoginButton.frame = self.webLoginLabel.frame;
    
    self.bottomTextLabel.frame = CGRectMake(self.bottomTextLabel.frame.origin.x, self.webLoginLabel.frame.origin.y + self.webLoginLabel.frame.size.height + 15.0f, self.bottomTextLabel.frame.size.width, self.bottomTextLabel.frame.size.height);
    [self adjustLabelHeightToText:self.bottomTextLabel];
    
    self.registerButton.frame = CGRectMake(self.registerButton.frame.origin.x, self.bottomTextLabel.frame.origin.y + self.bottomTextLabel.frame.size.height + 15.0f, self.registerButton.frame.size.width, self.registerButton.frame.size.height);
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, self.registerButton.frame.origin.y + self.registerButton.frame.size.height + 20.0f);
    
    // TODO: show last logged in user name
    
    if ([[dataManager legacyUserCredentials] objectForKey:@"email"]) {
        // the value is not nil -> user has logged in on the version 1.0 and the app is freshly updated to v. 2.0. -> we show the old user name, but do not login due to the new terms.
        self.usernameTextField.text = [[dataManager legacyUserCredentials] objectForKey:@"email"];
    } else {
        self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"WheelmapLastUserName"];
    }
    
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
        
        WMFirstStartViewController *firstStartViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMFirstStart"];
        [self presentViewController:firstStartViewController animated:YES];
        
        [dataManager firstLaunchOccurred];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgotPasswordButtonPressed {
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", baseURL, FORGOT_PASSWORD_LINK]];
    
    
    [[UIApplication sharedApplication] openURL:url];
    
    // use this when websites are optimized for mobile
    //    WMRegisterViewController *regViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMRegisterVC"];
    //    [regViewController loadForgotPasswordUrl];
    //    [self presentModalViewController:regViewController animated:YES];
}

- (IBAction)registerPressed:(id)sender
{
    WMRegisterViewController *regViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMRegisterVC"];
    [regViewController loadRegisterUrl];
    [self presentViewController:regViewController animated:YES];
}

- (IBAction)loginPressed:(id)sender
{
    
    [dataManager authenticateUserWithEmail:self.usernameTextField.text password:self.passwordTextField.text];
}

- (IBAction)webLoginPressed:(id)sender
{
    //NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    //NSString *baseURL = config[@"apiBaseURL"];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", baseURL, WEB_LOGIN_LINK]];
    
    //[[UIApplication sharedApplication] openURL:url];
    
    // use this when websites are optimized for mobile
    WMRegisterViewController *regViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"WMRegisterVC"];
    [regViewController loadLoginUrl];
    [self presentViewController:regViewController animated:YES];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.usernameTextField){
        [self.passwordTextField becomeFirstResponder];
    } else {
        
        [textField resignFirstResponder];
        [self loginPressed:self.loginButton];
    }
    return YES;
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

- (void)dealloc {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // unregister for keyboard notifications while not visible.
    /*
     [[NSNotificationCenter defaultCenter] removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
     // unregister for keyboard notifications while not visible.
     [[NSNotificationCenter defaultCenter] removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
     */
}

- (void)keyboardWillHide:(NSNotification *)n
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    NSDictionary* info = [n userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0,0,keyboardSize.height,0); // TODO check why 44px missing (view behind bottom bar?)
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, CGPointMake(0, CGRectGetMaxY(self.activeTextField.frame))) ) {
        [self.contentScrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.activeTextField = textField;
}

-(void)dismissKeyboard{
    [self.view endEditing:YES];
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320.0f, 550.0f);
}
@end