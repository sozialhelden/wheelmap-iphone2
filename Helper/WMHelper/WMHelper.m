//
//  WMHelper.m
//  Wheelmap
//
//  Created by Hans Seiffert on 20.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import "WMHelper.h"

@implementation WMHelper

+ (BOOL)shouldShowIntroViewController {
	return ([NSUserDefaults.standardUserDefaults boolForKey:K_UD_INTRO_ALREADY_SEEN] == NO);
}

@end
