//
//  WMDashboardButton.m
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDashboardButton.h"

@implementation WMDashboardButton

- (id)initWithFrame:(CGRect)frame andType:(WMDashboardButtonType)type
{
    self = [super initWithFrame:frame];
    if (self) {
                
        CGRect bounds = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        
        UIView *normalView = [[UIView alloc] initWithFrame:bounds];
        
        UIImageView *backgroundImageViewNormal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start_btn-grid.png"]];
        backgroundImageViewNormal.frame = bounds;
        [normalView addSubview:backgroundImageViewNormal];
        
        NSString *buttonImageStringNormal = @"";
        
        NSString *titleString = @"";
        
        switch (type) {
            case WMDashboardButtonTypeNearby:
                buttonImageStringNormal = @"DashboardLocalIcon";
                titleString = NSLocalizedString(@"DashboardNearby", nil);
                break;
            case WMDashboardButtonTypeMap:
                buttonImageStringNormal = @"DashboardMapIcon";
                titleString = NSLocalizedString(@"DashboardMap", nil);
                break;
            case WMDashboardButtonTypeCategories:
                buttonImageStringNormal = @"DashboardCategoryIcon";
                titleString = NSLocalizedString(@"DashboardCategories", nil);
                break;
            case WMDashboardButtonTypeHelp:
                buttonImageStringNormal = @"DashboardHelpIcon";
                titleString = NSLocalizedString(@"DashboardHelp", nil);
                break;
            default:
                break;
        }
        
        UIImage *imageNormal = [UIImage imageNamed:buttonImageStringNormal];
        UIImageView *imageViewNormal = [[UIImageView alloc] initWithImage:imageNormal];
        imageViewNormal.frame = CGRectMake( (frame.size.width - imageNormal.size.width)/2, (frame.size.height - imageNormal.size.height)/2 - 10.0f, imageNormal.size.width, imageNormal.size.height);
        [normalView addSubview:imageViewNormal];
        
        WMLabel *titleLabelNormal = [[WMLabel alloc] initWithFrame:CGRectMake(10.0f, bounds.size.height - 35.0f, bounds.size.width - 20.0f, 30.0f)];
        titleLabelNormal.textColor = [UIColor colorWithRed:39.0f/255.0f green:54.0f/255.0f blue:69.0f/255.0f alpha:1.0f];
        titleLabelNormal.text = titleString;
        titleLabelNormal.fontSize = 12.0f;
        titleLabelNormal.fontType = kWMLabelFontTypeBold;
        [normalView addSubview:titleLabelNormal];
                                     
        [self setView:normalView forControlState:UIControlStateNormal];
    }
    return self;
}

@end
