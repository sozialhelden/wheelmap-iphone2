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
#import "Asset.h"

#define WMSearchRadius 0.004
#define WMLogDataManager 0


// TODO: fix etag check
// TODO: delete zip in temp folder
// TODO: make sure no old files exist in unzipped folder after update
// TODO: use a regular queue to enqueue both http and zip operations when syncing

@interface WMDataManager()
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStore *persistentStore;
@end


@implementation WMDataManager

- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void) didBecomeActive:(NSNotification*)notification
{
    [self syncResources];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes"
              parameters:parameters
                    eTag:nil
                    data:nil
                  method:nil
                   error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                       [self.delegate dataManager:self fetchNodesFailedWithError:error];
                   }
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                       [self didReceiveNodes:JSON[@"nodes"]];
                   }
        startImmediately:YES
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

static BOOL syncInProgress;
static BOOL assetDownloadInProgress;

- (void) syncResources
{
    if (WMLogDataManager) {
        NSLog(@"syncResources");
        NSLog(@"... num categories: %i", [[self fetchObjectsOfEntity:@"Category" withPredicate:nil] count]);
        NSLog(@"... num node types: %i", [[self fetchObjectsOfEntity:@"NodeType" withPredicate:nil] count]);
        NSLog(@"... num assets: %i", [[self fetchObjectsOfEntity:@"Asset" withPredicate:nil] count]);
    }
    
    // make sure there's only one sync running at a time
    if (syncInProgress || assetDownloadInProgress) {
        if (WMLogDataManager) NSLog(@"... sync already in progress, skipping");
        return;
    }
    syncInProgress = YES;
    assetDownloadInProgress = YES;
    
    // create categories request operation
    NSOperation *categoriesOperation = [[WMWheelmapAPI sharedInstance] requestResource:@"categories"
                                  parameters:nil
                                        eTag:[self eTagForEntity:@"Category"]
                                        data:nil
                                      method:nil
                                       error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                           dispatch_async(dispatch_get_main_queue(), ^{NSLog(@"... error loading categories");});
                                       }
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                         NSUInteger code = response.statusCode;
                                         NSLog(@"status %i", code);
                                         NSString *eTag = [response allHeaderFields][@"ETag"];
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self receivedCategories:JSON[@"categories"] withETag:eTag];
                                         });
                                     }
                            startImmediately:NO
         ];

    // create node types request operation
    NSOperation *nodeTypesOperation = [[WMWheelmapAPI sharedInstance] requestResource:@"node_types"
                                 parameters:nil
                                       eTag:[self eTagForEntity:@"NodeType"]
                                       data:nil
                                     method:nil
                                      error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                          dispatch_async(dispatch_get_main_queue(), ^{NSLog(@"... error loading node types");});
                                      }
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                        NSString *eTag = [response allHeaderFields][@"ETag"];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self receivedNodeTypes:JSON[@"node_types"] withETag:eTag];
                                        });
                                    }
                           startImmediately:NO
    ];
    
    // create assets operation
    NSOperation *assetsOperation = [[WMWheelmapAPI sharedInstance] requestResource:@"assets"
                                                parameters:nil
                                                      eTag:[self eTagForEntity:@"Asset"]
                                                      data:nil
                                                    method:nil
                                                     error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{NSLog(@"... error loading assets");});
                                                     }
                                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                       NSString *eTag = [response allHeaderFields][@"ETag"];
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [self receivedAssets:JSON[@"assets"] withETag:eTag];
                                                       });
                                                   }
                                          startImmediately:NO
                                       ];
    
    // enqueue operations
    [[WMWheelmapAPI sharedInstance] enqueueBatchOfHTTPRequestOperations:@[categoriesOperation, nodeTypesOperation, assetsOperation]
                              progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                  // Maybe show this progress on splash screen at first launch
                              }
                            completionBlock:^(NSArray *operations) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (WMLogDataManager) NSLog(@"... sync assets finished");
                                    syncInProgress = NO;
                                    [self finishSync];
                                });
                            }
     ];
}

- (void) receivedCategories:(NSArray*)categories withETag:(NSString*) eTag
{
    BOOL dataIsUpdated = ![eTag isEqual:[self eTagForEntity:@"Category"]];
    if (WMLogDataManager) NSLog(@"... received %i categories %@", [categories count], dataIsUpdated?@"from cache":@"");
    
    if (dataIsUpdated && categories) {
        NSError *error = nil;
        [self parseDataObject:categories entityName:@"Category" error:&error];
        if (error) {
            // TODO: handle error
        } else {
            [self setETag:eTag forEntity:@"Category"];
        }
    }
}

- (void) receivedNodeTypes:(NSArray*)nodeTypes withETag:(NSString*) eTag
{
    BOOL dataIsUpdated = ![eTag isEqual:[self eTagForEntity:@"NodeType"]];
    if (WMLogDataManager) NSLog(@"... received %i node types %@", [nodeTypes count], dataIsUpdated?@"from cache":@"");
    if (nodeTypes) {
        NSError *error = nil;
        [self parseDataObject:nodeTypes entityName:@"NodeType" error:&error];
        if (error) {
            // TODO: handle error
        } else {
            [self setETag:eTag forEntity:@"NodeType"];
        }
    }
}

- (void) receivedAssets:(NSArray*)assets withETag:(NSString*) eTag
{
    if (WMLogDataManager) NSLog(@"... received %i assets", [assets count]);
    
    if (!assets) return;
        
    // if eTag has not changed
    if (![eTag isEqual:[self eTagForEntity:@"Asset"]]) {
       
        // store old icon modified date
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'icons'"];
        Asset *icon = [[self fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
        NSDate *oldLastModified = icon.modified_at;
        
        // parse data
        NSError *error = nil;
        [self parseDataObject:assets entityName:@"Asset" error:&error];
        if (error) {
            // TODO: handle error
        } else {
            
            // update etag
            [self setETag:eTag forEntity:@"Asset"];
            
            // get new icon
            icon = [[self fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
            
            // check if modified date has changed
            if (![icon.modified_at isEqual:oldLastModified]) {
                [self downloadFilesForAsset:icon];
                return;
            }
        }
    }
    
    assetDownloadInProgress = NO;
    [self finishSync];
}

- (void) downloadFilesForAsset:(Asset*)asset
{
    if (WMLogDataManager) NSLog(@"... download file for asset %@ from %@", asset.name, asset.url);

    // use /tmp dir for archive download
    NSString *path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.zip", asset.name];

    NSOperation *operation = [[WMWheelmapAPI sharedInstance] downloadFile:[NSURL URLWithString:asset.url]
                                                                   toPath:path
                                                                    error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            if (WMLogDataManager) NSLog(@"... download error");
                                                                            assetDownloadInProgress = NO;
                                                                            [self finishSync];
                                                                        });
                                                                    } 
                                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          if (WMLogDataManager) NSLog(@"... download success");
                                                                          [self didFinishFileDownload:path forAsset:asset];
                                                                      });
                                                                  }
                                                         startImmediately:NO
    ];
    
    [[WMWheelmapAPI sharedInstance] enqueueHTTPRequestOperation:(id)operation];// TODO: remove cast (it hides dependency on AFNetworking)
}

- (void) didFinishFileDownload:(NSString*)path forAsset:(Asset*)asset
{
    // get path where file should be unzipped
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *destinationPath = [paths objectAtIndex:0];
    
    // unzip file
    NSError *error = nil;
    [SSZipArchive unzipFileAtPath:path toDestination:destinationPath overwrite:YES password:nil error:&error delegate:self];
    if (error) {
        // TODO: handle error
        if (WMLogDataManager) NSLog(@"... unzipping failed");
        assetDownloadInProgress = NO;
        [self finishSync];
    } else {
        if (WMLogDataManager) NSLog(@"... unzipping file");
    }
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    if (WMLogDataManager) NSLog(@"... did unzip file");
    assetDownloadInProgress = NO;
    [self finishSync];
}

- (void) finishSync
{
    if (!syncInProgress && !assetDownloadInProgress) {
        if (WMLogDataManager) NSLog(@"... finished sync and asset download");
        [self.delegate dataManagerDidFinishSyncingResources:self];
    }
}


#pragma mark - Expose Data

- (NSArray *)categories
{
    return [self fetchObjectsOfEntity:@"Category" withPredicate:nil];
}

- (NSArray *)nodeTypes
{
    return [self fetchObjectsOfEntity:@"NodeType" withPredicate:nil];
}


#pragma mark - Parse Foundation Objects To Core Data Objects

- (id) parseDataObject:(id)object entityName:(NSString*)entityName error:(NSError**)error
{
    NSParameterAssert(object);
    NSParameterAssert(entityName);
    
    if (WMLogDataManager) NSLog(@"parsing %@", entityName);
    
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
    
    [self saveData];
    
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
        if (WMLogDataManager) NSLog(@"... no entity description for %@", entityName);
        
    } else {
        
        BOOL objectExisted = NO;
        
        // if entity has an id
        if ([descr attributesByName][@"id"]) {
            
            NSNumber *object_id = data[@"id"];
            if (!object_id || ![object_id isKindOfClass:[NSNumber class]]) {
                if (WMLogDataManager) NSLog(@"... received object with invalid id");
                return nil;
            }
            
            // check if an object with this id already exists
            object = [self fetchObjectOfEntity:entityName withId:[object_id integerValue]];
            objectExisted = (object != nil);
        }
        
        // if there is no object to update, create new object for entity name
        if (!objectExisted) {
            if (WMLogDataManager) NSLog(@"... creating %@", entityName);
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
            
        } else {
            if (WMLogDataManager) NSLog(@"... updating %@", entityName);
        }
        
        // copy all attributes to the object
        __block BOOL conversionSuccess = YES;
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            conversionSuccess = [self managedObject:object convertAndSetValue:obj forKey:key];
            
            // abort if an attribute cannot be converted
            if (!conversionSuccess) {
                if (WMLogDataManager) NSLog(@"... property conversion failed for key %@", key);
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
     if (WMLogDataManager) NSLog(@"...... setting value %@ for key %@", value, key);
    
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
                if (WMLogDataManager) NSLog(@"...... Unexpected attribute type %i in entity %@", type, managedObject.entity.name);
                return NO;
        }
        
        // if property is a relationship
    } else if ([descr isKindOfClass:[NSRelationshipDescription class]]) {
        
        NSRelationshipDescription *relationship = (NSRelationshipDescription*)descr;
        
        // get the destination entity
        NSEntityDescription *destinationEntity = [relationship destinationEntity];
        
        // if it is a to-many relationship
        if ([relationship isToMany]) {
            
            NSAssert([value isKindOfClass:[NSArray class]], @"...... Expected array as value of to-many-relationship");
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
        if (WMLogDataManager) NSLog(@"...... ignored property %@ on entity %@", key, managedObject.entity.name);
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
    static NSManagedObjectContext *_managedObjectContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
        
        // create model
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WMDataModel" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // create store coordinator
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        // get store URL
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *persistentStoreURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"WMDatabase.sqlite"];
        
        // try to add persistent store
        _persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                    configuration:nil
                                                                              URL:persistentStoreURL
                                                                          options:nil
                                                                            error:NULL];
        // if we can't add store to coordinator...
        NSError *error = nil;
        if (!_persistentStore) {
            
            NSLog(@"cannot add persistent store");
            
            // ... we ignore the error, and if the file already exists but is not compatible, we try to replace it with a new store file
            if ([[NSFileManager defaultManager] fileExistsAtPath:persistentStoreURL.path]) {
                
                // get metadata of existing store
                NSDictionary *metaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:persistentStoreURL error:NULL];
                
                // if meta data can't be read or model is not compatible
                if (!metaData || ![managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:metaData]) {
                    
                    NSLog(@"persistent store meta data can't be read or is not compatible");
                    
                    // if old store file can be removed
                    if ([[NSFileManager defaultManager] removeItemAtPath:persistentStoreURL.path error:&error]) {
                        
                        // try to add new store
                        _persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
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
            NSLog(@"cannot add persistent store, aborting");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fatal Error" message:@"Could not create local database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        } else {
            // assign coordinator to context
            [moc setPersistentStoreCoordinator:persistentStoreCoordinator];
            
            _managedObjectContext = moc;
        }
    });
    
    return _managedObjectContext;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    abort();
}


#pragma mark - Core Data Utility Methods

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

- (NSString*) eTagForEntity:(NSString*)entityName
{
    NSDictionary *metaData = [self.managedObjectContext.persistentStoreCoordinator metadataForPersistentStore:self.persistentStore];
    NSDictionary *eTags = metaData[@"eTags"];
    return eTags[entityName];
}

- (void) setETag:(NSString*)eTag forEntity:(NSString*)entityName
{
    // get meta data from persistent store
    NSMutableDictionary *metaData = [[self.managedObjectContext.persistentStoreCoordinator metadataForPersistentStore:self.persistentStore] mutableCopy];
    
    // create eTags dictionary if necessary
    NSMutableDictionary *eTags = [[metaData objectForKey:@"eTags"] mutableCopy] ?: [NSMutableDictionary dictionary];
    
    // use entity name as key of eTag
    eTags[entityName] = eTag;
    
    // save new eTags dictionary in meta data
    [metaData setObject:eTags forKey:@"eTags"];
    
    // save altered meta data to persistent store
    [self.managedObjectContext.persistentStoreCoordinator setMetadata:metaData forPersistentStore:self.persistentStore];
    [self saveData];
}

- (BOOL) saveData
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [self logValidationError:error];
        return NO;
    }
    if (WMLogDataManager) NSLog(@"Context saved");
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
    if (WMLogDataManager) NSLog(@"Error: %@.%@ couldn't be validated. Validation error keys: %@", entityName, object_id, validationErrorKey);
}


@end

NSString *WMDataManagerErrorDomain = @"WMDataManagerErrorDomain";




