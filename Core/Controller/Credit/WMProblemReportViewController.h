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

@end
