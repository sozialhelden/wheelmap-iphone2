//
//  WMDashboardViewController.h
//  Wheelmap
//
//  Created by npng on 12/2/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDashboardButton.h"
#import "WMDataManager.h"
#import "WMDataManagerDelegate.h"

@interface WMDashboardViewController : WMViewController <UITextFieldDelegate, WMDataManagerDelegate>
{
    WMDataManager* dataManager;
    WMButton* searchCancelButton;
    
    CGFloat searchTextFieldOriginalWidth;
    CGFloat searchTextFieldBgOriginalWidth;

    BOOL isUIObjectsReadyToInteract;
}

@property (nonatomic, strong) IBOutlet UIView *						containerView;

@property (nonatomic, strong) IBOutlet UIImageView *				searchTextFieldBg;
@property (nonatomic, strong) IBOutlet UITextField *				searchTextField;
@property (nonatomic, strong) IBOutlet UILabel *					numberOfPlacesLabel;

@property (nonatomic, strong) WMDashboardButton *					nearbyButton;
@property (nonatomic, strong) WMDashboardButton *					mapButton;
@property (nonatomic, strong) WMDashboardButton *					categoriesButton;
@property (nonatomic, strong) WMDashboardButton *					helpButton;
@property (nonatomic, strong) IBOutlet UIButton *					creditsButton;
@property (nonatomic, strong) IBOutlet UIButton *					loginButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView	*	loadingWheel;

@property (weak, nonatomic) IBOutlet UIImageView *					logoImageView;

-(IBAction)pressedNodeListButton:(id)sender;
-(IBAction)pressedMapButton:(id)sender;
-(IBAction)pressedContributeButton:(id)sender;
-(IBAction)pressedCategoriesButton:(id)sender;
-(IBAction)pressedLoginButton:(id)sender;

-(void)showUIObjectsAnimated:(BOOL)animated;

@end
