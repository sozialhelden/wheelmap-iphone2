//
//  WMViewController.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"
#import "WMInfinitePhotoViewController.h"
#import "WMTermsViewController.h"
#import "WMAcceptTermsViewController.h"
#import "WMShareSocialViewController.h"

@interface WMViewController ()

@end

@implementation WMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if (UIDevice.currentDevice.isIPad == NO) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    } else {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

	// Set the preferred content size to make sure the popover controller has the right size.
	self.preferredContentSize = CGSizeMake(K_POPOVER_VIEW_WIDTH, K_POPOVER_VIEW_HEIGHT);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UIDevice.currentDevice.isIPad == NO) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    } else {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    }
}


- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.navigationBarTitle = title;
}

-(NSString*)title
{
    return [super title];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (BOOL)shouldAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)presentForcedModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [super presentViewController:modalViewController animated:animated completion:nil];
}

- (void)presentViewController:(UIViewController *)modalViewController animated:(BOOL)animated{
    if (UIDevice.currentDevice.isIPad == YES) {
        
        UINavigationController *navigationController;
        if ([modalViewController isKindOfClass:[UINavigationController class]]) {
            navigationController = (UINavigationController*) modalViewController;
            modalViewController = modalViewController.childViewControllers[0];
        }

        
       if ([modalViewController isKindOfClass:[WMShareSocialViewController class]]) {
            
            if ((self.baseController != nil) && (self.baseController.view != nil)) {
                ((WMViewController *)modalViewController).popover = [[WMPopoverController alloc] initWithContentViewController:modalViewController];
                ((WMViewController *)modalViewController).baseController = self.baseController;
                
                if ((((WMViewController *)modalViewController).popoverButtonFrame.size.width == 0) || (((WMViewController *)modalViewController).popoverButtonFrame.size.height == 0)) {
                    ((WMViewController *)modalViewController).popoverButtonFrame = CGRectMake(((WMViewController *)modalViewController).popoverButtonFrame.origin.x, ((WMViewController *)modalViewController).popoverButtonFrame.origin.y, 10.0f, 10.0f);
                }
                
                [((WMViewController *)modalViewController).popover presentPopoverFromRect:((WMViewController *)modalViewController).popoverButtonFrame inView:self.baseController.view permittedArrowDirections:0 animated:animated];
            }
            
        } else if (![modalViewController isKindOfClass:[WMTermsViewController class]]) {
            
            [self dismissViewControllerAnimated:NO];
            if ((self.baseController != nil) && (self.baseController.view != nil)) {
				WMViewController *wmViewController = (WMViewController *)modalViewController;
                wmViewController.popover = [[WMPopoverController alloc] initWithContentViewController:modalViewController];
                wmViewController.baseController = self.baseController;

				UIPopoverArrowDirection popoverDirection = UIPopoverArrowDirectionAny;
                if ((wmViewController.popoverButtonFrame.size.width == 0) || (wmViewController.popoverButtonFrame.size.height == 0)) {
					// Show the popover controller in the middle of the screen if no rect is set.
                    wmViewController.popoverButtonFrame = CGRectMake(UIScreen.mainScreen.bounds.size.width/2, UIScreen.mainScreen.bounds.size.height/2, 1.0f, 1.0f);
					// Use now arrows
					popoverDirection = 0;
                }
                
                [wmViewController.popover presentPopoverFromRect:wmViewController.popoverButtonFrame inView:self.baseController.view permittedArrowDirections:popoverDirection animated:animated];
            }
        } else {
            if ((self.baseController != nil) && (self.baseController.view != nil)) {
                ((WMViewController *)modalViewController).popover = [[WMPopoverController alloc] initWithContentViewController:modalViewController];
                ((WMViewController *)modalViewController).baseController = self.baseController;
                
                if ((((WMViewController *)modalViewController).popoverButtonFrame.size.width == 0) || (((WMViewController *)modalViewController).popoverButtonFrame.size.height == 0)) {
                    ((WMViewController *)modalViewController).popoverButtonFrame = CGRectMake(((WMViewController *)modalViewController).popoverButtonFrame.origin.x, ((WMViewController *)modalViewController).popoverButtonFrame.origin.y, 10.0f, 10.0f);
                }
                
                [((WMViewController *)modalViewController).popover presentPopoverFromRect:((WMViewController *)modalViewController).popoverButtonFrame inView:self.baseController.view permittedArrowDirections:0 animated:animated];
            }
        }
    } else {
        [super presentViewController:modalViewController animated:animated completion:nil];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)animated{
    if (UIDevice.currentDevice.isIPad == YES && ![self isKindOfClass:[WMInfinitePhotoViewController class]]) {
        [self.popover dismissPopoverAnimated:animated];
    } else {
        [super dismissViewControllerAnimated:animated completion:nil];
    }
}

@end
