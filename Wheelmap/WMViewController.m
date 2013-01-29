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
#import "WMMapSettingsViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
	// Do any additional setup after loading the view.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    } else {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    }


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    } else {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.titleView = [[UIView alloc] init];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.navigationBarTitle = title;
}

-(NSString*)title
{
    return [super title];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"Popover %f", self.popoverButtonFrame.origin.y);
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"Popover %f", self.popoverButtonFrame.origin.y);
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(BOOL)shouldAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320.0f, 550.0f);
}

- (void)presentForcedModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [super presentModalViewController:modalViewController animated:animated];
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if ([modalViewController isKindOfClass:[WMMapSettingsViewController class]]) {
            
            [super presentModalViewController:modalViewController animated:animated];
            
        } else if (![modalViewController isKindOfClass:[WMTermsViewController class]]) {
            
            [self dismissModalViewControllerAnimated:NO];
            if ((self.baseController != nil) && (self.baseController.view != nil)) {
                ((WMViewController *)modalViewController).popover = [[UIPopoverController alloc] initWithContentViewController:modalViewController];
                ((WMViewController *)modalViewController).baseController = self.baseController;
                
                if ((((WMViewController *)modalViewController).popoverButtonFrame.size.width == 0) || (((WMViewController *)modalViewController).popoverButtonFrame.size.height == 0)) {
                    ((WMViewController *)modalViewController).popoverButtonFrame = CGRectMake(((WMViewController *)modalViewController).popoverButtonFrame.origin.x, ((WMViewController *)modalViewController).popoverButtonFrame.origin.y, 10.0f, 10.0f);
                }
                
                [((WMViewController *)modalViewController).popover presentPopoverFromRect:((WMViewController *)modalViewController).popoverButtonFrame inView:self.baseController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:animated];
            }
        } else {
            if ((self.baseController != nil) && (self.baseController.view != nil)) {
                ((WMViewController *)modalViewController).popover = [[UIPopoverController alloc] initWithContentViewController:modalViewController];
                ((WMViewController *)modalViewController).baseController = self.baseController;
                
                if ((((WMViewController *)modalViewController).popoverButtonFrame.size.width == 0) || (((WMViewController *)modalViewController).popoverButtonFrame.size.height == 0)) {
                    ((WMViewController *)modalViewController).popoverButtonFrame = CGRectMake(((WMViewController *)modalViewController).popoverButtonFrame.origin.x, ((WMViewController *)modalViewController).popoverButtonFrame.origin.y, 10.0f, 10.0f);
                }
                
                [((WMViewController *)modalViewController).popover presentPopoverFromRect:((WMViewController *)modalViewController).popoverButtonFrame inView:self.baseController.view permittedArrowDirections:0 animated:animated];
            }
        }
    } else {
        [super presentModalViewController:modalViewController animated:animated];
    }
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![self isKindOfClass:[WMInfinitePhotoViewController class]]) {
        [self.popover dismissPopoverAnimated:animated];
    } else {
        [super dismissModalViewControllerAnimated:animated];
    }
}

@end
