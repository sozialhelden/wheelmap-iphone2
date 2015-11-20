//
//  WMDashboardViewController.m
//  Wheelmap
//
//  Created by npng on 12/2/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDashboardViewController.h"
#import "WMPOIsListViewController.h"
#import "WMMapViewController.h"
#import "WMNavigationControllerBase.h"
#import "WMCategoriesListViewController.h"
#import "WMOSMOnboardingViewController.h"
#import "WMOSMLogoutViewController.h"
#import "WMDataManager.h"
#import "WMCreditsViewController.h"
#import "WMWheelmapAPI.h"

@interface WMDashboardViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *					logoImageView;

@property (nonatomic, strong) IBOutlet UIImageView *				searchTextFieldBg;
@property (nonatomic, strong) IBOutlet UITextField *				searchTextField;

@property (weak, nonatomic) IBOutlet UIView *						nearbyButtonView;
@property (weak, nonatomic) IBOutlet UILabel *						nearbyButtonTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *						mapButtonView;
@property (weak, nonatomic) IBOutlet UILabel *						mapButtonTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *						categoryButtonView;
@property (weak, nonatomic) IBOutlet UILabel *						categoriesButtonTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *						contributeButtonView;
@property (weak, nonatomic) IBOutlet UILabel *						contributeButtonTitleLabel;

@property (weak, nonatomic) IBOutlet WMButton *						cancelSearchButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *			cancelSearchButtonTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *			cancelSearchButtonWidthConstraint;

@property (nonatomic, strong) IBOutlet UIButton *					creditsButton;
@property (nonatomic, strong) IBOutlet UIButton *					loginButton;

@property (nonatomic, strong) IBOutlet UILabel *					numberOfPlacesLabel;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView	*	loadingWheel;

@property (nonatomic) BOOL											didLayoutSubviews;

@end

@implementation WMDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[self showIntroViewControllerIfNecessary];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    self.navigationController.hidesBottomBarWhenPushed = YES;

    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    self.searchTextField.delegate = self;
    self.searchTextField.placeholder = NSLocalizedString(@"SearchForPlace", nil);
    self.numberOfPlacesLabel.text = @"";
    [dataManager fetchTotalNodeCount];

	[self.cancelSearchButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];

	if (WMWheelmapAPI.isStagingBackend == YES) {
		self.logoImageView.image = [UIImage imageNamed:@"start_logo_staging.png"];
	} else {
		self.logoImageView.image = [UIImage imageNamed:@"start_logo.png"];
	}

	[self initButtons];
	
    self.navigationController.navigationBar.translucent = NO;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

	[self hideAllViews];

    [self showUIObjectsAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // this will update screen
    [self networkStatusChanged:nil];
    
    // revert search
    if ([dataManager isInternetConnectionAvailable]) {
        WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
        [navCtrl pressedCurrentLocationButton:nil];
    }
}

- (void)viewDidLayoutSubviews {
	if (self.didLayoutSubviews == NO) {
		self.didLayoutSubviews = YES;

		// Init cancel button width and adjust it's position to the base hidden position.
		[self.cancelSearchButton layoutIfNeeded];
		self.cancelSearchButtonWidthConstraint.constant = self.cancelSearchButton.titleLabel.bounds.size.width;
		[self.cancelSearchButton layoutIfNeeded];
		[self hideCancelButton];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark

- (void)initButtons {
	self.nearbyButtonTitleLabel.text = L(@"DashboardNearby");
	self.mapButtonTitleLabel.text = L(@"DashboardMap");
	self.categoriesButtonTitleLabel.text = L(@"DashboardCategories");
	self.contributeButtonTitleLabel.text = L(@"DashboardHelp");
}

- (void)showIntroViewControllerIfNecessary {
	if (WMHelper.shouldShowIntroViewController == YES) {
		[self presentViewController:UIStoryboard.instantiatedIntroViewController animated:YES];
	}
}

#pragma mark - IBActions

- (IBAction)pressedCancelSearchButton:(id)sender {
	self.searchTextField.text = nil;
	[self hideCancelButton];
	[self.searchTextField resignFirstResponder];
}

- (IBAction)pressedNearbyButton:(id)sender {
    [self pressedCancelSearchButton:self.cancelSearchButton];
	[(WMNavigationControllerBase *)self.navigationController setListViewControllerToNormal];
    [(WMNavigationControllerBase *)self.navigationController pushList];
    
}

- (IBAction)pressedMapButton:(id)sender {
    [self pressedCancelSearchButton:self.cancelSearchButton];
    [(WMNavigationControllerBase *)self.navigationController setMapControllerToNormal];
    [(WMNavigationControllerBase *)self.navigationController pushMap];
}

- (IBAction)pressedContributeButton:(id)sender {
    // we filter unknown nodes not using global filter setting!
    
    WMPOIsListViewController* nodeListVC = [UIStoryboard instantiatedPOIsListViewController];
    nodeListVC.useCase = kWMPOIsListViewControllerUseCaseContribute;
    [(WMNavigationControllerBase *)self.navigationController setMapControllerToContribute];
    [self.navigationController pushViewController:nodeListVC animated:YES];
    [self pressedCancelSearchButton:self.cancelSearchButton];
}

- (IBAction)pressedCategoriesButton:(id)sender {
    WMCategoriesListViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMCategoriesListViewController"];
    vc.baseController = self.navigationController;
    
    [self.navigationController pushViewController:vc animated:YES];
    [self pressedCancelSearchButton:self.cancelSearchButton];
}

- (IBAction)pressedLoginButton:(id)sender {
    WMViewController* vc;
    if (!dataManager.userIsAuthenticated) {
        vc = [UIStoryboard instantiatedOSMOnboardingViewController];
    } else {
        vc = [UIStoryboard instantiatedOSMLogoutViewController];
    }
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Search text field delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showCancelButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self hideCancelButton];
    if (textField.text == nil || textField.text.length == 0)
        return YES;
    
    WMPOIsListViewController* vc = [UIStoryboard instantiatedPOIsListViewController];
    vc.useCase = kWMPOIsListViewControllerUseCaseGlobalSearch;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    WMNavigationControllerBase* dataSource = (WMNavigationControllerBase*)self.navigationController;
    [dataSource updateNodesWithQuery:textField.text andRegion:dataSource.mapViewController.region];
    
    return YES;
}

#pragma mark - Search Cancel Button animation

- (void)showCancelButton {
	self.cancelSearchButtonTrailingConstraint.constant = 20;

	[UIView animateWithDuration:0.3
						  delay:0.0 options:UIViewAnimationOptionCurveEaseIn
					 animations:^(void) {
						 [self.view layoutIfNeeded];
					 } completion:nil];

}

- (void)hideCancelButton {
	self.cancelSearchButtonTrailingConstraint.constant = -self.cancelSearchButton.frameWidth;

    [UIView animateWithDuration:0.3
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
						 [self.view layoutIfNeeded];
					 } completion:nil];
}

#pragma mark - WMDataManager Delegate

- (void) dataManager:(WMDataManager *)aDataManager didReceiveTotalNodeCount:(NSNumber *)count {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedCount = [formatter stringFromNumber:count];
    
    self.numberOfPlacesLabel.text = [NSString stringWithFormat:@"%@ %@", formattedCount, NSLocalizedString(@"Places", nil)];
    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
         self.numberOfPlacesLabel.alpha = 1.0;
     } completion:nil];
}

- (void)dataManager:(WMDataManager *)aDataManager fetchTotalNodeCountFailedWithError:(NSError *)error {
    NSNumber *totalCountFromFile = [aDataManager totalNodeCountFromUserDefaults];
    if (totalCountFromFile != nil) {
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *formattedCount = [formatter stringFromNumber:totalCountFromFile];
        
        self.numberOfPlacesLabel.text = [NSString stringWithFormat:@"%@ %@", formattedCount, NSLocalizedString(@"Places", nil)];
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
         self.numberOfPlacesLabel.alpha = 1.0;
     } completion:nil];
}

- (void)hideAllViews {
	self.numberOfPlacesLabel.alpha = 0.0;
	self.nearbyButtonView.alpha = 0.0;
	self.mapButtonView.alpha = 0.0;
	self.categoryButtonView.alpha = 0.0;
	self.contributeButtonView.alpha = 0.0;
	self.searchTextFieldBg.alpha = 0.0;
	self.searchTextField.alpha = 0.0;
	self.cancelSearchButton.alpha = 0.0;
	self.numberOfPlacesLabel.alpha = 0.0;
	self.creditsButton.alpha = 0.0;
	self.loginButton.alpha = 0.0;
}

- (void)showAllViews {
	self.nearbyButtonView.alpha = 1.0;
	self.mapButtonView.alpha = 1.0;
	self.categoryButtonView.alpha = 1.0;
	self.contributeButtonView.alpha = 1.0;
	self.searchTextFieldBg.alpha = 1.0;
	self.searchTextField.alpha = 1.0;
	self.cancelSearchButton.alpha = 1.0;
	self.numberOfPlacesLabel.alpha = 1.0;
	self.creditsButton.alpha = 1.0;
	self.loginButton.alpha = 1.0;
}

- (void)showUIObjectsAnimated:(BOOL)animated {
    if (isUIObjectsReadyToInteract)
        return;
    
    CGFloat duration = 0.0;
	if (animated) {
        duration = 0.5;
	}
    
    [self.loadingWheel stopAnimating];
    
    [UIView animateWithDuration:duration
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
						 [self showAllViews];
					 } completion:^(BOOL finished) {
						 isUIObjectsReadyToInteract = YES;
					 }];
    
}

#pragma mark - Network Status Changes

- (void)networkStatusChanged:(NSNotification*)notice {
    NetworkStatus networkStatus = [[dataManager internetReachble] currentReachabilityStatus];
    
    switch (networkStatus) {
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
