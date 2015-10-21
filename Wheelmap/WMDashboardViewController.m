//
//  WMDashboardViewController.m
//  Wheelmap
//
//  Created by npng on 12/2/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDashboardViewController.h"
#import "WMNodeListViewController.h"
#import "WMMapViewController.h"
#import "WMNavigationControllerBase.h"
#import "WMCategoryViewController.h"
#import "WMOSMStartViewController.h"
#import "WMLogoutViewController.h"
#import "WMDataManager.h"
#import "WMCreditsViewController.h"
#import "Reachability.h"
#import "WMWheelmapAPI.h"

@interface WMDashboardViewController ()

@end

@implementation WMDashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    self.navigationController.hidesBottomBarWhenPushed = YES;
    self.containerView.backgroundColor = [UIColor wmBlueColor];
    
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    self.nearbyButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(20.0f, 130.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeNearby];
    [self.nearbyButton addTarget:self action:@selector(pressedNodeListButton:) forControlEvents:UIControlEventTouchUpInside];
    self.mapButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(170.0f, 130.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeMap];
    [self.mapButton addTarget:self action:@selector(pressedMapButton:) forControlEvents:UIControlEventTouchUpInside];
    self.categoriesButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(20.0f, 273.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeCategories];
    [self.categoriesButton addTarget:self action:@selector(pressedCategoriesButton:) forControlEvents:UIControlEventTouchUpInside];
    self.helpButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(170.0f, 273.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeHelp];
    [self.helpButton addTarget:self action:@selector(pressedContributeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchTextField.delegate = self;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTextFieldBg.image = [self.searchTextFieldBg.image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, K_NAVIGATION_BAR_HEIGHT)];
    searchTextFieldOriginalWidth = self.searchTextField.frame.size.width;
    searchTextFieldBgOriginalWidth = self.searchTextFieldBg.frame.size.width;
    
    [self.containerView addSubview:self.nearbyButton];
    [self.containerView addSubview:self.mapButton];
    [self.containerView addSubview:self.categoriesButton];
    [self.containerView addSubview:self.helpButton];
    
    self.searchTextField.placeholder = NSLocalizedString(@"SearchForPlace", nil);
    self.numberOfPlacesLabel.text = @"";
    self.numberOfPlacesLabel.alpha = 0.0;
    self.numberOfPlacesLabel.adjustsFontSizeToFitWidth = YES;
    [dataManager fetchTotalNodeCount];
    
    // search cancel button
    UIImageView* normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    WMLabel* normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    normalBtnLabel.fontSize = 13.0;
    normalBtnLabel.text = NSLocalizedString(@"Cancel", nil);
    normalBtnLabel.textAlignment = NSTextAlignmentCenter;
    normalBtnLabel.textColor = [UIColor whiteColor];
    CGSize expSize = [normalBtnLabel.text boundingRectWithSize:CGSizeMake(100, 17)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:normalBtnLabel.font}
                                                       context:nil].size;
    if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
    normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
    normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 40);
    normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
    [normalBtnImg addSubview:normalBtnLabel];
    searchCancelButton = [WMButton buttonWithType:UIButtonTypeCustom];
    searchCancelButton.frame = CGRectMake(self.searchTextFieldBg.topRightX, self.searchTextFieldBg.frame.origin.y, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
    searchCancelButton.backgroundColor = [UIColor clearColor];
    [searchCancelButton setView:normalBtnImg forControlState:UIControlStateNormal];
    searchCancelButton.hidden = YES;
    [searchCancelButton addTarget:self action:@selector(pressedSearchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:searchCancelButton];
    
    self.nearbyButton.alpha = 0.0;
    self.mapButton.alpha = 0.0;
    self.categoriesButton.alpha = 0.0;
    self.helpButton.alpha = 0.0;
    self.searchTextFieldBg.alpha = 0.0;
    self.searchTextField.alpha = 0.0;
    self.numberOfPlacesLabel.alpha = 0.0;
    self.creditsButton.alpha = 0.0;
    self.loginButton.alpha = 0.0;

	if (WMWheelmapAPI.isStagingBackend == YES) {
		self.logoImageView.image = [UIImage imageNamed:@"start_logo_staging.png"];
	} else {
		self.logoImageView.image = [UIImage imageNamed:@"start_logo.png"];
	}

    self.navigationController.navigationBar.translucent = NO;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self showUIObjectsAnimated:YES];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // this will update screen
    [self networkStatusChanged:nil];
    
    // revert search
    if ([dataManager isInternetConnectionAvailable]) {
        NSLog(@"InternetConnection is available");
        WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
        [navCtrl pressedCurrentLocationButton:nil];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pressedSearchCancelButton:(WMButton*)btn
{
    // dismiss the keyboard
    self.searchTextField.text = nil;
    [self hideCancelButton];
    [self.searchTextField resignFirstResponder];
    
}

-(IBAction)pressedNodeListButton:(id)sender
{
    // set the filters here
    //WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    //[navCtrl clearWheelChairFilterStatus];
    //[navCtrl clearCategoryFilterStatus];
    [self pressedSearchCancelButton:searchCancelButton];
	[(WMNavigationControllerBase *)self.navigationController setListViewControllerToNormal];
    [(WMNavigationControllerBase *)self.navigationController pushList];
    
}

-(IBAction)pressedMapButton:(id)sender
{
    // set the filters here
    //WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    //[navCtrl clearWheelChairFilterStatus];
    //[navCtrl clearCategoryFilterStatus];
    
    [self pressedSearchCancelButton:searchCancelButton];
    [(WMNavigationControllerBase *)self.navigationController setMapControllerToNormal];
    [(WMNavigationControllerBase *)self.navigationController pushMap];
}

-(IBAction)pressedContributeButton:(id)sender
{
    // set the filters here
    //WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    //[navCtrl clearWheelChairFilterStatus];
    //[navCtrl clearCategoryFilterStatus];
    //for (NSString* key in [navCtrl.wheelChairFilterStatus allKeys]) {
    //    if ([key isEqualToString:@"unknown"]) {
    //        [navCtrl.wheelChairFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
    //    } else {
    //        [navCtrl.wheelChairFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:key];
    //    }
    //}
    
    //
    // we filter unknown nodes not using global filter setting!
    
    WMNodeListViewController* nodeListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];
    nodeListVC.useCase = kWMNodeListViewControllerUseCaseContribute;
    [(WMNavigationControllerBase *)self.navigationController setMapControllerToContribute];
    [self.navigationController pushViewController:nodeListVC animated:YES];
    [self pressedSearchCancelButton:searchCancelButton];
}

-(IBAction)pressedCategoriesButton:(id)sender
{
    WMCategoryViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMCategoryViewController"];
    vc.baseController = self.navigationController;
    
    [self.navigationController pushViewController:vc animated:YES];
    [self pressedSearchCancelButton:searchCancelButton];
}

-(IBAction)pressedLoginButton:(id)sender
{
    WMViewController* vc;
    if (!dataManager.userIsAuthenticated) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMOSMStartViewController"];
    } else {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMLogoutViewController"];
    }
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark - Search text field delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self showCancelButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [self hideCancelButton];
    if (textField.text == nil || textField.text.length == 0)
        return YES;
    
    WMNodeListViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];
    vc.useCase = kWMNodeListViewControllerUseCaseGlobalSearch;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    WMNavigationControllerBase* dataSource = (WMNavigationControllerBase*)self.navigationController;
    [dataSource updateNodesWithQuery:textField.text andRegion:dataSource.mapViewController.region];
    
    return YES;
}

#pragma mark - Search Cancel Button animation
-(void)showCancelButton
{
    searchCancelButton.alpha = 0.0;
    searchCancelButton.hidden = NO;
    [UIView animateWithDuration:0.3
                          delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void)
     {
         self.searchTextField.frame = CGRectMake(self.searchTextField.frame.origin.x, self.searchTextField.frame.origin.y, searchTextFieldOriginalWidth-searchCancelButton.frame.size.width-5, self.searchTextField.frame.size.height);
         self.searchTextFieldBg.frame = CGRectMake(self.searchTextFieldBg.frame.origin.x, self.searchTextFieldBg.frame.origin.y, searchTextFieldBgOriginalWidth-searchCancelButton.frame.size.width-5, self.searchTextFieldBg.frame.size.height);
         
         searchCancelButton.transform = CGAffineTransformMakeTranslation(-searchCancelButton.frame.size.width, 0);
         searchCancelButton.alpha = 1.0;
         
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    
}

-(void)hideCancelButton
{
    searchCancelButton.alpha = 1.0;
    searchCancelButton.hidden = NO;
    [UIView animateWithDuration:0.3
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void)
     {
         self.searchTextField.frame = CGRectMake(self.searchTextField.frame.origin.x, self.searchTextField.frame.origin.y, searchTextFieldOriginalWidth, self.searchTextField.frame.size.height);
         self.searchTextFieldBg.frame = CGRectMake(self.searchTextFieldBg.frame.origin.x, self.searchTextFieldBg.frame.origin.y, searchTextFieldBgOriginalWidth, self.searchTextFieldBg.frame.size.height);
         
         searchCancelButton.transform = CGAffineTransformMakeTranslation(0, 0);
         searchCancelButton.alpha = 0.0;
         
     }
                     completion:^(BOOL finished)
     {
         searchCancelButton.hidden = YES;
         
     }];
    
}

#pragma mark - WMDataManager Delegate
-(void) dataManager:(WMDataManager *)dataManager didReceiveTotalNodeCount:(NSNumber *)count
{
    
    NSLog(@"Got new node count %@", count);
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedCount = [formatter stringFromNumber:count];
    
    self.numberOfPlacesLabel.text = [NSString stringWithFormat:@"%@ %@", formattedCount, NSLocalizedString(@"Places", nil)];
    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void)
     {
         self.numberOfPlacesLabel.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    
}

-(void)dataManager:(WMDataManager *)dataManager fetchTotalNodeCountFailedWithError:(NSError *)error
{
    NSLog(@"[Error] getting total count failed with error %@", error);
    
    NSNumber *totalCountFromFile = [dataManager totalNodeCountFromUserDefaults];
    if (totalCountFromFile != nil) {
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *formattedCount = [formatter stringFromNumber:totalCountFromFile];
        
        self.numberOfPlacesLabel.text = [NSString stringWithFormat:@"%@ %@", formattedCount, NSLocalizedString(@"Places", nil)];
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void)
     {
         self.numberOfPlacesLabel.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    
}

-(void)showUIObjectsAnimated:(BOOL)animated
{
    if (isUIObjectsReadyToInteract)
        return;
    
    CGFloat duration = 0.0;
    if (animated)
        duration = 0.5;
    
    [self.loadingWheel stopAnimating];
    
    [UIView animateWithDuration:duration
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void)
     {
         self.nearbyButton.alpha = 1.0;
         self.mapButton.alpha = 1.0;
         self.categoriesButton.alpha = 1.0;
         self.helpButton.alpha = 1.0;
         self.searchTextFieldBg.alpha = 1.0;
         self.searchTextField.alpha = 1.0;
         self.numberOfPlacesLabel.alpha = 1.0;
         self.creditsButton.alpha = 1.0;
         self.loginButton.alpha = 1.0;
         
         
     }
                     completion:^(BOOL finished)
     {
         isUIObjectsReadyToInteract = YES;
         
         
     }];
    
}

#pragma mark - Network Status Changes
-(void)networkStatusChanged:(NSNotification*)notice
{
    NetworkStatus networkStatus = [[dataManager internetReachble] currentReachabilityStatus];
    
    switch (networkStatus)
    {
        case NotReachable:
            
            self.searchTextField.placeholder = NSLocalizedString(@"NoSearchService", nil);
            self.searchTextField.textColor = [UIColor whiteColor];
            [self.searchTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
            self.searchTextField.userInteractionEnabled = NO;
            self.searchTextFieldBg.alpha = 0.3;
            
            [self.loginButton setImage:[UIImage imageNamed:@"start_icon-login.png"] forState:UIControlStateNormal];
            self.loginButton.enabled = NO;
            
            break;
            
        default:
            
            self.searchTextField.placeholder = NSLocalizedString(@"SearchForPlace", nil);
            self.searchTextField.textColor = [UIColor whiteColor];
            [self.searchTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
            self.searchTextField.userInteractionEnabled = YES;
            self.searchTextFieldBg.alpha = 1.0;
            
            self.loginButton.enabled = YES;
            // update login icon image here
            if ([dataManager userIsAuthenticated]) {
                [self.loginButton setImage:[UIImage imageNamed:@"start_icon-logged-in.png"] forState:UIControlStateNormal];
            } else {
                [self.loginButton setImage:[UIImage imageNamed:@"start_icon-login.png"] forState:UIControlStateNormal];
            }
            
            
            break;
    }
}

@end
