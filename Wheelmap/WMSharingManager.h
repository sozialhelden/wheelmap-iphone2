//
//  WMSharingManager.h
//  Wheelmap
//
//  Created by npng on 12/17/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "Facebook+Singleton.h"
#import <Twitter/Twitter.h>

@interface WMSharingManager : NSObject
<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate>

@property (nonatomic, strong) UIViewController* baseVC;
-(id)initWithBaseViewController:(UIViewController*)vc;

-(void)facebookPosting:(NSString*)body;
-(void)tweet:(NSString*)body;
-(void)sendMailWithSubject:(NSString*)subject andBody:(NSString*)body;
-(void)sendSMSwithBody:(NSString*)body;

@end
