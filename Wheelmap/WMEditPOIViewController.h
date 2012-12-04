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

- (IBAction)showAccesOptions:(id)sender;


@end
