//
//  Node.h
//  Wheelmap
//
//  Created by Dorian Roy on 08.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NodeType, Photo;

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
@property (nonatomic, retain) NodeType *node_type;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Node (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
