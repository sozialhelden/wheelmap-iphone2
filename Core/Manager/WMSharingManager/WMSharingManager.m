//
//  WMSharingManager.m
//  Wheelmap
//
//  Created by npng on 12/17/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMSharingManager.h"

@implementation WMSharingManager

- (id)initWithBaseViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.baseVC = viewController;
    }
    
    return self;
}

#pragma mark - Facebook

- (void)facebookPosting:(NSString *)body {
    SLComposeViewController* fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [fbController setCompletionHandler:nil];
    
    [fbController addURL:[NSURL URLWithString:body]];

    [self.baseVC presentViewController:fbController animated:YES completion:nil];
}

#pragma mark - Tweeter

- (void)tweet:(NSString *)body {
    SLComposeViewController* fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    SLComposeViewControllerCompletionHandler __block completionHandler=
    ^(SLComposeViewControllerResult result){
        
        [fbController dismissViewControllerAnimated:YES completion:nil];
        
        switch(result){
            case SLComposeViewControllerResultCancelled:
            default:
            {
            }
                break;
            case SLComposeViewControllerResultDone:
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:NSLocalizedString(@"TweetSuccess", nil)
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                       otherButtonTitles: nil];
                [alert show];
            }
                break;
        }};
    [fbController setCompletionHandler:completionHandler];
    
    [fbController setInitialText:body];
    //[fbController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://jam.solutions.smfhq.com/staging/events/%@", eventToBeSent.objectID]]];
    
    [self.baseVC presentViewController:fbController animated:YES completion:nil];
    
}

#pragma mark - Mail

- (void)sendMailWithSubject:(NSString*)subject andBody:(NSString*)body {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:subject];
        [controller setMessageBody:body isHTML:NO];
        
        [self.baseVC presentViewController:controller animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    if (result == MFMailComposeResultSent) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"MailSendSuccess", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"MailSendFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];

        [alert show];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SMS

- (void)sendSMSwithBody:(NSString *)body {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = body;
        
        controller.messageComposeDelegate = self;
        [self.baseVC presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"SMSSendSuccess", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
	} else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"SMSSendFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        
        [alert show];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end

