//
//  WMWheelChairStatusFilterPopoverView.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMWheelChairStatusFilterPopoverView;

@protocol WMWheelChairStatusFilterPopoverViewDelegate <NSObject>

@required
-(void)pressedButtonOfDotType:(DotType)type selected:(BOOL)selected;
@end

@interface WMWheelChairStatusFilterPopoverView : UIView
{
    WMButton* buttonGreen;
    WMButton* buttonYellow;
    WMButton* buttonRed;
    WMButton* buttonNone;
}

@property (nonatomic, strong) id<WMWheelChairStatusFilterPopoverViewDelegate> delegate;
- (id)initWithOrigin:(CGPoint)origin;
- (void)updateFilterButtons;
@end
