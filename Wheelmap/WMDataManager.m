//
//  WMDataManager.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "WMDataManager.h"
#import "WMWheelmapAPI.h"

#define WMSearchRadius 0.004

@interface WMDataManager()
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@end

@implementation WMDataManager
{
    WMWheelmapAPI *api;
    NSManagedObjectContext *_managedObjectContext;
}

- (id) init
{
    self = [super init];
    if (self) {
        api = [[WMWheelmapAPI alloc] init];
        [self syncResources];
    }
    return self;
}


#pragma mark - Fetch Nodes

- (void) fetchNodesNear:(CLLocationCoordinate2D)location
{
    // get rect of area within search radius around current location
    // this rect won"t have the same proportions as the map area on screen
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake(location.latitude - WMSearchRadius, location.longitude - WMSearchRadius);
    CLLocationCoordinate2D northeast = CLLocationCoordinate2DMake(location.latitude + WMSearchRadius, location.longitude + WMSearchRadius);
    
    [self fetchNodesBetweenSouthwest:southwest northeast:northeast];
}

- (void) fetchNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest northeast:(CLLocationCoordinate2D)northeast
{
    NSString *coords = [NSString stringWithFormat:@"%f,%f,%f,%f",
                         southwest.longitude,
                         southwest.latitude,
                         northeast.longitude,
                         northeast.latitude];
    [self fetchNodesWithParameters:@{@"bbox":coords}];
}

- (void) fetchNodesWithParameters:(NSDictionary*)parameters;
{
    [api requestResource:@"nodes"
              parameters:parameters
                    eTag:nil
                    data:nil
                  method:nil
                   error:^(NSError *error) {
                       [self.delegate dataManager:self fetchNodesFailedWithError:error];
                   }
                 success:^(NSDictionary *data, NSString* eTag) {
                     [self didReceiveNodes:data[@"nodes"]];
                 }
     ];
}

- (void) didReceiveNodes:(NSArray *)nodes
{
    // parse result and add it to managed object context
    NSError *error = nil;
    NSArray *parsedNodes = [self parseDataObject:nodes entityName:@"Node" error:&error];
    
    if (error) {
        if (self.delegate) {
            [self.delegate dataManager:self fetchNodesFailedWithError:error];
        }
    } else {
        [self.delegate dataManager:self didReceiveNodes:parsedNodes];
    }
}


#pragma mark - Sync Resources

- (void) syncResources
{
    // TODO: fetch data and cache it
    [self.delegate dataManagerDidFinishSyncingResources:self];
}


#pragma mark - Expose Data

- (NSArray *)categories
{
    return [self fetchObjectsOfEntity:@"Category" withPredicate:nil];
}

- (NSArray *)types
{
    return [self fetchObjectsOfEntity:@"NodeType" withPredicate:nil];
}

- (NSArray*) fetchObjectsOfEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (predicate) [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSAssert(results, error.localizedDescription);
    return results;
}

- (NSManagedObject*) fetchObjectOfEntity:(NSString*)entityName withId:(NSUInteger)object_id
{
    NSEntityDescription *entityDescr = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entitiesByName[entityName];
    NSAssert(entityDescr, @"can't get description of unknown entity");
    NSArray *result = [self fetchObjectsOfEntity:entityName withPredicate:[NSPredicate predicateWithFormat:@"id==%i", object_id]];
    NSAssert([result count] < 2, @"id should be unique");
    return [result lastObject];
}


#pragma mark - Parse Foundation Objects To Core Data Objects

- (id) parseDataObject:(id)object entityName:(NSString*)entityName error:(NSError**)error
{
    id parsedObject = nil;
    
    if ([object isKindOfClass:[NSArray class]]) {
        
        NSArray *resultObjectsItems = [NSArray array];
        
        // create managed objects for all items in array
        for (NSDictionary *item in (NSArray*)object) {
            
            NSManagedObject *newObject = [self createOrUpdateManagedObjectWithEntityName:entityName objectData:item];
            if (newObject) {
                
                resultObjectsItems = [resultObjectsItems arrayByAddingObject:newObject];
                
            } else {
                *error = [NSError errorWithDomain:WMDataManagerErrorDomain code:WMDataManagerManagedObjectCreationError userInfo:nil];
                
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
            *error = [NSError errorWithDomain:WMDataManagerErrorDomain code:WMDataManagerManagedObjectCreationError userInfo:nil];
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
        NSLog(@"no entity description for %@", entityName);
        
    } else {
        
        BOOL objectExisted = NO;
        
        // if entity has an id
        if ([descr attributesByName][@"id"]) {
            
            NSNumber *object_id = data[@"id"];
            if (!object_id || ![object_id isKindOfClass:[NSNumber class]]) {
                NSLog(@"received object with invalid id");
                return nil;
            }
            
            // check if an object with this id already exists
            object = [self fetchObjectOfEntity:entityName withId:[object_id integerValue]];
            objectExisted = (object != nil);
        }
        
        // if there is no object to update, create new object for entity name
        if (!objectExisted) {
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
        }
        
        // copy all attributes to the object
        __block BOOL conversionSuccess = YES;
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            conversionSuccess = [self managedObject:object convertAndSetValue:obj forKey:key];
            
            // abort if an attribute cannot be converted
            if (!conversionSuccess) {
                NSLog(@"...property conversion failed for key %@", key);
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
                [managedObject setValue:@([value integerValue]) forKey:key];
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
                NSLog(@"Unexpected attribute type %i in entity %@", type, managedObject.entity.name);
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
        NSLog(@"ignored property %@ on entity %@", key, managedObject.entity.name);
    }
    
    return YES;
}



#pragma mark - Core Data Stack

/**
 Returns a single instance of a managed object context.
 If the context doesn't already exist, it is created with the preset
 database name and bound to a SQLite persistent store.
 */
- (NSManagedObjectContext*) managedObjectContext
{
    if (!_managedObjectContext) {
        
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
        
        // create model
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WMDataModel" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // create store coordinator
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        // get store URL
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *persistentStoreURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"WMDatabase.sqlite"];
        
        NSError *error = nil;
        // if we can't add store to coordinator...
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:persistentStoreURL
                                                            options:nil
                                                              error:NULL]) {
            
            // ... we ignore the error, and if the file already exists but is not compatible, we try to replace it with a new store file
            if ([[NSFileManager defaultManager] fileExistsAtPath:persistentStoreURL.path]) {
                
                // get metadata of existing store
                NSDictionary *metaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:persistentStoreURL error:NULL];
                
                // if meta data can't be read or model is not compatible
                if (!metaData || ![managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:metaData]) {
                    
                    // if old store file can be removed
                    if ([[NSFileManager defaultManager] removeItemAtPath:persistentStoreURL.path error:&error]) {
                        
                        // try to add new store
                        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:persistentStoreURL
                                                                       options:nil
                                                                         error:&error];
                    }
                }
            }
        }
        
        if (error) {
            // this is an unrecoverable error, so we show an alert and crash
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fatal Error" message:@"Could not create local database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        } else {
            // assign coordinator to context
            [moc setPersistentStoreCoordinator:persistentStoreCoordinator];
            
            _managedObjectContext = moc;
        }
    }
    
    return _managedObjectContext;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    abort();
}


#pragma mark - Save to Database

- (BOOL) saveData
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logValidationError:error];
        return NO;
    }
    NSLog(@"Context saved");
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
    NSLog(@"Error: %@.%@ couldn't be validated. Validation error keys: %@", entityName, object_id, validationErrorKey);
}

@end


NSString *WMDataManagerErrorDomain = @"WMDataManagerErrorDomain";




