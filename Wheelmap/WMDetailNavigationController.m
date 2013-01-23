//
//  WMDetailNavigationController.m
//  Wheelmap
//
//  Created by Michael Thomas on 23.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMDetailNavigationController.h"
#import "WMDetailViewController.h"
#import "WMEditPOIViewController.h"

@interface WMDetailNavigationController ()

@end

@implementation WMDetailNavigationController {
    WMDataManager *dataManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        dataManager = [[WMDataManager alloc] init];
        
        // set custom nagivation and tool bars
        self.navigationBar.frame = CGRectMake(0, self.navigationBar.frame.origin.y, self.view.frame.size.width, 60);
        
        self.customNavigationBar = [[WMNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, 50)];
        self.customNavigationBar.delegate = self;
        [self.navigationBar addSubview:self.customNavigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pressedBackButton:(WMNavigationBar*)navigationBar {
    [self popViewControllerAnimated:YES];
}
-(void)pressedDashboardButton:(WMNavigationBar*)navigationBar {}

-(void)pressedEditButton:(WMNavigationBar*)navigationBar {
    if (![dataManager userIsAuthenticated]) {
        
    }
    
    if ([self.topViewController isKindOfClass:[WMDetailViewController class]]) {
        
        WMEditPOIViewController* vc = [[UIStoryboard storyboardWithName:@"WMDetailView" bundle:nil] instantiateViewControllerWithIdentifier:@"WMEditPOIViewController"];
        vc.node = ((WMDetailViewController *)self.topViewController).node;
        vc.editView = YES;
        vc.title = self.title = NSLocalizedString(@"EditPOIViewHeadline", @"");
        [self pushViewController:vc animated:YES];
    } else {
        NSLog(@"ERROR! Pushing Edit screen from sth different than Detail screen");
    }
}

-(void)pressedCancelButton:(WMNavigationBar*)navigationBar {}
-(void)pressedSaveButton:(WMNavigationBar*)navigationBar {}
-(void)pressedContributeButton:(WMNavigationBar*)navigationBar {}
-(void)pressedSearchCancelButton:(WMNavigationBar *)navigationBar {}
-(void)pressedSearchButton:(BOOL)selected {}

-(void)searchStringIsGiven:(NSString*)query {}

#pragma mark - NavigationController stack

- (void)changeScreenStatusFor:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[WMDetailViewController class]]) {
        self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleNone;
        self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleEditButton;
    } else if ([viewController isKindOfClass:[WMEditPOIViewController class]]) {
        self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
    } else{
        self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
    }

}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self changeScreenStatusFor:viewController];
    
    [super pushViewController:viewController animated:animated];
}

-(UIViewController*)popViewControllerAnimated:(BOOL)animated
{
    UIViewController* lastViewController = [super popViewControllerAnimated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewController;
}

-(NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray* lastViewControllers = [super popToRootViewControllerAnimated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    return lastViewControllers;
}

-(NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    NSArray* lastViewControllers = [super popToViewController:viewController animated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewControllers;
}

-(void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];
    [self changeScreenStatusFor:[viewControllers lastObject]];
}

@end
