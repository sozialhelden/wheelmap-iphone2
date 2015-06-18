//
//  WMRegisterViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMRegisterViewController.h"
#import "WMWheelmapAPI.h"
#import "Constants.h"
#import "WMDataManager.h"

@implementation WMRegisterViewController {
    
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
    
    // clear the cookies first, as the webview would otherwise send the api token
    // but at this point, the user did not log into the app, so the satandard app user is sent, which is bad
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    [self.cancelButton setTitle:NSLocalizedString(@"Ready", nil) forState:UIControlStateNormal];
    
    self.webView.scrollView.scrollsToTop = YES;
    
    if (urlString != nil) {
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSLog(@"Loading URL %@", url);
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }/* else {
        [self loadRegisterUrl];
    }*/
    
}

- (void)loadRegisterUrl {
    self.titleLabel.text = NSLocalizedString(@"RegisterNew", nil);

    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, WM_REGISTER_LINK];
    
    //NSURL *url = [NSURL URLWithString:urlString];
    
    //NSLog(@"Loading URL %@", url);
    
	//[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)loadLoginUrl {
    self.titleLabel.text = @"";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, WEB_LOGIN_LINK];
    
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSLog(@"Loading URL %@", url);

	//[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadForgotPasswordUrl {
    self.titleLabel.text = @"";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, FORGOT_PASSWORD_LINK];
    
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSLog(@"Loading URL %@", url);

	//[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView loading failed: %@",error.localizedDescription);
}

-(IBAction)pressedCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"req: %@\n", request);
    if([webView.request.URL.absoluteString containsString:@"www.facebook.com"]){
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
            NSLog(@"install id; %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"installId"]);
            // reload the request
            [webView loadRequest:request2];
        });
    });
    return NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
 /*
    if([webView.request.URL.absoluteString containsString:@"/users/signed_in_token"]){
        NSString *apiToken = [self.webView stringByEvaluatingJavaScriptFromString:@"$('#user_authentication_token').val();"];
        if(![apiToken isEqualToString:@"undefined"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveAuthenticationData"
                                                                object:self
                                                              userInfo:@{@"authData":@{@"api_key":apiToken}}];
            //[self.loginVC.dataManager didReceiveAuthenticationData: forAccount:@"wheelmapApp"];
            [self dismissViewControllerAnimated:YES];
        }
    }
  */
}

@end

