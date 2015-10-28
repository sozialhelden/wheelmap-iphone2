//
//  NSString+Distance.h
//  Wheelmap
//
//  Created by Hans Seiffert on 28/10/15.
//  Copyright (c) 2015 Sozialhelden e.V. All rights reserved.
//

@interface NSString (Distance)

/*
	Returns a string in the form of "1.3 km" etc, using miles (mi) or kilometers (km)
	and different decimal separators depending on the user locale.
 */
+ (NSString*)localizedDistanceStringFromMeters:(CGFloat)meters;

@end