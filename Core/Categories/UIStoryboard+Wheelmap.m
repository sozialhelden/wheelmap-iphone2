//
//  UIStoryboard+Wheelmap.m
//  Breeze
//
//  Created by H. Seiffert on 27.10.15.
//  Copyright (c) 2015 Smart Mobile Factory GmbH. All rights reserved.
//

#import "UIStoryboard+Wheelmap.h"

@implementation UIStoryboard (Wheelmap)

+ (UIStoryboard*)mainStoryboard {
	if (UIDevice.isIPad) {
		return [UIStoryboard mainIPadStoryboard];
	} else {
		return [UIStoryboard mainIPhoneStoryboard];
	}
}

+ (UIStoryboard*)mainIPhoneStoryboard {
	return [UIStoryboard storyboardWithName:@"Main-iPhone" bundle:nil];
}

+ (UIStoryboard*)mainIPadStoryboard {
	return [UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil];
}

+ (UIStoryboard*)poiStoryboard {
	return [UIStoryboard storyboardWithName:@"POI" bundle:nil];
}

#pragma mark - Instantiations

+ (id)instantiatedEditPOIViewController {
	return [UIStoryboard.poiStoryboard instantiateViewControllerWithIdentifier:@"WMEditPOIViewController"];
}

+ (id)instantiatedRegisterViewController {
	return [UIStoryboard.mainIPhoneStoryboard instantiateViewControllerWithIdentifier:@"WMRegisterVC"];
}

+ (id)instantiatedDetailViewController {
	return [UIStoryboard.poiStoryboard instantiateInitialViewController];
}

+ (id)instantiatedAcceptTermsViewController {
	return [UIStoryboard.mainIPhoneStoryboard instantiateViewControllerWithIdentifier:@"AcceptTermsVC"];
}

+ (id)instantiatedOSMStartViewController {
	return [UIStoryboard.mainIPhoneStoryboard instantiateViewControllerWithIdentifier:@"WMOSMStartViewController"];
}

+ (id)instantiatedLogoutViewController {
	return [UIStoryboard.mainIPhoneStoryboard instantiateViewControllerWithIdentifier:@"WMLogoutViewController"];
}

+ (id)instantiatedCreditsViewController {
	return [UIStoryboard.mainIPhoneStoryboard instantiateViewControllerWithIdentifier:@"WMCreditsViewController"];
}

+ (id)instantiatedDescribeViewController {
	return [UIStoryboard.mainIPhoneStoryboard instantiateViewControllerWithIdentifier:@"WMOSMDescribeViewController"];
}

+ (id)instantiatedOSMLoginViewController {
	return [UIStoryboard.mainIPhoneStoryboard instantiateViewControllerWithIdentifier:@"WMOSMLoginVC"];
}

@end
