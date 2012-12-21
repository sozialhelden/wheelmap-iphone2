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
    
    
    self.dataManager = [[WMDataManager alloc] init];
    self.dataManager.delegate = self;

	// Do any additional setup after loading the view.
    self.currentCategory = self.node.category;
    self.currentNodeType = self.node.node_type;
    self.nameTextField.delegate = self;
    self.infoTextView.delegate = self;
    self.streetTextField.delegate = self;
    self.housenumberTextField.delegate = self;
    self.postcodeTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.websiteTextField.delegate = self;
    self.phoneTextField.delegate = self;
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewStreet", @"");
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewHousenumber", @"");
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewPostcode", @"");
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewCity", @"");
        
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
    
    self.streetTextField.placeholder = NSLocalizedString(@"Street Placeholder", nil);
    self.housenumberTextField.placeholder = NSLocalizedString(@"Housenumber Placeholder", nil);
    self.postcodeTextField.placeholder = NSLocalizedString(@"Postcode Placeholder", nil);
    self.cityTextField.placeholder = NSLocalizedString(@"City Placeholder", nil);
    
    if (self.editView) {
        [self.setMarkerButton setTitle:NSLocalizedString(@"EditPOIViewSetMarkerButtonDisabled", @"") forState:UIControlStateNormal];
        self.setMarkerButton.enabled = NO;
    } else {
        self.node = [self.dataManager createNode];
        [self.setMarkerButton setTitle:NSLocalizedString(@"EditPOIViewSetMarkerButton", @"") forState:UIControlStateNormal];
        [self.setMarkerButton addTarget:self action:@selector(pushToSetMarkerView) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self setWheelAccessButton];
    
    
    [self styleInputView:self.nameInputView];
    [self styleInputView:self.nodeTypeInputView];
    [self styleInputView:self.categoryInputView];
    [self styleInputView:self.positionInputView];
    [self styleInputView:self.infoInputView];
    [self styleInputView:self.addressInputView];
    [self styleInputView:self.websiteInputView];
    [self styleInputView:self.phoneInputView];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, self.phoneInputView.frame.origin.y + self.phoneInputView.frame.size.height + 20)];

    // progress wheel
    progressWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    progressWheel.frame = CGRectMake(0, 0, 50, 50);
    progressWheel.backgroundColor = [UIColor blackColor];
    progressWheel.center = CGPointMake(self.view.center.x, self.view.center.y-40);
    progressWheel.hidden = YES;
    progressWheel.layer.cornerRadius = 5.0;
    progressWheel.layer.masksToBounds = YES;
    [self.view addSubview:progressWheel];
    
}



- (void)viewWillAppear:(BOOL)animated {
    self.title = NSLocalizedString(@"NavBarTitleEdit", nil);
    self.navigationBarTitle = self.title;

    [self updateFields];
    
}


- (void) updateFields {
    self.nameTextField.text = self.node.name;
    [self.setNodeTypeButton setTitle:self.currentNodeType.localized_name forState:UIControlStateNormal];
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
    } else {
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
    [self setWheelAccessButton];
}

- (void)categoryChosen:(Category *)category {
    self.currentCategory = category;
    BOOL nodeTypeStillValid = NO;
    for (NodeType *nt in self.currentCategory.nodeType) {
        if ([nt isEqual:self.currentNodeType]) {
            nodeTypeStillValid = YES;
        }
    }
    if (!nodeTypeStillValid) {
        self.currentNodeType = nil;
        
    }
}

- (void)nodeTypeChosen:(NodeType*)nodeType {
    self.currentNodeType= nodeType;
    [self.setNodeTypeButton setTitle:self.currentNodeType.localized_name forState:UIControlStateNormal];
}

- (void)markerSet:(CLLocationCoordinate2D)coord {
    self.currentCoordinate = coord;
}

- (IBAction)showAccessOptions:(id)sender {
    [self buttonPressed];
    
    WMWheelchairStatusViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMWheelchairStatusViewController"];
    vc.delegate = self;
    vc.node = self.node;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setNodeType:(id)sender {
    [self buttonPressed];
    
    WMNodeTypeTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeTypeTableViewController"];
    vc.delegate = self;
    vc.nodeArray = [[NSSet alloc] initWithSet:self.currentCategory.nodeType];
    vc.title = self.title = NSLocalizedString(@"SetNodeType", @"");

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setCategory:(id)sender {
    [self buttonPressed];
    
    WMCategoryTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMCategoryTableViewController"];
    vc.delegate = self;
    WMDataManager *dataManager = [[WMDataManager alloc] init];
    vc.categoryArray = [[NSArray alloc] initWithArray:dataManager.categories];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) buttonPressed {
    [self.nameTextField resignFirstResponder];
    [self.infoTextView resignFirstResponder];
    [self.streetTextField resignFirstResponder];
    [self.housenumberTextField resignFirstResponder];
    [self.postcodeTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    
}

- (void) pushToSetMarkerView {
    [self.nameTextField resignFirstResponder];
    [self.infoTextView resignFirstResponder];
    [self.streetTextField resignFirstResponder];
    [self.housenumberTextField resignFirstResponder];
    [self.postcodeTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    
    WMSetMarkerViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMSetMarkerViewController"];
    vc.node = self.node;
    vc.delegate = self;
    vc.currentCoordinate = self.currentCoordinate;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)saveCurrentEntriesToCurrentNode {
    
    self.node.name = self.nameTextField.text;
    self.node.category = self.currentCategory;
    self.node.node_type = self.currentNodeType;
    self.node.wheelchair = self.node.wheelchair;
    self.node.wheelchair_description = self.infoTextView.text;
    self.node.street = self.streetTextField.text;
    self.node.housenumber = self.housenumberTextField.text;
    self.node.postcode = self.postcodeTextField.text;
    self.node.city = self.cityTextField.text;
    self.node.website = self.websiteTextField.text;
    self.node.phone = self.phoneTextField.text;
    if (!self.editView) {
        self.node.lat = [NSNumber numberWithDouble:self.currentCoordinate.latitude];
        self.node.lon = [NSNumber numberWithDouble:self.currentCoordinate.longitude];
    }
}

- (void) saveEditedData {
    if (!self.node.lat || !self.node.lon) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PleaseSetMarker", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self saveCurrentEntriesToCurrentNode];
    
    [self.dataManager putNode:self.node];
    
    progressWheel.hidden = NO;
    [progressWheel startAnimating];

}


- (void) dataManager:(WMDataManager *)dataManager didFinishPuttingNodeWithMsg:(NSString *)msg {
    progressWheel.hidden = YES;
    [progressWheel stopAnimating];
    NSLog(@"XXXXXXXX FINISHED %@", msg);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dataManager:(WMDataManager *)dataManager failedPuttingNodeWithError:(NSError *)error {
    NSLog(@"XXXXXXXX Failed %@", error);
    progressWheel.hidden = YES;
    [progressWheel stopAnimating];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"SaveNodeFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
    
    
    
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
    
    if (textField == self.streetTextField) {
        [self.housenumberTextField becomeFirstResponder];
    } else if (textField == self.housenumberTextField) {
        [self.postcodeTextField becomeFirstResponder];

    } else if (textField == self.postcodeTextField) {
        [self.cityTextField becomeFirstResponder];
        
    }
    return YES;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView{
    
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString *)aText {
    
    NSString* newText = [self.infoTextView.text stringByReplacingCharactersInRange:aRange withString:aText];
            
    if([aText isEqualToString:@"\n"]) {
        [aTextView resignFirstResponder];
        return NO;
    }
    
    if([newText length] > 255) {
        return NO; // can't enter more text
    } else {
        return YES;
    }
}


- (void)keyboardWillHide:(NSNotification *)n {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.2];
    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height + 216);
    
    self.keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n {
    
    if (self.keyboardIsShown) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.2];
    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height - 216);
    
    self.keyboardIsShown = YES;
}


@end
