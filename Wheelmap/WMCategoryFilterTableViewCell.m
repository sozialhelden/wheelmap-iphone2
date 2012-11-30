//
//  WMCategoryFilterTableViewCell.m
//  Wheelmap
//
//  Created by npng on 11/29/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCategoryFilterTableViewCell.h"

@implementation WMCategoryFilterTableViewCell
@synthesize title = _title;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        titleLabel = [[WMLabel alloc] initWithFrame:CGRectMake(5, 0, 100, CELL_HEIGHT)];
        titleLabel.fontSize = 15.0;
        titleLabel.textAlignment = UITextAlignmentLeft;
        [self addSubview:titleLabel];
        
        checkIcon = [[UIImageView alloc] initWithFrame:CGRectMake(105, 0, 25, CELL_HEIGHT)];
        checkIcon.image = [UIImage imageNamed:@"toolbar_category-check.png"];
        checkIcon.contentMode = UIViewContentModeCenter;
        checkIcon.hidden = YES;
        [self addSubview:checkIcon];
        
        self.isSelected = NO;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.isSelected = !self.isSelected;
        if (self.isSelected) {
            checkIcon.hidden = NO;
        } else {
            checkIcon.hidden = YES;
        }
    }
}


#pragma mark - Set Title
-(void)setTitle:(NSString *)title
{
    _title = title;
    titleLabel.text = title;
}
-(NSString*)title
{
    return _title;
}

@end
