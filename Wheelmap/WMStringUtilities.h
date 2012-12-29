//
//  WMStringUtilities.h
//  Wheelmap
//
//  Created by Dorian Roy on 29.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMStringUtilities : NSObject


/*
 Returns a string in the form of "1.3 km" etc, using miles (mi) or kilometers (km)
 and different decimal separators depending on the user locale.
 */
+ (NSString*) localizedDistanceFromMeters:(CGFloat)meters;

@end
