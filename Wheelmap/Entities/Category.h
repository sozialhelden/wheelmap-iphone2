//
//  Category.h
//  Wheelmap
//
//  Created by Dorian Roy on 08.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NodeType;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * localized_name;
@property (nonatomic, retain) NSSet *nodeType;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addNodeTypeObject:(NodeType *)value;
- (void)removeNodeTypeObject:(NodeType *)value;
- (void)addNodeType:(NSSet *)values;
- (void)removeNodeType:(NSSet *)values;

@end
