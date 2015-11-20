//
//  WMIntroViewController.m
//  Wheelmap
//
//  Created by Hans Seiffert on 17.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import "WMIntroViewController.h"

@interface WMIntroViewController ()

#define K_LAST_PAGE_INDEX	4

@property (weak, nonatomic) IBOutlet UIScrollView *			scrollView;

@property (weak, nonatomic) IBOutlet WMLabel *				firstPageTitleLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				firstPageDescriptionLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				searchPageTitleLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				searchPageDescriptionLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				markPOIPageTitleLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				markPOIPageDescriptionLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				editPOIPageTitleLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				editPOIPageDescriptionLabel;
@property (weak, nonatomic) IBOutlet WMLabel *				lastPageTitleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *			lastPageDescriptionWebView;

@property (weak, nonatomic) IBOutlet UIButton *				button;
@property (weak, nonatomic) IBOutlet UIPageControl *		pageControl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewContentWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	firstPageWidthConstraint;

@end

@implementation WMIntroViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	[UIApplication.sharedApplication setStatusBarHidden:YES];

	[self initPageControl];
	[self initTexts];
	[self initLastPageDescriptionWebview];

	if (UIDevice.isIPad == YES) {
		self.scrollViewContentWidthConstraint.constant = K_POPOVER_VIEW_WIDTH * self.pageControl.numberOfPages;
		self.preferredContentSize = CGSizeMake(K_POPOVER_VIEW_WIDTH, K_POPOVER_VIEW_HEIGHT);
	} else {
		self.scrollViewContentWidthConstraint.constant = self.view.frameWidth * self.pageControl.numberOfPages;
		self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.view.frameHeight);
	}

	// Adjust the width of the first page. The other pages will use the same width as constraint
	self.firstPageWidthConstraint.constant = self.scrollViewContentWidthConstraint.constant / self.pageControl.numberOfPages;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[UIApplication.sharedApplication setStatusBarHidden:NO];
}

#pragma mark - Initialization

- (void)initPageControl {
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = K_LAST_PAGE_INDEX + 1;
}

- (void)initTexts {
	self.firstPageTitleLabel.text = L(@"intro.start.title");
	self.firstPageDescriptionLabel.text = L(@"intro.start.description");
	self.searchPageTitleLabel.text = L(@"intro.search.title");
	self.searchPageDescriptionLabel.text = L(@"intro.start.description");
	self.markPOIPageTitleLabel.text = L(@"intro.state.title");
	self.markPOIPageDescriptionLabel.text = L(@"intro.state.description");
	self.editPOIPageTitleLabel.text = L(@"intro.edit.title");
	self.editPOIPageDescriptionLabel.text = L(@"intro.edit.description");
	self.lastPageTitleLabel.text = L(@"intro.last.title");
	[self.button setTitle:L(@"intro.button.next") forState:UIControlStateNormal];
}

- (void)initLastPageDescriptionWebview {
	// Init the web view which is used to display the agreement message.
	[self.lastPageDescriptionWebView loadHTMLString:self.lastPageDescriptionLabelHTML baseURL:[NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath]];
}

#pragma mark - IBActions

- (IBAction)didPressButton:(id)sender {
	if (self.pageControl.currentPage == K_LAST_PAGE_INDEX) {
		if (self.popoverController != nil) {
			[self.popoverController dismissPopoverAnimated:YES];
		} else {
			[self dismissViewControllerAnimated:YES];
		}
	} else {
		self.pageControl.currentPage = self.pageControl.currentPage + 1;
		[self.scrollView scrollRectToVisible:[self rectOfPage:self.pageControl.currentPage] animated:YES];
		if (self.pageControl.currentPage == K_LAST_PAGE_INDEX) {
			[self.button setTitle:L(@"intro.button.done") forState:UIControlStateNormal];
		}
	}
}

#pragma Helper

- (NSString *)lastPageDescriptionLabelHTML {

	NSString *agreement = nil;
	NSString *htmlPath = [NSBundle.mainBundle pathForResource:@"IntroLastPageDescription" ofType:@"html"];
	if (htmlPath != nil) {
		NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
		agreement = [NSString stringWithFormat:html, L(@"intro.last.description")];
	}
	return agreement;
}

- (CGRect)rectOfPage:(NSUInteger)pageIndex {
	return CGRectMake(pageIndex * self.firstPageWidthConstraint.constant, 0, self.firstPageWidthConstraint.constant, self.view.frameHeight);
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	BOOL shouldLoad = true;

	// Check if the requested site is local (it has a fileURL than) or a site in the www. If it's local we let the web view open it. If not, we open the URL in the system browser.
	if (request.URL.fileURL == false) {
		[UIApplication.sharedApplication openURL:request.URL];
		shouldLoad = false;
	}

	return shouldLoad;
}

@end
