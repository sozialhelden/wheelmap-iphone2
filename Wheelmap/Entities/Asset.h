//
//  Asset.h
//  Wheelmap
//
//  Created by Dorian Roy on 29.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Asset : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * modified_at;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;

@end
