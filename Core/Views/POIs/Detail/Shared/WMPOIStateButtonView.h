//
//  WMPOIStateButtonView.h
//  Wheelmap
//
//  Created by Hans Seiffert on 03.11.15.
//
//

#import <UIKit/UIKit.h>

@interface WMPOIStateButtonView : UIView

@property (nonatomic) id<WMPOIStateButtonViewDelegate>		showStateDelegate;

@property (weak, nonatomic) IBOutlet UIButton *				button;
@property (weak, nonatomic) IBOutlet WMLabel *				titleLabel;

@property (strong, nonatomic) NSString *					statusString;

@property (nonatomic) WMEditPOIStatusType					statusType;

- (instancetype)initFromNibToView:(UIView *)view;

#pragma mark - Mehtods for the subclasses

- (void)initConstraints;
- (void)initDefaultValues;
- (void)updateViewContent;

@end
