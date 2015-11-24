//
//  WMEditPOIStateButtonView.h
//  Wheelmap
//
//  Created by SMF on 02.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPOIStateButtonView.h"

@interface WMEditPOIStateButtonView : WMPOIStateButtonView

@property (nonatomic, weak) id<WMEditPOIStateButtonViewDelegate>		editStateDelegate;

#pragma mark - Public Setter

- (void)setSelected:(BOOL)selected;

@end
