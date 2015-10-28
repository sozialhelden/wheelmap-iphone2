//
//  WMAcceptTermsViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMAcceptTermsViewController.h"
#import "WMTermsViewController.h"
#import "Constants.h"

@interface WMAcceptTermsViewController ()
{
    WMDataManager* _dataManager;
}
@end

@implementation WMAcceptTermsViewController

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
    
    _dataManager = [[WMDataManager alloc] init];
    _dataManager.delegate = self;
    
    self.titleLabel.text = NSLocalizedString(@"TermsTitle", nil);
    self.titleLabel.adjustsFontSizeToFitWidth = YES;

    self.textLabel.text = NSLocalizedString(@"TermsText", nil);
     
    self.linkTextView.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"AcceptUserTerms", nil), WheelMapTermsURL];
    self.link2TextView.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"AcceptDataTerms", nil), WheelMapDataTermsURL];
    
    CGSize maximumLabelSize = CGSizeMake(self.textLabel.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [self.textLabel.text boundingRectWithSize:maximumLabelSize
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:self.textLabel.font}
                                                                 context:nil].size;
    
    //adjust the label the the new height.
    CGRect newFrame = self.textLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.textLabel.frame = newFrame;
    
    self.linkTextView.frame = CGRectMake(self.linkTextView.frame.origin.x, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 10.0f, self.linkTextView.frame.size.width, self.linkTextView.contentSize.height);
    
    self.link2TextView.frame = CGRectMake(self.link2TextView.frame.origin.x, self.linkTextView.frame.origin.y + self.linkTextView.frame.size.height + 10.0f, self.link2TextView.frame.size.width, self.link2TextView.contentSize.height);
    
    self.interceptButton.frame = self.linkTextView.frame;
    self.intercept2Button.frame = self.link2TextView.frame;
        
    self.acceptButton.frame = CGRectMake(self.acceptButton.frame.origin.x, self.link2TextView.frame.origin.y + self.link2TextView.frame.size.height + 30.0f, self.acceptButton.frame.size.width, self.acceptButton.frame.size.height);
    
    self.declineButton.frame = CGRectMake(self.declineButton.frame.origin.x, self.link2TextView.frame.origin.y + self.link2TextView.frame.size.height + 30.0f, self.declineButton.frame.size.width, self.declineButton.frame.size.height);
    
    self.checkBoxTermsButton.frame = CGRectMake(self.checkBoxTermsButton.frame.origin.x, self.linkTextView.frame.origin.y + 10.0f, self.checkBoxTermsButton.frame.size.width, self.checkBoxTermsButton.frame.size.height);

    
    self.checkBoxDataButton.frame = CGRectMake(self.checkBoxDataButton.frame.origin.x, self.link2TextView.frame.origin.y + 10.0f, self.checkBoxDataButton.frame.size.width, self.checkBoxDataButton.frame.size.height);

    
    [self.acceptButton setTitle:NSLocalizedString(@"TermsAcceptButton", nil) forState:UIControlStateNormal];
    
    [self.declineButton setTitle:NSLocalizedString(@"TermsDeniedButton", nil) forState:UIControlStateNormal];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.acceptButton.frame.origin.y + self.acceptButton.frame.size.height + 20.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressedAcceptButton:(id)sender {
    
    if (!self.checkBoxTermsButton.selected || !self.checkBoxDataButton.selected) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"PleaseAcceptAllTerms", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    
    [_dataManager updateTermsAccepted:YES];
    self.loadingWheel.hidden = NO;
}

- (void) dataManagerDidUpdateTermsAccepted:(WMDataManager*)dataManager withValue:(BOOL)accepted
{
    self.loadingWheel.hidden = YES;
    if (accepted) {
        [_dataManager userDidAcceptTerms];
        [self dismissViewControllerAnimated:YES];
    } else {
        [_dataManager userDidNotAcceptTerms];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"TermsDeniedText", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [alert show];
        [self dismissViewControllerAnimated:YES];
    }
}

-(void)dataManager:(WMDataManager *)dataManager updateTermsAcceptedFailedWithError:(NSError *)error
{
    self.loadingWheel.hidden = YES;
    NSLog(@"TermsAccepted Could Not Updated: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"TermsCouldNotUpdate", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];

    [alert show];
    
    [_dataManager removeUserAuthentication];
    
    [self dismissViewControllerAnimated:YES];
}

-(IBAction)pressedDeclineButton:(id)sender {
    
    [_dataManager updateTermsAccepted:NO];
    self.loadingWheel.hidden = NO;
}

-(IBAction)pressedInterceptButton:(id)sender {
    WMTermsViewController *termsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WMTermsVC"];
    
    if (sender == self.interceptButton) {
        [termsViewController showDataTerms:NO];
    } else {
        [termsViewController showDataTerms:YES];
    }
    
    [self presentViewController:termsViewController animated:YES];
}

-(IBAction)pressedCheckboxButton:(UIButton *)sender {
    sender.selected = !sender.selected;
}

@end
