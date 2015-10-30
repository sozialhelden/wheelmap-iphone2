//
//  WMPOIIPadNavigationController.m
//  Wheelmap
//
//  Created by Michael Thomas on 23.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMPOIIPadNavigationController.h"
#import "WMPOIViewController.h"
#import "WMEditPOIViewController.h"
#import "WMPOIWheelchairStatusViewController.h"
#import "WMEditPOICommentViewController.h"
#import "WMIPadRootViewController.h"
#import "WMNodeListViewController.h"
#import "WMAcceptTermsViewController.h"

@interface WMPOIIPadNavigationController ()

@end

@implementation WMPOIIPadNavigationController {
    WMDataManager *dataManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        dataManager = [[WMDataManager alloc] init];
        
        // set custom nagivation and tool bars
        self.navigationBar.frame = CGRectMake(0, self.navigationBar.frame.origin.y, self.view.frame.size.width, K_NAVIGATION_BAR_HEIGHT);
        
        self.customNavigationBar = [[WMNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, K_NAVIGATION_BAR_HEIGHT)];
        [self.customNavigationBar adjustButtonsToPopoverPresentation];
        self.customNavigationBar.delegate = self;
        if ([self.customNavigationBar isKindOfClass:[WMNavigationBar_iPad class]]) {
            ((WMNavigationBar_iPad *)self.customNavigationBar).searchBarEnabled = NO;
        }
        [self.navigationBar addSubview:self.customNavigationBar];
    }
    return self;
}

- (void)mapWasMoved:(CLLocationCoordinate2D)coordinate {
    self.initialCoordinate = coordinate;
}

-(void)pressedBackButton:(WMNavigationBar*)navigationBar {
    [self popViewControllerAnimated:YES];
}

- (void)pressedDashboardButton:(WMNavigationBar*)navigationBar {}

- (void)pressedEditButton:(WMNavigationBar*)navigationBar {
	// Check if the user is logged in.
    if (dataManager.userIsAuthenticated == NO) {
		[self showLoginViewController];
		return;
	}

	if ([self.topViewController isKindOfClass:[WMPOIViewController class]] == YES) {
		WMEditPOIViewController* editPOIViewController = [UIStoryboard instantiatedEditPOIViewController];
		editPOIViewController.node = ((WMPOIViewController *)self.topViewController).node;
		editPOIViewController.initialCoordinate = self.initialCoordinate;
		editPOIViewController.editView = YES;
		editPOIViewController.title = editPOIViewController.navigationBarTitle = self.title = NSLocalizedString(@"EditPOIViewHeadline", @"");
		[self pushViewController:editPOIViewController animated:YES];
	}else {
		NSLog(@"ERROR! Pushing Edit screen from sth. different than Detail screen");
	}
}

- (void)pressedCancelButton:(WMNavigationBar*)navigationBar {
    [self popViewControllerAnimated:YES];
}

- (void)pressedSaveButton:(WMNavigationBar*)navigationBar {
    WMViewController* currentViewController = [self.viewControllers lastObject];
    if ([currentViewController isKindOfClass:[WMPOIWheelchairStatusViewController class]]) {
        [(WMPOIWheelchairStatusViewController*)currentViewController saveAccessStatus];
    }
    if ([currentViewController isKindOfClass:[WMEditPOIViewController class]]) {
        [(WMEditPOIViewController*)currentViewController saveEditedData];
    }
    if ([currentViewController isKindOfClass:[WMEditPOICommentViewController class]]) {
        [(WMEditPOICommentViewController*)currentViewController saveEditedData];
    }
}

- (void)pressedContributeButton:(WMNavigationBar*)navigationBar {}

- (void)pressedSearchCancelButton:(WMNavigationBar *)navigationBar {}

- (void)pressedSearchButton:(BOOL)selected {}

- (void)searchStringIsGiven:(NSString*)query {}

#pragma mark - NavigationController stack

- (void)changeScreenStatusFor:(UIViewController *)viewController {
        
    if ([viewController isKindOfClass:[WMPOIViewController class]]) {
        self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleNone;
        self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleEditButton;
    } else if ([viewController isKindOfClass:[WMEditPOIViewController class]]) {
        if (((WMEditPOIViewController *)viewController).isRootViewController) {
            self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleNone;
        } else {
            self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        }
        self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
    } else if ([viewController isKindOfClass:[WMEditPOICommentViewController class]]) {
        self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
    } else if ([viewController isKindOfClass:[WMPOIWheelchairStatusViewController class]]) {
        self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        if ( ((WMPOIWheelchairStatusViewController *)viewController).hideSaveButton ) {
            self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
        } else {
            self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
        }
    } else {
        self.customNavigationBar.leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        self.customNavigationBar.rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
    }

    if ([viewController respondsToSelector:@selector(navigationBarTitle)]) {
        self.customNavigationBar.title = [viewController performSelector:@selector(navigationBarTitle)];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self changeScreenStatusFor:viewController];
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    UIViewController* lastViewController = [super popViewControllerAnimated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewController;
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray* lastViewControllers = [super popToRootViewControllerAnimated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    return lastViewControllers;
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray* lastViewControllers = [super popToViewController:viewController animated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    [self changeScreenStatusFor:[viewControllers lastObject]];
}

- (void) showLoadingWheel {
    [self.listViewController.controllerBase showLoadingWheel];
}

- (void)hideLoadingWheel {
    [self.listViewController.controllerBase hideLoadingWheel];
}

- (void)showLoginViewController {
	if ([self.listViewController.navigationController isKindOfClass:[WMNavigationControllerBase class]] == YES) {
		// The user isn't logged in. Present the login screen then. This will close the popover and open the login screen popover.
		[((WMNavigationControllerBase *)self.listViewController.navigationController) presentLoginScreen];
	}
}

@end
