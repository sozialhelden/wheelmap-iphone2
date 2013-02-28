//
//  WMLoginViewController.m
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMLoginViewController.h"
#import "WMDataManager.h"
#import "WMTermsViewController.h"
#import "WMNavigationControllerBase.h"
#import "WMDetailNavigationController.h"
#import "WMNodeListViewController.h"
#import "WMFirstStartViewController.h"

#define FORGOT_PASSWORD_LINK @"/users/password/new"
#define WEB_LOGIN_LINK @"/users/sign_in"

@implementation WMLoginViewController

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
    
    // register for keyboard notifications
    // not necessary on ipad, as theres enough space
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
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
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
        [self presentModalViewController:firstStartViewController animated:YES];
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
}

- (IBAction)loginPressed:(id)sender
{
    
    [dataManager authenticateUserWithEmail:self.usernameTextField.text password:self.passwordTextField.text];
}

- (IBAction)webLoginPressed:(id)sender
{
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", baseURL, WEB_LOGIN_LINK]];
        
    [[UIApplication sharedApplication] openURL:url];
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
            [self dismissModalViewControllerAnimated:YES];
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (self.navigationController != nil) {
                [((WMDetailNavigationController *)self.navigationController).listViewController.controllerBase showAcceptTermsViewController];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [(WMNavigationControllerBase *)self.baseController showAcceptTermsViewController];
                [self dismissModalViewControllerAnimated:YES];
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
        [self dismissModalViewControllerAnimated:YES];
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

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // unregister for keyboard notifications while not visible.
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        // unregister for keyboard notifications while not visible.
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
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
    // resize the scrollview
    CGRect viewFrame = self.view.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.origin.y += 50.0f;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.2];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    // resize the noteView
    CGRect viewFrame = self.view.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.origin.y -= 50.0f;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.2];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320.0f, 550.0f);
}

@end
