//
//  WMCreditsViewController.m
//  Wheelmap
//
//  Created by Taehun Kim on 1/7/13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMCreditsViewController.h"
#import "Constants.h"

@implementation WMCreditsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationBar setBackgroundColor:NAVBAR_BACKGROUND_COLOR];
    self.scroller.backgroundColor = [UIColor wmGreyColor];
    
    self.titleLabel.text = NSLocalizedString(@"Credits", nil);
    [self.doneButton setTitle:NSLocalizedString(@"Ready", nil) forState:UIControlStateNormal];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(85, 20, 150, 30)];
    logo.image = [UIImage imageNamed:@"navigationbar_logo.png"];
    [self.scroller addSubview:logo];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logo.frame)+4, CGRectGetWidth(self.scroller.frame), 22)];
    version.textColor = [UIColor darkGrayColor];
    version.font = [UIFont systemFontOfSize:14];
    version.textAlignment = NSTextAlignmentCenter;
    [self.scroller addSubview:version];
    
    version.text = [NSString stringWithFormat:@"iOS App Version: %@ (Build %@)",
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    UIImageView *bmas = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(version.frame)+20, 300, 220)];
    bmas.image = [UIImage imageNamed:@"credits_bmas.png"];
    [self.scroller addSubview:bmas];
    
    UIImageView *verein = [[UIImageView alloc] initWithFrame:CGRectMake(10, bmas.leftBottomY+10, 300, 148)];
    verein.image = [UIImage imageNamed:@"credits_verein.png"];
    [self.scroller addSubview:verein];
    
    UIImageView *authors = [[UIImageView alloc] initWithFrame:CGRectMake(10, verein.leftBottomY+10, 301, 90)];
    authors.image = [UIImage imageNamed:@"credits_authors.png"];
    [self.scroller addSubview:authors];
    
    UILabel *creditsTitleLabel = [[WMLabel alloc] initWithFrame:CGRectMake(10, authors.leftBottomY+20, 300, 18)];
    creditsTitleLabel.textAlignment = NSTextAlignmentCenter;
    creditsTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    creditsTitleLabel.text = @"Credits:";
    [self.scroller addSubview:creditsTitleLabel];
    
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    CGSize size = CGSizeMake(320, 16);
    NSString *titleCardData = @"Kartendaten:";
    CGSize stringsize = [titleCardData boundingRectWithSize:size
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:font}
                                                    context:nil].size;
    
    UILabel *cardDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, creditsTitleLabel.leftBottomY+10, stringsize.width, stringsize.height)];
    [cardDataLabel setBackgroundColor:[UIColor clearColor]];
    cardDataLabel.textAlignment = NSTextAlignmentLeft;
    cardDataLabel.font = font;
    cardDataLabel.text = titleCardData;
    [self.scroller addSubview:cardDataLabel];
    
    UIButton *cardDataButtonOSM = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *titleOSM = @"OpenStreetMap";
    stringsize = [titleOSM boundingRectWithSize:size
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:font}
                                        context:nil].size;
    cardDataButtonOSM.frame = CGRectMake(cardDataLabel.frame.origin.x + cardDataLabel.frame.size.width + 5.0f, cardDataLabel.frame.origin.y, stringsize.width, stringsize.height);
    [cardDataButtonOSM setBackgroundColor:[UIColor clearColor]];
    cardDataButtonOSM.titleLabel.textColor = [UIColor blueColor];
    cardDataButtonOSM.titleLabel.font = font;
    [cardDataButtonOSM setTitle:titleOSM forState:UIControlStateNormal];
    [cardDataButtonOSM setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cardDataButtonOSM addTarget:self action:@selector(osmButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.scroller addSubview:cardDataButtonOSM];
    
    UIButton *cardDataButtonODBL = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *titleODBL = @"(ODbL)";
    stringsize = [titleODBL boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil].size;
    cardDataButtonODBL.frame = CGRectMake(cardDataButtonOSM.frame.origin.x + cardDataButtonOSM.frame.size.width + 5.0f, cardDataLabel.frame.origin.y, stringsize.width, stringsize.height);
    [cardDataButtonODBL setBackgroundColor:[UIColor clearColor]];
    [cardDataButtonODBL setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    cardDataButtonODBL.titleLabel.font = font;
    [cardDataButtonODBL setTitle:titleODBL forState:UIControlStateNormal];
    [cardDataButtonODBL addTarget:self action:@selector(odblButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.scroller addSubview:cardDataButtonODBL];
    
    UIImageView *license = [[UIImageView alloc] initWithFrame:CGRectMake(20, cardDataLabel.leftBottomY+10, 61, 18)];
    license.image = [UIImage imageNamed:@"credits_license.png"];
    license.contentMode = UIViewContentModeBottomRight;
    [self.scroller addSubview:license];
    
    UILabel *licenseLabel = [[WMLabel alloc] initWithFrame:CGRectMake(license.frame.origin.x + license.frame.size.width + 10.0f, license.frame.origin.y, 210, 18)];
    licenseLabel.textAlignment = NSTextAlignmentLeft;
    licenseLabel.font = [UIFont systemFontOfSize:12.0f];
    licenseLabel.text = @"Map Icons Collection: Nicolas Mollet";
    [self.scroller addSubview:licenseLabel];
    
    UIImageView *license2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, license.leftBottomY+10, 61, 18)];
    license2.image = [UIImage imageNamed:@"credits_license.png"];
    license2.contentMode = UIViewContentModeBottomRight;
    [self.scroller addSubview:license2];
    
    UILabel *licenseLabel2 = [[WMLabel alloc] initWithFrame:CGRectMake(license2.frame.origin.x + license2.frame.size.width + 10.0f, license2.frame.origin.y, 210, 18)];
    licenseLabel2.textAlignment = NSTextAlignmentLeft;
    licenseLabel2.font = [UIFont systemFontOfSize:12.0f];
    licenseLabel2.text = @"Entypo pictograms by Daniel Bruce";
    [self.scroller addSubview:licenseLabel2];
    
    self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width, license2.leftBottomY+20);
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(donePressed:)];
    [self.view addGestureRecognizer:tapGR];
}

- (void)osmButtonPressed {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:OSM_URL]];
}

- (void)odblButtonPressed {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ODBL_URL]];
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES];
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320.0f, 600.0f);
}

@end