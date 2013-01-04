//
//  NodeType.h
//  Wheelmap
//
//  Created by Dorian Roy on 29.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Node;

@interface NodeType : NSManagedObject

@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * iconPath;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * localized_name;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *node;
@end

@interface NodeType (CoreDataGeneratedAccessors)

- (void)addNodeObject:(Node *)value;
- (void)removeNodeObject:(Node *)value;
- (void)addNode:(NSSet *)values;
- (void)removeNode:(NSSet *)values;

@end
