//
//  WMStringUtilities.m
//  Wheelmap
//
//  Created by Dorian Roy on 29.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMStringUtilities.h"

@implementation WMStringUtilities


+ (NSString*) localizedDistanceFromMeters:(CGFloat)meters
{
    // for larger distances, use miles or kilometres
    if (meters >= 1000.0) {
        
        BOOL useMetricSystem = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
        
        // reuse formatter instance
        static NSNumberFormatter *formatter;
        if (!formatter) {
            formatter = [[NSNumberFormatter alloc] init];
            formatter.roundingMode = NSNumberFormatterRoundUp;
            formatter.usesGroupingSeparator = YES;
            formatter.groupingSize = 3;
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            // use grouping and decimal separators according to locale
            formatter.groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
            formatter.decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
        }
        
        CGFloat distance = useMetricSystem ? meters / 1000.0 : meters / 1609.344; // 1 Mile = 1609.344 Meters
        
        // don't use decimal digits for numbers greater than 10
        formatter.maximumFractionDigits = distance > 10.0 ? 0 : 1;
        
        NSString *distanceUnit = useMetricSystem ? @"km" : @"mi";
        NSString *distanceString = [formatter stringFromNumber:[NSNumber numberWithFloat:distance]];
        return [NSString stringWithFormat: @"%@ %@", distanceString, distanceUnit];
    }
    
    // for smaller distances, always use meters
    return [NSString stringWithFormat: @"%@ m", [NSString stringWithFormat: @"%.0f", meters]];
}

@end
