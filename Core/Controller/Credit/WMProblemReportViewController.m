//
//  WMProblemReportViewController.m
//  Wheelmap
//
//  Created by Mauricio Torres Mejia on 15/09/16.
//  Copyright © 2016 Sozialhelden e.V. All rights reserved.
//

#import "WMDataManager.h"
#import "WMProblemReportViewController.h"

@interface WMProblemReportViewController()

@property (weak, nonatomic) IBOutlet WMLabel			*navBarTitle;
@property (weak, nonatomic) IBOutlet WMButton			*closeButton;
@property (weak, nonatomic) IBOutlet UILabel			*titleLabel;
@property (weak, nonatomic) IBOutlet UILabel			*infoLabel;
@property (weak, nonatomic) IBOutlet UITextView			*textArea;
@property (weak, nonatomic) IBOutlet UIButton			*sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomLayoutContraint;
@property (weak, nonatomic) IBOutlet UIScrollView		*scrollView;

@end

@implementation WMProblemReportViewController

#pragma mark: - Lyfe cycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.titleLabel.text = NSLocalizedString(@"problem.report.title", nil);
	self.infoLabel.text = NSLocalizedString(@"problem.report.info", nil);
	[self.sendButton setTitle: NSLocalizedString(@"problem.report.title", nil) forState:UIControlStateNormal];
	[self.closeButton setTitle: NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.textArea
																			action:@selector(resignFirstResponder)]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

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
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	// unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

#pragma mark: - Actions

- (IBAction)cancelReportPressed:(id)sender {
	[self dismissViewControllerAnimated:YES completion: nil];
}

- (IBAction)sendButtonPressed:(id)sender {

	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setMailComposeDelegate:self];
	[mailViewController setSubject:NSLocalizedString(@"problem.report.title", nil)];
	[mailViewController setMessageBody:[self generateMailHTMLString] isHTML:YES];
	[mailViewController setToRecipients:@[K_PROBLEM_REPORT_MAIL]];

	// Present mail view controller on screen
	[self presentViewController:mailViewController animated:YES completion:NULL];
}

#pragma mark: - Helpers

- (NSString *)generateMailHTMLString {

	BOOL gpsActive = (([CLLocationManager locationServicesEnabled] == YES) && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied));
	long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
	NSString *username = (([WMDataManager new].userIsAuthenticated == NO) ? NSLocalizedString(@"problem.report.no", nil) : [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"problem.report.yes", nil), [WMDataManager new].currentUserName]);
	NSString *latLon = (self.lastKnownLocation == nil) ? @"" : [NSString stringWithFormat:@"%f | %f", self.lastKnownLocation.coordinate.latitude, self.lastKnownLocation.coordinate.longitude];
	NSString *freeSpaceString = [NSString stringWithFormat:@"%i MB", (int)(freeSpace / (K_BYTES_PREFFIX_DIVISION * K_BYTES_PREFFIX_DIVISION))];
	NSString *gpsString = ((gpsActive == YES) ? [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"problem.report.yes", nil), latLon] : NSLocalizedString(@"problem.report.no", nil));

	NSString *mailString = K_MAIL_TEMPLATE_TEXT;
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_DESCRIPTION withString: self.textArea.text];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_DATA_TITLE withString: NSLocalizedString(@"problem.report.data.title", nil)];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_APP_VERSION withString: NSLocalizedString(@"problem.report.version.app", nil)];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_APP_VERSION_VALUE withString: [[NSUserDefaults standardUserDefaults] objectForKey:LastRunVersion]];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_USER withString: NSLocalizedString(@"problem.report.user", nil)];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_USER_VALUE withString: username];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_IOS_VERSION withString: NSLocalizedString(@"problem.report.version.ios", nil)];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_IOS_VERSION_VALUE withString: [[UIDevice currentDevice] systemVersion]];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_FREE_SPACE withString: NSLocalizedString(@"problem.report.free.space", nil)];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_FREE_SPACE_VALUE withString: freeSpaceString];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_GPS withString: NSLocalizedString(@"problem.report.gps", nil)];
	mailString = [mailString stringByReplacingOccurrencesOfString:K_MAIL_FIELD_GPS_VALUE withString: gpsString];

	return mailString;
}

#pragma mark: - Keyboard handling

-(void)keyboardWillShow: (NSNotification *)notification
{
	// Get keyboard info
	NSValue *keyboardSizeValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
	float keyboardHeight = [keyboardSizeValue CGRectValue].size.height;
	float scrollOffset = (self.infoLabel.frameY + self.infoLabel.frameHeight);
	self.bottomLayoutContraint.constant = keyboardHeight;
	self.buttonBottomLayoutContraint.constant = (keyboardHeight + K_REPORT_BOTTOM_MARGIN);

	[UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		[self.view layoutIfNeeded];
		[self.scrollView setContentOffset:CGPointMake(0, scrollOffset) animated:YES];
	}];
}

-(void)keyboardWillHide: (NSNotification *)notification {

	self.bottomLayoutContraint.constant = 0;
	self.buttonBottomLayoutContraint.constant = K_REPORT_BOTTOM_MARGIN;
	[UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
		[self.view layoutIfNeeded];
	}];
}

#pragma mark: - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {

	__typeof(self) __weak weakSelf = self;
	[controller dismissViewControllerAnimated:YES completion:^{
		if (result == MFMailComposeResultSent) {
			[weakSelf dismissViewControllerAnimated:YES completion:nil];
		}
	}];
}

@end
