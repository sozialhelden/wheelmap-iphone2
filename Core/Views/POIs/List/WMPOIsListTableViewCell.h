//
//  WMPOIListCell.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WMPOIsListTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UILabel *nodeTypeLabel;
@property (nonatomic) IBOutlet UILabel *distanceLabel;

@property (nonatomic) IBOutlet UIImageView *iconImage;

@end
