//
//  WMOSMDescriptionViewController.h
//  Wheelmap
//
//  Created by Dirk Tech on 04/30/15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

@interface WMOSMDescriptionViewController : WMViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *		scrollView;

@property (nonatomic, weak) IBOutlet UILabel *			whyOSMLabel;
@property (nonatomic, weak) IBOutlet UITextView	*		whyOSMTextView;

@property (nonatomic, weak) IBOutlet UIButton *			okButton;

@end
