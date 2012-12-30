//
//  WMWheelchairStatusViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "WMDataManager.h"
typedef enum {
    kWMWheelChairStatusViewControllerUseCasePutWheelChairStatus,
    kWMWheelChairStatusViewControllerUseCasePutNode
} WMWheelChairStatusViewControllerUseCase;

@interface WMWheelchairStatusViewController : WMViewController <WMDataManagerDelegate>
{
    WMDataManager* dataManager;
    
    UIActivityIndicatorView* progressWheel;
}
@property (nonatomic, strong) Node *node;

@property (strong, nonatomic) UIScrollView *scrollView;
@property WMWheelChairStatusViewControllerUseCase useCase;
@property (weak, nonatomic) IBOutlet WMButton *yesButton;
@property (weak, nonatomic) IBOutlet WMButton *limitedButton;
@property (weak, nonatomic) IBOutlet WMButton *noButton;

@property (nonatomic, strong) UIImageView *yesCheckMarkImageView;
@property (nonatomic, strong) UIImageView *limitedCheckMarkImageView;
@property (nonatomic, strong) UIImageView *noCheckMarkImageView;

//@property (weak, nonatomic) IBOutlet UIButton *yesButton;
//@property (weak, nonatomic) IBOutlet UIButton *limitedButton;
//@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (strong, nonatomic) id delegate;
@property (nonatomic, strong) NSString *wheelchairAccess;


- (IBAction)accessButtonPressed:(id)sender;
- (void) saveAccessStatus;

@end
