//
//  UIStoryboard+Wheelmap.h
//  Breeze
//
//  Created by H. Seiffert on 27.10.15.
//  Copyright (c) 2015 Smart Mobile Factory GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (Wheelmap)

+ (UIStoryboard*)mainStoryboard;
+ (UIStoryboard*)mainIPhoneStoryboard;
+ (UIStoryboard*)mainIPadStoryboard;
+ (UIStoryboard*)poiStoryboard;
+ (UIStoryboard*)introStoryboard;

#pragma mark - Instantiations

+ (id)instantiatedPOIsListViewController;

+ (id)instantiatedEditPOIViewController;

+ (id)instantiatedRegisterViewController;

+ (id)instantiatedDetailViewController;

+ (id)instantiatedAcceptTermsViewController;

+ (id)instantiatedOSMOnboardingViewController;

+ (id)instantiatedOSMLogoutViewController;

+ (id)instantiatedCreditsViewController;

+ (id)instantiatedDescriptionViewController;

+ (id)instantiatedOSMLoginViewController;

+ (id)instantiatedIntroViewController;

@end
