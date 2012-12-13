//
//  WMEditPOIViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WMEditPOIViewController.h"
#import "WMWheelchairStatusViewController.h"
#import "WMDetailViewController.h"
#import "WMSetMarkerViewController.h"
#import "NodeType.h"
#import "WMCategoryTableViewController.h"
#import "WMNodeTypeTableViewController.h"
#import "WMDataManagerDelegate.h"
#import "Category.h"

@interface WMEditPOIViewController ()

@end

@implementation WMEditPOIViewController

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
	// Do any additional setup after loading the view.
    self.currentCategory = self.node.category;
    self.nameTextField.delegate = self;
    self.infoTextView.delegate = self;
    self.streetTextField.delegate = self;
    self.housenumberTextField.delegate = self;
    self.postcodeTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.websiteTextField.delegate = self;
    self.phoneTextField.delegate = self;
    

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
        
    // WHEEL ACCESS
    [self setWheelAccessButton];
    self.wheelAccessButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.wheelAccessButton.titleLabel.textColor = [UIColor whiteColor];
    [self.wheelAccessButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.wheelAccessButton setContentEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];

    self.nameLabel.text = NSLocalizedString(@"EditPOIViewNameLabel", @"");
    self.nodeTypeLabel.text = NSLocalizedString(@"EditPOIViewNodeTypeLabel", @"");
    self.categoryLabel.text = NSLocalizedString(@"EditPOIViewCategoryLabel", @"");
    self.infoLabel.text = NSLocalizedString(@"EditPOIViewInfoLabel", @"");
    self.addressLabel.text = NSLocalizedString(@"EditPOIViewAddressLabel", @"");
    self.websiteLabel.text = NSLocalizedString(@"EditPOIViewWebsiteLabel", @"");
    self.phoneLabel.text = NSLocalizedString(@"EditPOIViewPhoneLabel", @"");
    [self.setMarkerButton setTitle:NSLocalizedString(@"EditPOIViewSetMarkerButton", @"") forState:UIControlStateNormal];
    [self.setMarkerButton addTarget:self action:@selector(pushToSetMarkerView) forControlEvents:UIControlEventTouchUpInside];
    
  
    
    [self styleInputView:self.nameInputView];
    [self styleInputView:self.nodeTypeInputView];
    [self styleInputView:self.categoryInputView];
    [self styleInputView:self.positionInputView];
    [self styleInputView:self.infoInputView];
    [self styleInputView:self.addressInputView];
    [self styleInputView:self.websiteInputView];
    [self styleInputView:self.phoneInputView];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, self.phoneInputView.frame.origin.y + self.phoneInputView.frame.size.height + 20)];

    
}



- (void)viewWillAppear:(BOOL)animated {
    [self updateFields];
}


- (void) updateFields {
    self.nameTextField.text = self.node.name;
    [self.setNodeTypeButton setTitle:self.node.node_type.localized_name forState:UIControlStateNormal];
    [self.setCategoryButton setTitle:self.currentCategory.localized_name forState:UIControlStateNormal];
    [self setWheelAccessButton];
    self.infoTextView.text = self.node.wheelchair_description;
    self.streetTextField.text = self.node.street;
    self.housenumberTextField.text = self.node.housenumber;
    self.postcodeTextField.text = self.node.postcode;
    self.cityTextField.text = self.node.city;
    self.websiteTextField.text = self.node.website;
    self.phoneTextField.text = self.node.phone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    
    [self setSetCategoryButton:nil];
    [self setNodeTypeInputView:nil];
    [self setNodeTypeLabel:nil];
    [self setSetNodeTypeButton:nil];
    [super viewDidUnload];
    [self setScrollView:nil];
    [self setNameInputView:nil];
    [self setCategoryInputView:nil];
    [self setPositionInputView:nil];
    [self setInfoInputView:nil];
    [self setAddressInputView:nil];
    [self setAddressInputView:nil];
    [self setWebsiteInputView:nil];
    [self setWebsiteInputView:nil];
    [self setPhoneInputView:nil];
    [self setWheelAccessButton:nil];
    [self setNameTextField:nil];
    [self setWebsiteTextField:nil];
    [self setPhoneTextField:nil];
    [self setNameLabel:nil];
    [self setCategoryLabel:nil];
    [self setPosition:nil];
    [self setInfoLabel:nil];
    [self setWebsiteLabel:nil];
    [self setPhoneLabel:nil];
    [self setAddressLabel:nil];
    [self setStreetTextField:nil];
    [self setHousenumberTextField:nil];
    [self setPostcodeTextField:nil];
    [self setCityTextField:nil];
    [self setSetMarkerButton:nil];
    [self setInfoTextView:nil];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void)setWheelAccessButton {
    
    
    if ([self.node.wheelchair isEqualToString:@"yes"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-yes.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessYes", @"");
    } else if ([self.node.wheelchair isEqualToString:@"no"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-no.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessNo", @"");
    } else if ([self.node.wheelchair isEqualToString:@"limited"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-limited.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessLimited", @"");
    } else if ([self.node.wheelchair isEqualToString:@"unknown"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-unknown.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessUnknown", @"");
    }
    
    [self.wheelAccessButton setBackgroundImage: self.accessImage forState: UIControlStateNormal];
    [self.wheelAccessButton setTitle:self.wheelchairAccess forState:UIControlStateNormal];
    
}

- (void) styleInputView: (UIView*) inputView {
    [inputView.layer setCornerRadius:5.0f];
    [inputView.layer setMasksToBounds:YES];
    inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    inputView.layer.borderWidth = 1.0f;
    
}


- (void)accessButtonPressed:(NSString*)wheelchairAccess {
      self.node.wheelchair = wheelchairAccess;
}

- (void)categoryChosen:(Category *)category {
    self.currentCategory = category;
}

- (void)nodeTypeChosen:(NodeType*)nodeType {
    self.node.node_type = nodeType;
}

- (IBAction)showAccessOptions:(id)sender {
    WMWheelchairStatusViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMWheelchairStatusViewController"];
    vc.delegate = self;
    vc.node = self.node;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setNodeType:(id)sender {
    WMNodeTypeTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeTypeTableViewController"];
    vc.delegate = self;
    WMDataManager *dataManager = [[WMDataManager alloc] init];
    vc.nodeArray = [[NSArray alloc] initWithArray:dataManager.nodeTypes];
    vc.title = self.title = NSLocalizedString(@"SetNodeType", @"");
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setCategory:(id)sender {
    WMCategoryTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMCategoryTableViewController"];
    vc.delegate = self;
    WMDataManager *dataManager = [[WMDataManager alloc] init];
    vc.categoryArray = [[NSArray alloc] initWithArray:dataManager.categories];
     vc.title = self.title = NSLocalizedString(@"SetCategory", @"");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) pushToSetMarkerView {
    WMSetMarkerViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMSetMarkerViewController"];
    vc.node = self.node;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) saveEditedData {
    
    self.node.name = self.nameTextField.text;
    self.node.category = self.currentCategory;
    self.node.wheelchair = self.node.wheelchair;
    self.node.wheelchair_description = self.infoTextView.text;
    self.node.street = self.streetTextField.text;
    self.node.housenumber = self.housenumberTextField.text;
    self.node.postcode = self.postcodeTextField.text;
    self.node.city = self.cityTextField.text;
    self.node.website = self.websiteTextField.text;
    self.node.phone = self.phoneTextField.text;
    
    WMDataManager *dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    [dataManager putNode:self.node];

}


- (void) dataManager:(WMDataManager *)dataManager didFinishPuttingNodeWithMsg:(NSString *)msg {
 //   progressWheel.hidden = YES;
 //   [progressWheel stopAnimating];
    NSLog(@"XXXXXXXX FINISHED %@", msg);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dataManager:(WMDataManager *)dataManager didFailPuttingNodeWithMsg:(NSString *)msg {
    NSLog(@"XXXXXXXX FINISHED %@", msg);
    //   progressWheel.hidden = YES;
    //   [progressWheel stopAnimating];
    
}

- (void)dealloc {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}


- (void)keyboardWillHide:(NSNotification *)n {
    
   // resize the scrollview
    CGRect viewFrame = self.view.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
  //  viewFrame.origin.y += 50.0f;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.2];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    self.keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n {
    
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (self.keyboardIsShown) {
        return;
    }
    
    // resize the noteView
    CGRect viewFrame = self.view.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
 //   viewFrame.origin.y -= 50.0f;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.2];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    self.keyboardIsShown = YES;
}


@end
