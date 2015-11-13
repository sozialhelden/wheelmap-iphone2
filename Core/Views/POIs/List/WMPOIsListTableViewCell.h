//
//  WMPOIListCell.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface WMPOIsListTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet MarqueeLabel *	titleLabel;
@property (nonatomic) IBOutlet MarqueeLabel *	nodeTypeLabel;
@property (nonatomic) IBOutlet UILabel *		distanceLabel;

@property (nonatomic) IBOutlet UIImageView *	markerImageView;
@property (nonatomic) IBOutlet UIImageView *	iconImageView;

@end
