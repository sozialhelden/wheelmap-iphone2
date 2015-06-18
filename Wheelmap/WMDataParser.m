//
//  WMDataParser.m
//  Wheelmap
//
//  Created by Dorian Roy on 03.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMDataParser.h"
#import <CoreData/CoreData.h>

#define WMLogDataParser 1

@implementation WMDataParser

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super init];
    if (self) {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}


#pragma mark - Parse Foundation Objects To Core Data Objects

- (id) parseDataObject:(id)object entityName:(NSString*)entityName error:(NSError**)error
{
    NSParameterAssert(object);
    NSParameterAssert(entityName);
    
//    if (WMLogDataParser) NSLog(@"parsing %@ %@", entityName, dispatch_get_current_queue() == dispatch_get_main_queue() ? @"on main queue" : @"on background queue");
    
    id parsedObject = nil;
    
    if ([object isKindOfClass:[NSArray class]]) {
        
        NSArray *resultObjectsItems = [NSArray array];
        
        // create managed objects for all items in array
        for (NSDictionary *item in (NSArray*)object) {
            
            NSManagedObject *newObject = [self createOrUpdateManagedObjectWithEntityName:entityName objectData:item];
            if (newObject) {
                
                resultObjectsItems = [resultObjectsItems arrayByAddingObject:newObject];
                
            } else {
                
                if (error != NULL) *error = [NSError errorWithDomain:WMDataParserErrorDomain code:WMDataParserManagedObjectCreationError userInfo:nil];
                
                // roll back already created objects
                for (NSManagedObject *alreadyCreatedObject in resultObjectsItems) {
                    [self.managedObjectContext deleteObject:alreadyCreatedObject];
                }
                // skip rest of array
                break;
            }
        }
        
        parsedObject = resultObjectsItems;
        
    } else {
        
        // create a single managed object
        parsedObject = [self createOrUpdateManagedObjectWithEntityName:entityName objectData:object];
        if (!parsedObject) {
            if (error != NULL) *error = [NSError errorWithDomain:WMDataParserErrorDomain code:WMDataParserManagedObjectCreationError userInfo:nil];
        }
    }
    
    return parsedObject;
}

/**
 *  Returns a Managed Object for the entity configured with the attributes of the dictionary.
 *  If an object with the same id already exists in the managed object context, this
 *  object will be updated with the dictionary and returned
 */

- (NSManagedObject*) createOrUpdateManagedObjectWithEntityName:(NSString*)entityName objectData:(NSDictionary*)data
{
    NSParameterAssert(data != nil);
    
    NSManagedObject *object = nil;
    
    // check if there is an entity with this name
    NSDictionary *entityDescriptionsByName = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel entitiesByName];
    NSEntityDescription *descr = entityDescriptionsByName[entityName];
    
    if (!descr) {
        if (WMLogDataParser>1) NSLog(@"... no entity description for %@", entityName);
        
    } else {
        
        BOOL objectExisted = NO;
        
        // if entity has an id
        if ([descr attributesByName][@"id"]) {
            
            NSNumber *object_id = data[@"id"];
                        
            if (!object_id || ![object_id isKindOfClass:[NSNumber class]]) {
                if (WMLogDataParser>1) NSLog(@"... received object with invalid id");
                return nil;
            }
            
            // check if an object with this id already exists
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id==%@", object_id]];
            NSError *error = nil;
            NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                        
            object = [results lastObject];
            objectExisted = (object != nil);
        }
        
        // if there is no object to update, create new object for entity name
        if (!objectExisted) {
            if (WMLogDataParser>1) NSLog(@"... creating %@", entityName);
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
            
        } else {
            if (WMLogDataParser>1) NSLog(@"... updating %@", entityName);
        }
        
        // copy all attributes to the object
        __block BOOL conversionSuccess = YES;
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            conversionSuccess = [self managedObject:object convertAndSetValue:obj forKey:key];
            
            // abort if an attribute cannot be converted
            if (!conversionSuccess) {
                if (WMLogDataParser>1) NSLog(@"... property conversion failed for key %@", key);
                *stop = YES;
            }
        }];
        
        // check if converted object is valid
        NSError *error = nil;
        if (!conversionSuccess || ![object validateForUpdate:&error]) {
            
            if (objectExisted) {
                
                // this is the case where an existing object got into an invalid state through the update
                // TODO: use undo manager to roll back all changes since the update/sync started
                NSAssert(YES, @"Error: %@:%@ was invalidated through remote data", descr.name, [object valueForKey:@"id"]);
                
            } else {
                
                // delete new object again
                // this should also delete all newly created related objects through cascading delete policies
                [self.managedObjectContext deleteObject:object];
                
                // log error details
                [self logValidationError:error];
            }
            
            return nil;
        }
    }
    
    return object;
}



/**
 This method converts integer, float, bool, date and string values to
 the expected attribute type of a managed objects property. Other attribute
 types will be ignored.
 Relationships will be set by recursively creating the related objects.
 */
- (BOOL) managedObject:(NSManagedObject*)managedObject convertAndSetValue:(id)value forKey:(NSString*)key
{
    if (WMLogDataParser>2) NSLog(@"...... setting value %@ for key %@", value, key);
    
    if (value == [NSNull null]) {
        value = nil;
    }
    // get property description by name
    NSPropertyDescription *descr = [[managedObject.entity propertiesByName] valueForKey:key];
    
    // if property is an attribute
    if ([descr isKindOfClass:[NSAttributeDescription class]]) {
        
        // convert value to the right type and assign it to the attribute
        NSAttributeType type = ((NSAttributeDescription*)descr).attributeType;
        switch (type) {
                
            case NSStringAttributeType:
                [managedObject setValue:value forKey:key];
                break;
                
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
                [managedObject setValue:@([value longLongValue]) forKey:key];
                break;
                
            case NSDoubleAttributeType:
                [managedObject setValue:@([value doubleValue]) forKey:key];
                break;
                
            case NSFloatAttributeType:
                [managedObject setValue:@([value floatValue]) forKey:key];
                break;
                
            case NSBooleanAttributeType:
                [managedObject setValue:@([value boolValue]) forKey:key];
                break;
                
            case NSDateAttributeType:
                [managedObject setValue:[NSDate dateWithTimeIntervalSince1970:[value integerValue]] forKey:key];
                break;
                
            case NSTransformableAttributeType:
                [managedObject setValue:value forKey:key];
                break;
                
            default:
                if (WMLogDataParser>2) NSLog(@"...... Unexpected attribute type %lu in entity %@", type, managedObject.entity.name);
                return NO;
        }
        
        // if property is a relationship
    } else if ([descr isKindOfClass:[NSRelationshipDescription class]]) {
        
        NSRelationshipDescription *relationship = (NSRelationshipDescription*)descr;
        
        // get the destination entity
        NSEntityDescription *destinationEntity = [relationship destinationEntity];
        
        // if it is a to-many relationship
        if ([relationship isToMany]) {
            
            NSAssert([value isKindOfClass:[NSArray class]], @"Expected array as value of to-many-relationship");
            NSArray *array = (NSArray*) value;
            
            // create temp set
            id newSet = relationship.isOrdered ? [NSMutableOrderedSet orderedSetWithCapacity:[array count]] : [NSMutableSet setWithCapacity:[array count]];
            
            // create or fetch each referenced object
            for (id item in (NSArray*)value) {
                
                NSManagedObject *itemManagedObject = [self createOrUpdateManagedObjectWithEntityName:destinationEntity.name objectData:(NSDictionary *)item];
                if (!itemManagedObject) {
                    return NO;
                }
                
                // add object to set
                [newSet addObject:itemManagedObject];
            }
            
            // keep old set temporarily
            id oldSet = [managedObject valueForKey:key];
            
            // set new set as value of property
            [managedObject setValue:newSet forKey:key];
            
            // remove orphaned objects from managed object context
            [(NSSet*)oldSet enumerateObjectsUsingBlock:^(NSManagedObject *obj, BOOL *stop) {
                
                // if the inverse relationship is nil
                if ([obj valueForKey:relationship.inverseRelationship.name] == nil) {
                    
                    // delete object
                    [self.managedObjectContext deleteObject:obj];
                }
            }];
            
            // if it is a to-one relationship
        } else {
            
            // create or fetch the single referenced object and assign it
            NSManagedObject *referencedObject = [self createOrUpdateManagedObjectWithEntityName:destinationEntity.name objectData:(NSDictionary *)value];
            if (!referencedObject) {
                return NO;
            }
            
            [managedObject setValue:referencedObject forKey:relationship.name];
        }
        
    } else {
        // the property is not part of the local data model and will be ignored
        if (WMLogDataParser>2) NSLog(@"...... ignored property %@ on entity %@", key, managedObject.entity.name);
    }
    
    return YES;
}

- (void) logValidationError:(NSError*)error
{
    NSString *validationErrorKey = error.userInfo[NSValidationKeyErrorKey];
    if (!validationErrorKey) {
        NSArray *multipleErrors = error.userInfo[NSDetailedErrorsKey];
        NSArray *multipleKeys = @[];
        for (NSError *singleError in multipleErrors) {
            multipleKeys = [multipleKeys arrayByAddingObject:singleError.userInfo[NSValidationKeyErrorKey]];
        }
        validationErrorKey = [multipleKeys componentsJoinedByString:@", "];
    }
    NSString *entityName;
    NSString *object_id;
    if (WMLogDataParser) NSLog(@"Error: %@.%@ couldn't be validated. Validation error keys: %@", entityName, object_id, validationErrorKey);
}


@end



NSString *WMDataParserErrorDomain = @"WMDataParserErrorDomain";

