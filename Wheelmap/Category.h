//
//  Category.h
//  Wheelmap
//
//  Created by Dorian Roy on 28.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * localized_name;
@property (nonatomic, retain) NSSet *node;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addNodeObject:(Node *)value;
- (void)removeNodeObject:(Node *)value;
- (void)addNode:(NSSet *)values;
- (void)removeNode:(NSSet *)values;

@end
