//
//  Node.h
//  Wheelmap
//
//  Created by Dorian Roy on 27.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Node : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * housenumber;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * wheelchair;
@property (nonatomic, retain) NSString * wheelchair_description;
@property (nonatomic, retain) NSManagedObject *category;
@property (nonatomic, retain) NSManagedObject *node_type;

@end
