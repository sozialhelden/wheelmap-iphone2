//
//  WMProblemReportViewController.h
//  Wheelmap
//
//  Created by Mauricio Torres Mejia on 15/09/16.
//  Copyright © 2016 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface WMProblemReportViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) CLLocation 				*lastKnownLocation;

@property (weak, nonatomic) IBOutlet WMLabel 			*navBarTitle;
@property (weak, nonatomic) IBOutlet WMButton			*closeButton;
@property (weak, nonatomic) IBOutlet UILabel 			*titleLabel;
@property (weak, nonatomic) IBOutlet UILabel 			*infoLabel;
@property (weak, nonatomic) IBOutlet UITextView 		*textArea;
@property (weak, nonatomic) IBOutlet UIButton 			*sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutContraint;
@property (weak, nonatomic) IBOutlet UIScrollView 		*scrollView;

@end
