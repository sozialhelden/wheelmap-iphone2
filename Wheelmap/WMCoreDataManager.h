//
//  WMCoreDataManager.h
//  Wheelmap
//
//  Created by Dorian Roy on 27.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface WMCoreDataManager : NSObject

+ (NSManagedObjectContext*) managedObjectContext;

@end
