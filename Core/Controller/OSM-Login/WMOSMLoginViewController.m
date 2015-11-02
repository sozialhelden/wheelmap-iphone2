//
//  WMOSMLoginViewController.m
//  Wheelmap
//
//  Created by Dirk Tech on 04/30/15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMOSMLoginViewController.h"
#import "WMWheelmapAPI.h"
#import "WMDataManager.h"
#import "WMOSMDescriptionViewController.h"

@implementation WMOSMLoginViewController {
    
    NSString *urlString;
}


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


    [self.navigationBar setBackgroundColor:[UIColor wmNavigationBackgroundColor]];
    // clear the cookies first, as the webview would otherwise send the api token
    // but at this point, the user did not log into the app, so the satandard app user is sent, which is bad
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    self.webView.scrollView.scrollsToTop = YES;
    
    if (urlString != nil) {
        NSURL *url = [NSURL URLWithString:urlString];

        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)loadRegisterUrl {
    self.titleLabel.text = NSLocalizedString(@"RegisterNew", nil);

	urlString = [NSString stringWithFormat:@"%@%@", WMWheelmapAPI.baseUrl, WM_REGISTER_LINK];
}

- (void)loadLoginUrl {
    self.titleLabel.text = @"";

    urlString = [NSString stringWithFormat:@"%@%@", WMWheelmapAPI.baseUrl, WEB_LOGIN_LINK];
}

- (void)loadForgotPasswordUrl {
    self.titleLabel.text = @"";

    urlString = [NSString stringWithFormat:@"%@%@", WMWheelmapAPI.baseUrl, FORGOT_PASSWORD_LINK];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DKLog(K_VERBOSE_ONBOARDING, @"WebView loading failed: %@",error.localizedDescription);
}

- (IBAction)pressedCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if([request.URL.absoluteString containsString:@"www.facebook.com"]){
        return NO;
    }
    
    if([request.URL.scheme isEqualToString:@"wheelmap"]){
        
        NSString *apiToken = @"undefined";
        NSString *email = @"WheelmapUserOverOSM";
        NSNumber *privacy_policy = [NSNumber numberWithBool:FALSE];
        NSNumber *terms = [NSNumber numberWithBool:FALSE];
        NSString *url = request.URL.absoluteString;
        
        NSArray *comp1 = [url componentsSeparatedByString:@"?"];
        NSString *query = [comp1 lastObject];
        NSArray *queryElements = [query componentsSeparatedByString:@"&"];
        for (NSString *element in queryElements) {
            NSArray *keyVal = [element componentsSeparatedByString:@"="];
            if (keyVal.count > 0) {
                NSString *variableKey = [keyVal objectAtIndex:0];
                NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : nil;
                if([variableKey isEqualToString:@"token"]){
                    apiToken = value;
                }else if([variableKey isEqualToString:@"email"] && value!=nil){
                    email = value;
                }else if([variableKey isEqualToString:@"privacy_accepted"] && value!=nil && [value isEqualToString:@"true"]){
                    privacy_policy = [NSNumber numberWithBool:TRUE];
                }else if([variableKey isEqualToString:@"terms_accepted"] && value!=nil && [value isEqualToString:@"true"]){
                    terms = [NSNumber numberWithBool:TRUE];
                }
            }
        }
        
        if(![apiToken isEqualToString:@"undefined"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveAuthenticationData"
                                                                object:self
                                                              userInfo:@{@"authData":@{@"api_key":apiToken, @"email":email, @"privacy_accepted":privacy_policy , @"terms_accepted":terms}}];
            //[self.loginVC.dataManager didReceiveAuthenticationData: forAccount:@"wheelmapApp"];
            [self dismissViewControllerAnimated:YES];
        }
        
        return NO;
    }
    
    BOOL headerIsPresent = [[request allHTTPHeaderFields] objectForKey:@"Install-Id"]!=nil;
    
    if(headerIsPresent || (![request.URL.absoluteString containsString:@"/users/auth/osm/callback"])) return YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *url = [request URL];
            NSMutableURLRequest* request2 = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [request2 setHTTPMethod:@"GET"];
            // set the new headers
            [request2 setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"installId"] forHTTPHeaderField:@"Install-ID"];
            DKLog(K_VERBOSE_ONBOARDING, @"install id; %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"installId"]);
            // reload the request
            [webView loadRequest:request2];
        });
    });
    return NO;
}

-(IBAction)whyOSM:(id)sender {
    WMOSMDescriptionViewController *osmDescriptionViewController = [UIStoryboard instantiatedDescriptionViewController];
    [self presentViewController:osmDescriptionViewController animated:YES];
}

@end

