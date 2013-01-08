//
//  WMEditPOIViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WMDataManagerDelegate.h"

@class Node, Category, NodeType;

@interface WMEditPOIViewController : WMViewController <UITextFieldDelegate, UITextViewDelegate, WMDataManagerDelegate>
{
    UIActivityIndicatorView* progressWheel;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) WMDataManager *dataManager;

//NAME
@property (weak, nonatomic) IBOutlet UIView *nameInputView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
//TYPE
@property (weak, nonatomic) IBOutlet UIView *nodeTypeInputView;
@property (weak, nonatomic) IBOutlet UILabel *nodeTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *setNodeTypeButton;
//CATEGORY
@property (weak, nonatomic) IBOutlet UIView *categoryInputView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *setCategoryButton;
//SETMARKER
@property (weak, nonatomic) IBOutlet UIView *positionInputView;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UIButton *setMarkerButton;
@property (assign) BOOL editView;
//WHEELACCESSBUTTON
@property (weak, nonatomic) IBOutlet UIButton *wheelAccessButton;
//INFO
@property (weak, nonatomic) IBOutlet UIView *infoInputView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
//ADDRESS
@property (weak, nonatomic) IBOutlet UIView *addressInputView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *housenumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *postcodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
//WEBSITE
@property (weak, nonatomic) IBOutlet UIView *websiteInputView;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
//PHONE
@property (weak, nonatomic) IBOutlet UIView *phoneInputView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
//VARIOUS
@property (nonatomic) Node *node;
@property (nonatomic, assign) BOOL keyboardIsShown;
@property (nonatomic, strong) UIImage *accessImage;
@property (nonatomic, strong) NSString *wheelchairAccess;
@property (nonatomic, strong) Category *currentCategory;
@property (nonatomic, strong) NodeType *currentNodeType;
@property (nonatomic, strong) NSString *currentWheelchairStatus;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;


- (IBAction)setNodeType:(id)sender;
- (IBAction)setCategory:(id)sender;
- (IBAction)showAccessOptions:(id)sender;
- (void)categoryChosen:(Category*)category;
- (void)nodeTypeChosen:(NodeType*)nodeType;
- (void)markerSet:(CLLocationCoordinate2D)coord;
- (void) saveEditedData;

@end
