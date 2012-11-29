//
//  Photo.h
//  Wheelmap
//
//  Created by Dorian Roy on 28.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, Node;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * taken_on;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Node *node;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
