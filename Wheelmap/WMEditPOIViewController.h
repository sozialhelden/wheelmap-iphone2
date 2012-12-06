//
//  WMEditPOIViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface WMEditPOIViewController : WMViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *nameInputView;
@property (weak, nonatomic) IBOutlet UIView *categoryInputView;
@property (weak, nonatomic) IBOutlet UIView *positionInputView;
@property (weak, nonatomic) IBOutlet UIView *infoInputView;
@property (weak, nonatomic) IBOutlet UIView *addressInputView;
@property (weak, nonatomic) IBOutlet UIView *websiteInputView;
@property (weak, nonatomic) IBOutlet UIView *phoneInputView;
@property (nonatomic, strong) UIImage *accessImage;
@property (nonatomic, strong) NSString *wheelchairAccess;
@property (nonatomic) Node *node;

@property (weak, nonatomic) IBOutlet UIButton *wheelAccessButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *housenumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *postcodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;

@property (weak, nonatomic) IBOutlet UIButton *setMarkerButton;

@property (strong) id delegate;

- (IBAction)showAccessOptions:(id)sender;
- (void) saveEditedData;

@end
