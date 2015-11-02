//
//  WMEditPOIStatusButtonView.h
//  Wheelmap
//
//  Created by SMF on 02.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMEditPOIStatusButtonView : UIView

@property (nonatomic, weak) id<WMEditPOIStatusButtonViewDelegate>		delegate;

@property (nonatomic) WMEditPOIStatusType								statusType;

- (instancetype)initFromNibToView:(UIView *)view;

#pragma mark - Public Setter

- (void)setCurrentStatus:(NSString *)statusString;
- (void)setSelected:(BOOL)selected;

@end
