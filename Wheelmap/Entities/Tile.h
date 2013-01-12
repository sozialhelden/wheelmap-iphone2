//
//  Tile.h
//  Wheelmap
//
//  Created by Dorian Roy on 11.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface Tile : NSManagedObject

@property (nonatomic, retain) NSNumber * swLat;
@property (nonatomic, retain) NSNumber * swLon;
@property (nonatomic, retain) NSSet *nodes;
@end

@interface Tile (CoreDataGeneratedAccessors)

- (void)addNodesObject:(Node *)value;
- (void)removeNodesObject:(Node *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

@end
