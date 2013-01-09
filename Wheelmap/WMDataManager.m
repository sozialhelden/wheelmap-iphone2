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
#import "WMKeychainWrapper.h"
#import "Asset.h"
#import "NodeType.h"
#import "Node.h"
#import "Photo.h"
#import "Image.h"
#import "Category.h"
#import "WMDataParser.h"


#define WMSearchRadius 0.004
#define WMLogDataManager 0

// Max number of nodes per page that should be returned for a bounding box request, based on experience.
// The API limits this value currently to 500 (as of 12/29/2012)
// Setting a high limit here is necessary to avoid a nasty problem where newly added nodes
// won't show in results, because nodes are returned with ascending id from the server,
// so the newest nodes come last (that"s why using pages doesn't make any sense here).
// If you experience this problem, try to use smaller bounding boxes before raising this number.
#define WMNodeLimit 700


// TODO: fix etag check


@interface WMDataManager()
@property (nonatomic, readonly) NSManagedObjectContext *mainMOC;
@property (nonatomic, readonly) NSManagedObjectContext *backgroundMOC;
@property (nonatomic) NSManagedObjectContext *temporaryMOC;
@property (nonatomic, readonly) NSPersistentStore *persistentStore;
@property (nonatomic, readonly) WMKeychainWrapper *keychainWrapper;
@property (nonatomic) NSNumber* totalNodeCount;
@property (nonatomic) NSNumber* unknownNodeCount;
@end


@implementation WMDataManager
{
    NSMutableArray *syncErrors;
    NSMutableDictionary *iconPaths;
    NSString *appApiKey;
    NSManagedObjectContext *_temporaryMOC;
}


#pragma mark - API Key

- (WMKeychainWrapper*) keychainWrapper
{
    static WMKeychainWrapper *_keychainWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _keychainWrapper = [[WMKeychainWrapper alloc] init];
    });
    return _keychainWrapper;
}

- (NSString*) apiKey
{
    // check if a user key is stored in the keychain
    NSString *userToken = [self.keychainWrapper tokenForAccount:nil];
    if ([userToken length] > 0) {
        return userToken;
    }
    
    // else, use app key
    if (!appApiKey) {
        // load it from config file if necessary
        NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WMConfig" ofType:@"plist"]];
        appApiKey = config[@"appAPIKey"];
    }
    
    return appApiKey;
}


#pragma mark - Authentication

- (void)authenticateUserWithEmail:(NSString *)email password:(NSString *)password
{
    if (WMLogDataManager) NSLog(@"authenticate user w email:%@ pw:%@", email, password);
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"users/authenticate"
                                             apiKey:[self apiKey]
                                         parameters:@{@"email":email, @"password":password}
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:userAuthenticationFailedWithError:)]) {
                                                      [self.delegate dataManager:self userAuthenticationFailedWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                [self didReceiveAuthenticationData:JSON[@"user"] forAccount:email];
                                            }
                                   startImmediately:YES
     ];
}

- (void) didReceiveAuthenticationData:(NSDictionary*)user forAccount:(NSString*)account
{
    NSString *userToken = user[@"api_key"];
    if (WMLogDataManager) NSLog(@"received user token %@", userToken);
    
    if (userToken) {
        
        // save token to keychain
        BOOL saveSuccess = [self.keychainWrapper saveToken:userToken forAccount:account];
        if (WMLogDataManager) NSLog(@"saved user token to keychain with %@", saveSuccess ? @"success" : @"error");
        
        if (saveSuccess) {
            // now that we have saved a token, we can delete legacy keychain data
            [self.keychainWrapper deleteLegacyAccountData];
            // save last login email into the userdefault (this should be improved..)
            
            NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:[self currentUserName] forKey:@"WheelmapLastUserName"];
        }
        
        if ([self.delegate respondsToSelector:@selector(dataManagerDidAuthenticateUser:)]) {
            [self.delegate dataManagerDidAuthenticateUser:self];
        }
        
    } else if ([self.delegate respondsToSelector:@selector(dataManager:userAuthenticationFailedWithError:)]) {
        NSError *error = [NSError errorWithDomain:WMDataManagerErrorDomain code:WMDataManagerInvalidUserKeyError userInfo:nil];
        [self.delegate dataManager:self userAuthenticationFailedWithError:error];
    }
}

- (BOOL) userIsAuthenticated
{
    NSString *userToken = [self.keychainWrapper tokenForAccount:nil];
    return ([userToken length] > 0);
}

- (void)removeUserAuthentication
{
    BOOL deleteSuccess = [self.keychainWrapper deleteTokenForAccount:nil];
    if (WMLogDataManager) NSLog(@"removed user token from keychain with %@", deleteSuccess ? @"success" : @"error");
}

- (NSDictionary *) legacyUserCredentials
{
    return [self.keychainWrapper legacyAccountData];
}

- (NSString*)currentUserName
{
    return self.keychainWrapper.userAccount;
}


#pragma mark - Fetch Nodes

- (void) fetchNodesNear:(CLLocationCoordinate2D)location
{
    // get rect of area within search radius around current location
    // this rect won"t have the same proportions as the map area on screen
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake(location.latitude - WMSearchRadius, location.longitude - WMSearchRadius);
    CLLocationCoordinate2D northeast = CLLocationCoordinate2DMake(location.latitude + WMSearchRadius, location.longitude + WMSearchRadius);
    
    [self fetchNodesBetweenSouthwest:southwest northeast:northeast query:nil];
}

-(void)fetchNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest northeast:(CLLocationCoordinate2D)northeast query:(NSString *)query
{
    NSString *coords = [NSString stringWithFormat:@"%f,%f,%f,%f",
                        southwest.longitude,
                        southwest.latitude,
                        northeast.longitude,
                        northeast.latitude];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[@"bbox"] = coords;
    parameters[@"per_page"] = @WMNodeLimit;
    if (query) parameters[@"q"] = query;

    if (WMLogDataManager) NSLog(@"fetching nodes in bbox %@", coords);
    
    [[WMWheelmapAPI sharedInstance] requestResource:query ? @"nodes/search" : @"nodes"
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  [self fetchNodesFailedWithError:error];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                [self didReceiveNodes:JSON[@"nodes"]];
                                            }
                                   startImmediately:YES
     ];   
}

- (void)fetchNodesWithQuery:(NSString*)query
{
    NSDictionary* parameters = @{@"q":query};
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes/search"
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  [self fetchNodesFailedWithError:error];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                [self didReceiveNodes:JSON[@"nodes"]];
                                            }
                                   startImmediately:YES
     ];
}

- (void) fetchNodesFailedWithError:(NSError*) error
{
    if ([self.delegate respondsToSelector:@selector(dataManager:fetchNodesFailedWithError:)]) {
        [self.delegate dataManager:self fetchNodesFailedWithError:error];
    }
}

- (void) didReceiveNodes:(NSArray *)nodes
{
    if (WMLogDataManager) NSLog(@"received %i nodes", [nodes count]);
    
    [self parseDataObjectInBackground:nodes
               entityName:@"Node"
                    error:^(NSError *error) {
                        if ([self.delegate respondsToSelector:@selector(dataManager:fetchNodesFailedWithError:)]) {
                            [self.delegate dataManager:self fetchNodesFailedWithError:error];
                        }
                    }
                  success:^(id parsedNodes) {
                      if (WMLogDataManager) {
                          NSArray *allNodes = [self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Node" withPredicate:nil];
                          NSLog(@"parsed %i nodes. Total count is now %i", [(NSArray*)parsedNodes count], [allNodes count]);
                      }
                        if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveNodes:)]) {
                            [self.delegate dataManager:self didReceiveNodes:parsedNodes];
                        }
                  }
     ];
}

- (void) parseDataObjectInBackground:(id)object
            entityName:(NSString*)entityName
                 error:(void (^)(NSError *error))errorBlock
               success:(void (^)(id parsedObject))successBlock
{
    // perform parsing on private queue and perform result blocks on current queue
    [self.backgroundMOC performBlock:^{
        
        // create parser with temporary context
        WMDataParser *parser = [[WMDataParser alloc] initWithManagedObjectContext:self.backgroundMOC];
        
        // parse data
        NSError *parseError = nil;
        id parsedObject = [parser parseDataObject:object entityName:entityName error:&parseError];
        
        if (!parsedObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(parseError);
            });
            
        } else {
            
            NSArray *result = (NSArray*)parsedObject;
            
            // get permanent IDs
            NSError *permanentIDsError = nil;
            
            // WORKAROUND: get permanent ids of all pending objects, not just the result objects,
            // to work around a bug in iOS 5 (http://openradar.appspot.com/11478919)
            NSSet *pendingObjects = [[self.backgroundMOC updatedObjects] setByAddingObjectsFromSet:[self.backgroundMOC insertedObjects]];
            pendingObjects = [pendingObjects setByAddingObjectsFromSet:[self.backgroundMOC deletedObjects]];
            if(![self.backgroundMOC obtainPermanentIDsForObjects:[pendingObjects allObjects] error:&permanentIDsError]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(permanentIDsError);
                });
                
            } else {
                
                // merge changes to parent moc
                NSError *saveTempMocError = nil;
                if (![self.backgroundMOC save:&saveTempMocError]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorBlock(saveTempMocError);
                    });
                    
                } else {
                    
                    [self.mainMOC performBlock:^{
                        
                        // save parent moc to disk
                        NSError *saveParentMocError = nil;
                        if (![self.mainMOC save:&saveParentMocError]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                errorBlock(saveParentMocError);
                            });
                            
                        } else {
                            
                            // fetch result objects from main moc
                            NSMutableArray *resultObjectsInMainMoc = [NSMutableArray arrayWithCapacity:[result count]];
                            [result enumerateObjectsUsingBlock:^(NSManagedObject* obj, NSUInteger idx, BOOL *stop) {
                                [resultObjectsInMainMoc addObject:[self.mainMOC objectWithID:obj.objectID]];
                            }];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                successBlock(resultObjectsInMainMoc);
                            });
                        }
                    }];
                }                
            }
        }
    }];
}


#pragma mark - Put/Post a node

-(void) updateWheelchairStatusOfNode:(Node *)node
{
    if (WMLogDataManager) NSLog(@"update wheelchair status to %@", node.wheelchair);
    
    NSDictionary* parameters = @{@"wheelchair":node.wheelchair};
    [[WMWheelmapAPI sharedInstance] requestResource:[NSString stringWithFormat:@"nodes/%@/update_wheelchair", node.id]
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                             method:@"PUT"
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:updateWheelchairStatusOfNode:failedWithError:)]) {
                                                      [self.delegate dataManager:self updateWheelchairStatusOfNode:node failedWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didUpdateWheelchairStatusOfNode:)]) {
                                                    [self.delegate dataManager:self didUpdateWheelchairStatusOfNode:node];
                                                }
                                            }
                                   startImmediately:YES
     ];   
}

-(void) updateNode:(Node *)node
{
    if (WMLogDataManager) NSLog(@"update node %@", node.name);
    
    // if this is a put
    if (node.id) {
        
        // validate node
        NSError *validationError = nil;
        if (![node validateForUpdate:&validationError]) {
            if (WMLogDataManager) [self logValidationError:validationError];
            if ([self.delegate respondsToSelector:@selector(dataManager:updateNode:failedWithError:)]) {
                [self.delegate dataManager:self updateNode:node failedWithError:validationError];
            }
            return;
        }
    }

    NSDictionary* parameters = @{
        @"city" : node.city ?: [NSNull null],
        @"housenumber" : node.housenumber ?: [NSNull null],
        @"lat" : node.lat ?: [NSNull null],
        @"lon" : node.lon ?: [NSNull null],
        @"name" : node.name ?: [NSNull null],
        @"phone" : node.phone ?: [NSNull null],
        @"postcode" : node.postcode ?: [NSNull null],
        @"street" : node.street ?: [NSNull null],
        @"website" : node.website ?: [NSNull null],
        @"wheelchair" : node.wheelchair ?: [NSNull null],
        @"wheelchair_description" : node.wheelchair_description ?: [NSNull null],
        @"type" : node.node_type.identifier ?: [NSNull null]
    };

    [[WMWheelmapAPI sharedInstance] requestResource:node.id ? [NSString stringWithFormat:@"nodes/%@/", node.id] : @"nodes"
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                             method:node.id ? @"PUT" : @"POST"
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:updateNode:failedWithError:)]) {
                                                      [self.delegate dataManager:self updateNode:node failedWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                
                                                // save changes to disk if this was a put
                                                if (node.id) {
                                                    [self.mainMOC performBlock:^{
                                                        NSError *saveParentMocError = nil;
                                                        if (![self.mainMOC save:&saveParentMocError]) {
                                                            if (WMLogDataManager) [self logValidationError:saveParentMocError];
                                                            NSAssert(YES, @"error saving moc after node PUT");
                                                        }
                                                    }];
                                                }
                                                
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didUpdateNode:)]) {
                                                    [self.delegate dataManager:self didUpdateNode:node];
                                                }
                                            }
                                   startImmediately:YES
     ];    
}


#pragma mark - Sync Resources

// use static variables to make sure there's only one sync running at a time
// across all instances of WMDatamanager
static BOOL nodeTypeSyncInProgress = NO;
static BOOL categorySyncInProgress = NO;
static BOOL assetSyncInProgress = NO;

- (BOOL) syncInProgress
{
    return nodeTypeSyncInProgress || categorySyncInProgress || assetSyncInProgress;
}

- (void) syncResources
{
    if (WMLogDataManager) NSLog(@"syncResources");
    if (WMLogDataManager>1) {
        NSLog(@"... num categories: %i", [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Category" withPredicate:nil] count]);
        NSLog(@"... num node types: %i", [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"NodeType" withPredicate:nil] count]);
        NSLog(@"... num assets: %i", [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Asset" withPredicate:nil] count]);
    }
    
    // make sure there's only one sync running at a time
    if (self.syncInProgress) {
        if (WMLogDataManager>1) NSLog(@"... sync already in progress, skipping");
        return;
    }
    
    nodeTypeSyncInProgress = YES;
    categorySyncInProgress = YES;
    assetSyncInProgress = YES;
    
    syncErrors = nil;
    
    // check if cached assets are available on disk (could have been purged by the system)
    [self.nodeTypes enumerateObjectsUsingBlock:^(NodeType *nodeType, NSUInteger idx, BOOL *stop) {
        if (nodeType.iconPath && ![[NSFileManager defaultManager] fileExistsAtPath:nodeType.iconPath]) {
            if(WMLogDataManager>1) NSLog(@"... cached icon not found: %@", nodeType.iconPath);
            
            // if any file is missing, reset eTag and modified date to force reload of assets
            [self setETag:nil forEntity:@"Asset"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'icons'"];
            Asset *icon = [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
            icon.modified_at = [NSDate dateWithTimeIntervalSince1970:0];
            
            *stop = YES;
        }
    }];
    
    // TODO: make string consistent with v1.0
    // check if the locale setting is changed
    // get the previous locale
    NSString* prev_locale = [[NSUserDefaults standardUserDefaults] objectForKey:@"WheelMap2-PreviousLocaleString"];
    NSString* current_locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    BOOL localeChanged = NO;
    if (!prev_locale) {
        // this is the first launch, so we assume that the locale is not changed (new)
        localeChanged = NO;
    } else {
        // we have both of prev and current locales
        if ([prev_locale isEqualToString:current_locale]) {
            // the locale is not changed.
            localeChanged = NO;
        } else {
            localeChanged = YES;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:current_locale forKey:@"WheelMap2-PreviousLocaleString"];
    
    // create categories request operation    
    [[WMWheelmapAPI sharedInstance] requestResource:@"categories"
                                             apiKey:[self apiKey]
                                         parameters:@{@"locale" :[[NSLocale preferredLanguages] objectAtIndex:0]}
                                               eTag:localeChanged ? nil : [self eTagForEntity:@"Category"]
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if (WMLogDataManager>1) NSLog(@"... error loading categories");
                                                  categorySyncInProgress = NO;
                                                  [self syncOperationFailedWithError:error];
                                                  [self finishSync];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                
                                                NSString *eTag = [response allHeaderFields][@"ETag"];
                                                id categories = JSON[@"categories"];
                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:@"Category"]];
                                                if (WMLogDataManager>1) NSLog(@"... received %i categories, %@", [categories count], eTagChanged?@"eTag changed":@"eTag is same");
                                                
                                                if (eTagChanged && categories) {
                                                    
                                                    [self parseDataObjectInBackground:categories
                                                                           entityName:@"Category"
                                                                                error:^(NSError *error) {
                                                                                    categorySyncInProgress = NO;
                                                                                    [self syncOperationFailedWithError:error];
                                                                                    [self finishSync];
                                                                                }
                                                                              success:^(id parsedObject) {
                                                                                  categorySyncInProgress = NO;
                                                                                  [self setETag:eTag forEntity:@"Category"];
                                                                                  [self finishSync];
                                                                              }
                                                     ];
                                                } else {
                                                    categorySyncInProgress = NO;
                                                    [self finishSync];
                                                }
                                            }
                                   startImmediately:YES
    ];

    // create node types request operation
    [[WMWheelmapAPI sharedInstance] requestResource:@"node_types"
                                             apiKey:[self apiKey]
                                         parameters:@{@"locale" :[[NSLocale preferredLanguages] objectAtIndex:0]}
                                               eTag:localeChanged ? nil : [self eTagForEntity:@"NodeType"]
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if (WMLogDataManager>1) NSLog(@"... error loading node types");
                                                  nodeTypeSyncInProgress = NO;
                                                  [self syncOperationFailedWithError:error];
                                                  [self finishSync];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                
                                                NSString *eTag = [response allHeaderFields][@"ETag"];
                                                id nodeTypes = JSON[@"node_types"];
                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:@"NodeType"]];
                                                if (WMLogDataManager>1) NSLog(@"... received %i node types %@", [nodeTypes count], eTagChanged?@"eTag changed":@"eTag is same");
                                                
                                                if (eTagChanged && nodeTypes) {
                                                    
                                                    [self parseDataObjectInBackground:nodeTypes
                                                                           entityName:@"NodeType"
                                                                                error:^(NSError *error) {
                                                                                    nodeTypeSyncInProgress = NO;
                                                                                    [self syncOperationFailedWithError:error];
                                                                                    [self finishSync];
                                                                                }
                                                                              success:^(id parsedObject) {
                                                                                  nodeTypeSyncInProgress = NO;
                                                                                  [self setETag:eTag forEntity:@"NodeType"];
                                                                                  [self finishSync];
                                                                              }
                                                     ];
                                                } else {
                                                    nodeTypeSyncInProgress = NO;
                                                    [self finishSync];
                                                }
                                            }
                                   startImmediately:YES
    ];
    
    // create assets operation
    [[WMWheelmapAPI sharedInstance] requestResource:@"assets"
                                             apiKey:[self apiKey]
                                         parameters:nil
                                               eTag:[self eTagForEntity:@"Asset"]
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if (WMLogDataManager>1) NSLog(@"... error loading assets");
                                                  assetSyncInProgress = NO;
                                                  [self syncOperationFailedWithError:error];
                                                  [self finishSync];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                
                                                NSString *eTag = [response allHeaderFields][@"ETag"];
                                                id assets = JSON[@"assets"];
                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:@"Asset"]];
                                                if (WMLogDataManager>1) NSLog(@"... received %i assets %@", [assets count], eTagChanged?@"eTag changed":@"eTag is same");
                                                
                                                if (eTagChanged && assets) {
                                                    
                                                    // store old icon modified date
                                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'icons'"];
                                                    Asset *oldIcon = [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
                                                    NSDate *oldIconModifiedAt = oldIcon.modified_at;
                                                    
                                                    // parse data
                                                    [self parseDataObjectInBackground:assets
                                                                           entityName:@"Asset"
                                                                                error:^(NSError *error) {
                                                                                    assetSyncInProgress = NO;
                                                                                    [self syncOperationFailedWithError:error];
                                                                                    [self finishSync];
                                                                                }
                                                                              success:^(id parsedObject) {
                                                                                  
                                                                                  // update etag
                                                                                  [self setETag:eTag forEntity:@"Asset"];
                                                                                  
                                                                                  // get new icon
                                                                                  Asset *newIcon = [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
                                                                                  
                                                                                  // check if modified date has changed
                                                                                  if (![newIcon.modified_at isEqual:oldIconModifiedAt]) {
                                                                                      [self downloadFilesForAsset:newIcon];
                                                                                  } else {
                                                                                      assetSyncInProgress = NO;
                                                                                      [self finishSync];
                                                                                  }
                                                                              }
                                                     ];
                                                } else {
                                                    
                                                    assetSyncInProgress = NO;
                                                    [self finishSync];
                                                }
                                            }
                                   startImmediately:YES
    ];
}

- (void) downloadFilesForAsset:(Asset*)asset
{
    if (WMLogDataManager>1) NSLog(@"... download file for asset %@ from %@", asset.name, asset.url);

    // use /tmp dir for archive download
    NSString *path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.zip", asset.name];

    [[WMWheelmapAPI sharedInstance] downloadFile:[NSURL URLWithString:asset.url]
                                          toPath:path
                                           error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               if (WMLogDataManager) NSLog(@"... file download error");
                                               assetSyncInProgress = NO;
                                               [self syncOperationFailedWithError:error];
                                               [self finishSync];
                                           }
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response) {
                                             if (WMLogDataManager) NSLog(@"... download success");
                                             // get path where file should be unzipped
                                             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                             NSString *destinationPath = [paths objectAtIndex:0];
                                             
                                             // init dictionary to save the local paths of unzipped files
                                             iconPaths = [NSMutableDictionary dictionary];
                                             
                                             // unzip file
                                             NSError *error = nil;
                                             if (![SSZipArchive unzipFileAtPath:path toDestination:destinationPath overwrite:YES password:nil error:&error delegate:self]) {
                                                 
                                                 if (WMLogDataManager>1) NSLog(@"... unzipping failed");
                                                 // NOTE: any files in the destination dir that are not used by the new data will
                                                 // remain on disk. however, since this is in the caches dir, if this dir gets too big,
                                                 // it will eventually be cleaned up by the system. the app should then reload all assets.
                                             
                                                 assetSyncInProgress = NO;
                                                 [self syncOperationFailedWithError:error];
                                                 [self finishSync];                                             
                                             }
                                         }
                                startImmediately:YES
    ];
}

- (void) syncOperationFailedWithError:(NSError*)error
{
    if (!syncErrors) syncErrors = [NSMutableArray array];
    [syncErrors addObject:error];
}

- (void) finishSync
{
    if (!self.syncInProgress) {
        
        // set iconPath on NodeType objects if new icons have been downloaded during sync process
        if (iconPaths) {
            
            // update in child context to keep it current
            [self.backgroundMOC performBlockAndWait:^{
                
                NSArray *nodeTypes = [self managedObjectContext:self.backgroundMOC fetchObjectsOfEntity:@"NodeType" withPredicate:nil];
                [nodeTypes enumerateObjectsUsingBlock:^(NodeType *nodeType, NSUInteger idx, BOOL *stop) {
                
                    NSString *iconPath = nil;
                    if (nodeType.icon) {
                        iconPath = iconPaths[nodeType.icon];
                        
                    } else if (WMLogDataManager>1) {
                        NSLog(@"... no icon set for nodeType %@", nodeType.identifier);
                    }
                    
                    nodeType.iconPath = iconPath;
                        
                    if (WMLogDataManager>1 && !iconPath) {
                        NSLog(@"... icon %@ not found for nodeType %@", nodeType.icon, nodeType.identifier);
                    }
                }];
                
                // merge changes to parent moc
                NSError *saveTempMocError = nil;
                if (![self.backgroundMOC save:&saveTempMocError]) {
                    [self syncOperationFailedWithError:saveTempMocError];
                    
                } else {
                    
                    // save parent moc to disk
                    [self.mainMOC performBlock:^{
                        NSError *saveParentMocError = nil;
                        if (![self.mainMOC save:&saveParentMocError]) {
                            [self syncOperationFailedWithError:saveParentMocError];                            
                        }
                    }];
                }
            }];
                        
            iconPaths = nil;
        }
        
        if (syncErrors) {
            if (WMLogDataManager>1) NSLog(@"... finished sync with %i errors", [syncErrors count]);
            if ([self.delegate respondsToSelector:@selector(didFinishSyncingResourcesWithErrors:)]) {
                [self.delegate dataManager:self didFinishSyncingResourcesWithErrors:syncErrors];
            }
        } else {
            if (WMLogDataManager>1) NSLog(@"... finished sync with no errors");
            
            if (WMLogDataManager) {
                NSArray *categories = [self managedObjectContext:self.mainMOC  fetchObjectsOfEntity:@"Category" withPredicate:nil];
                NSArray *nodeTypes = [self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"NodeType" withPredicate:nil];
                NSLog(@"counting %i NodeType, %i Category", [categories count], [nodeTypes count]);
            }
            
            if ([self.delegate respondsToSelector:@selector(dataManagerDidFinishSyncingResources:)]) {
                [self.delegate dataManagerDidFinishSyncingResources:self];
            }
        }
    }
}


#pragma mark -  ZIP Archive Delegate

- (void)zipArchiveDidUnzipFile:(NSString *)destinationPath
{
    NSString *filename = [destinationPath lastPathComponent];
    [iconPaths setObject:destinationPath forKey:filename];
    if (WMLogDataManager>2) NSLog(@"...... unzipped %@", filename);
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    if (WMLogDataManager) NSLog(@"... did unzip archive");    
    
    // delete downloaded zip file from tmp folder
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        if (WMLogDataManager>1) NSLog(@"... can't delete temp file %@", path);
        [self syncOperationFailedWithError:error];
    }
    
    assetSyncInProgress = NO;
    [self finishSync];
}


#pragma mark - Fetch Photos

- (void) fetchPhotosForNode:(Node*)node
{
    [[WMWheelmapAPI sharedInstance] requestResource:[NSString stringWithFormat:@"nodes/%@/photos", node.id]
                                             apiKey:[self apiKey]
                                         parameters:nil
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:fetchPhotosForNode:failedWithError:)]) {
                                                      [self.delegate dataManager:self fetchPhotosForNode:node failedWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                [self didReceivePhotos:JSON[@"photos"] forNode:node];
                                            }
                                   startImmediately:YES
     ];
}

- (void) didReceivePhotos:(NSArray*)photos forNode:(Node*)node
{    
    [self parseDataObjectInBackground:photos
               entityName:@"Photo"
                    error:^(NSError *error) {
                        if ([self.delegate respondsToSelector:@selector(dataManager:fetchPhotosForNode:failedWithError:)]) {
                            [self.delegate dataManager:self fetchPhotosForNode:node failedWithError:error];
                        }
                    }
                  success:^(id parsedData) {
                      if (![parsedData isKindOfClass:[NSArray class]]) {
                          if ([self.delegate respondsToSelector:@selector(dataManager:fetchPhotosForNode:failedWithError:)]) {
                              NSError *parseError = [NSError errorWithDomain:WMDataManagerErrorDomain code:WMDataManagerManagedObjectCreationError userInfo:nil];
                              [self.delegate dataManager:self fetchPhotosForNode:node failedWithError:parseError];
                          }
                          
                      } else {
                          
                          // assign photos to node
                          node.photos = [NSSet setWithArray:(NSArray*)parsedData];
                          
                          if ([self.delegate respondsToSelector:@selector(dataManager:didReceivePhotosForNode:)]) {
                              [self.delegate dataManager:self didReceivePhotosForNode:node];
                          }
                      }                      
                  }
     ];
}


#pragma mark - Upload Image

- (void) uploadImage:(UIImage*)image forNode:(Node*)node
{
    
    [[WMWheelmapAPI sharedInstance] uploadImage:image
                                         nodeID:node.id
                                         apiKey:[self apiKey]
                                          error:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError *error, id JSON) {
                                              if ([self.delegate respondsToSelector:@selector(dataManager:uploadImageForNode:failedWithError:)]) {
                                                  [self.delegate dataManager:self uploadImageForNode:node failedWithError:error];
                                              }
                                        }
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                            if ([self.delegate respondsToSelector:@selector(dataManager:didUploadImageForNode:)]) {
                                                [self.delegate dataManager:self didUploadImageForNode:node];
                                            }
        
                                        }
                               startImmediately:YES
    ];
}


#pragma mark - Updating/Creating Nodes

- (Node*) createNode
{
    NSAssert(self.useForTemporaryObjects, @"useForTemporaryObjects must be switched on if createNode is used");
    
    __block Node* newNode = nil;
    
    // create temporary context just for the new node
    [self.temporaryMOC performBlockAndWait:^{
        newNode = [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:self.temporaryMOC];
    }];
    
    return newNode;
}

- (void)fetchTotalNodeCount
{
    //
    // request total node counts
    //
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes"
                                             apiKey:[self apiKey]
                                         parameters:@{@"per_page":@1}
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:fetchTotalNodeCountFailedWithError:)]) {
                                                      [self.delegate dataManager:self fetchTotalNodeCountFailedWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                NSDictionary *meta  = JSON[@"meta"];
                                                if ([meta isKindOfClass:[NSDictionary class]]) self.totalNodeCount = meta[@"item_count_total"];
                                                
                                                [self notifyDelegateMarkedNodeCount];
                                            }
                                   startImmediately:YES
     ];
    
    //
    // request unknown node count
    //
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes"
                                             apiKey:[self apiKey]
                                         parameters:@{@"per_page":@1, @"wheelchair":@"unknown"}
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:fetchNodeCountFailedWithError:)]) {
                                                      [self.delegate dataManager:self fetchTotalNodeCountFailedWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                NSDictionary *meta  = JSON[@"meta"];
                                                if ([meta isKindOfClass:[NSDictionary class]]) self.unknownNodeCount = meta[@"item_count_total"];
                                                
                                                [self notifyDelegateMarkedNodeCount];
                                            }
                                   startImmediately:YES
     ];

}

-(void)notifyDelegateMarkedNodeCount
{
    if (self.totalNodeCount && self.unknownNodeCount) {
        NSNumber *nodeCount = [NSNumber numberWithDouble:[self.totalNodeCount doubleValue] - [self.unknownNodeCount doubleValue]];
        if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveTotalNodeCount:)]) {
            [self.delegate dataManager:self didReceiveTotalNodeCount:nodeCount];
        } else if ([self.delegate respondsToSelector:@selector(dataManager:fetchNodeCountFailedWithError:)]) {
            [self.delegate dataManager:self fetchTotalNodeCountFailedWithError:[NSError errorWithDomain:WMDataManagerErrorDomain code:WMDataManagerInvalidRemoteDataError userInfo:nil]];
        }
    }
}


#pragma mark - Expose Data

- (NSArray *)categories
{
    NSManagedObjectContext *context = self.useForTemporaryObjects ? self.temporaryMOC : self.mainMOC;
    NSArray* categories = [self managedObjectContext:context fetchObjectsOfEntity:@"Category" withPredicate:nil];
    
    return [categories sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        Category *c1 = (Category*)a;
        Category *c2 = (Category*)b;
        return [c1.localized_name localizedCaseInsensitiveCompare:c2.localized_name];
    }];
}

- (NSArray *)nodeTypes
{
    NSManagedObjectContext *context = self.useForTemporaryObjects ? self.temporaryMOC : self.mainMOC;
    NSArray* nodeTypes = [self managedObjectContext:context fetchObjectsOfEntity:@"NodeType" withPredicate:nil];
    
    return [nodeTypes sortedArrayUsingComparator:^NSComparisonResult(NodeType *obj1, NodeType *obj2) {
        return [obj1.localized_name localizedCaseInsensitiveCompare:obj2.localized_name];
    }];
}


#pragma mark - Core Data Stack

/*
 Returns a single instance of a managed object context.
 If the context doesn't already exist, it is created with the preset
 database name and bound to a SQLite persistent store.
 */
- (NSManagedObjectContext*) mainMOC
{
    static NSManagedObjectContext *_mainMOC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
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
            
            // create context
            NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [moc performBlockAndWait:^{
                // assign coordinator to context
                [moc setPersistentStoreCoordinator:persistentStoreCoordinator];
            }];
            
            _mainMOC = moc;
        }
    });
    
    return _mainMOC;
}

- (NSManagedObjectContext*) backgroundMOC
{
    static NSManagedObjectContext *backgroundMOC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [backgroundMOC performBlockAndWait:^{
            backgroundMOC.parentContext = self.mainMOC;
        }];
    });
    return backgroundMOC;
}

- (NSManagedObjectContext *) temporaryMOC
{
    if (!_temporaryMOC) {
        _temporaryMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_temporaryMOC performBlock:^{
            _temporaryMOC.parentContext = self.mainMOC;
        }];
    }
    return _temporaryMOC;
}
                  
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    abort();
}


#pragma mark - Core Data Utility Methods

- (NSArray*) managedObjectContext:(NSManagedObjectContext*)moc fetchObjectsOfEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    __block NSArray *results = nil;
    [moc performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        if (predicate) [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        results = [moc executeFetchRequest:fetchRequest error:&error];
        NSAssert(results, error.localizedDescription);
    }];
    return results;
}

- (NSString*) eTagForEntity:(NSString*)entityName
{
    NSDictionary *metaData = [self.mainMOC.persistentStoreCoordinator metadataForPersistentStore:self.persistentStore];
    NSDictionary *eTags = metaData[@"eTags"];
    return eTags[entityName];
}

- (void) setETag:(NSString*)eTag forEntity:(NSString*)entityName
{
    NSParameterAssert(entityName);
    
    [self.mainMOC performBlock:^{
        
        // get meta data from persistent store
        NSMutableDictionary *metaData = [[self.mainMOC.persistentStoreCoordinator metadataForPersistentStore:self.persistentStore] mutableCopy];
        
        // create eTags dictionary if necessary
        NSMutableDictionary *eTags = [[metaData objectForKey:@"eTags"] mutableCopy] ?: [NSMutableDictionary dictionary];
        
        // use entity name as key of eTag
        if (eTag) {
            eTags[entityName] = eTag;
            
        } else {
            // remove key if eTag is nil
            [eTags removeObjectForKey:entityName];
        }
        
        // save new eTags dictionary in meta data
        [metaData setObject:eTags forKey:@"eTags"];
        
        // save altered meta data to persistent store
        [self.mainMOC.persistentStoreCoordinator setMetadata:metaData forPersistentStore:self.persistentStore];
        
        NSError *error = nil;
        if (![self.mainMOC save:&error]) {
            [self logValidationError:error];
        } else {
            if (WMLogDataManager) NSLog(@"Context saved");
        }
    }];
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




