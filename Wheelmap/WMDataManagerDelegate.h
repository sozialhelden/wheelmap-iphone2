//
//  WMDataManagerDelegate.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WMDataManagerDelegate <NSObject>

- (void) receivedNodes:(NSArray*)nodes;

@end
