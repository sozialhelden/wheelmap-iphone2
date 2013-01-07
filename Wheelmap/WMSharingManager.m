//
//  WMSharingManager.m
//  Wheelmap
//
//  Created by npng on 12/17/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMSharingManager.h"



@implementation WMSharingManager

-(id)initWithBaseViewController:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        self.baseVC = vc;
    }
    
    return self;
}

#pragma mark - Facebook
-(void)facebookPosting:(NSString*)body
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [self facebookPostingForVersionSixAndAbove:body];
    } else {
        [self facebookPostingForVersionFive:body];
    }
    
}

-(void)facebookPostingForVersionSixAndAbove:(NSString *)body
{
    SLComposeViewController* fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    SLComposeViewControllerCompletionHandler __block completionHandler=
    ^(SLComposeViewControllerResult result){
        
        [fbController dismissViewControllerAnimated:YES completion:nil];
        
        switch(result){
            case SLComposeViewControllerResultCancelled:
            default:
            {
                NSLog(@"Cancelled.....");
                
            }
                break;
            case SLComposeViewControllerResultDone:
            {
                NSLog(@"Posted....");
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:NSLocalizedString(@"FacebookSuccess", nil)
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
    
    [self.baseVC presentModalViewController:fbController animated:YES];
}

-(void)facebookPostingForVersionFive:(NSString *)body {
    
}

#pragma mark - Tweeter
-(void)tweet:(NSString*)body
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [self tweetForVersionSixAndAbove:body];
    } else {
        [self tweetForVersionFive:body];
    }
    
}

-(void)tweetForVersionSixAndAbove:(NSString *)body
{
    SLComposeViewController* fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    SLComposeViewControllerCompletionHandler __block completionHandler=
    ^(SLComposeViewControllerResult result){
        
        [fbController dismissViewControllerAnimated:YES completion:nil];
        
        switch(result){
            case SLComposeViewControllerResultCancelled:
            default:
            {
                NSLog(@"Cancelled.....");
                
            }
                break;
            case SLComposeViewControllerResultDone:
            {
                NSLog(@"Posted....");
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
    
    [self.baseVC presentModalViewController:fbController animated:YES];
    
}

-(void)tweetForVersionFive:(NSString *)body
{
    
}

#pragma mark - Mail
-(void)sendMailWithSubject:(NSString*)subject andBody:(NSString*)body
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:NSLocalizedString(@"MailSubject", nil)];
        [controller setMessageBody:NSLocalizedString(@"MailBody", nil) isHTML:NO];
        
        [self.baseVC presentModalViewController:controller animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    if (result == MFMailComposeResultSent) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"MailSendSuccess", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
    } else if (result == MFMailComposeResultCancelled) {
        NSLog(@"email was canceled");
    }
    else {
        NSLog(@"email was not sent: %@", error.localizedDescription);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"MailSendFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];

        [alert show];
    }
    
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - SMS
-(void)sendSMSwithBody:(NSString *)body
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = body;
        
        controller.messageComposeDelegate = self;
        [self.baseVC presentModalViewController:controller animated:YES];
    } else {
        NSLog(@"SMS service is not available!");
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"SMSSendSuccess", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
    } else if (result == MessageComposeResultCancelled) {
        NSLog(@"SMS was canceled");
    }
    else {
        NSLog(@"SMS was not sent");
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"SMSSendFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        
        [alert show];
    }
    
    [controller dismissModalViewControllerAnimated:YES];

    
}


@end

