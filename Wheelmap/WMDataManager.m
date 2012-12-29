//
//  WMDataManager.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDataManager.h"
#import "WMWheelmapAPI.h"
#import "WMKeychainWrapper.h"
#import "Asset.h"
#import "NodeType.h"
#import "Node.h"
#import "Photo.h"
#import "Image.h"


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
// TODO: use a regular queue to enqueue both http and zip operations when syncing

@interface WMDataManager()
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStore *persistentStore;
@property (nonatomic, readonly) WMKeychainWrapper *keychainWrapper;
@end


@implementation WMDataManager
{
    NSMutableArray* syncErrors;
    NSString *appApiKey;
}

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
    // start sync process whenever the app becomes active, e.g. on
    // startup and when it moves to foreground
    [self syncResources];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                                               data:nil
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
    
    [[WMWheelmapAPI sharedInstance] requestResource:query ? @"nodes/search" : @"nodes"
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                               data:nil
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
                                               data:nil
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
    // parse result and add it to managed object context
    NSError *error = nil;
    NSArray *parsedNodes = [self parseDataObject:nodes entityName:@"Node" error:&error];
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(dataManager:fetchNodesFailedWithError:)]) {
            [self.delegate dataManager:self fetchNodesFailedWithError:error];
        }
    } else if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveNodes:)]) {
        [self.delegate dataManager:self didReceiveNodes:parsedNodes];
    }
}


#pragma mark - Put/Post a node

-(void)putWheelChairStatusForNode:(Node *)node
{
    NSLog(@"[WMDataManager] put wheelchair status %@", node.wheelchair);
    NSString* resource = [NSString stringWithFormat:@"nodes/%@/update_wheelchair", node.id];
    
    NSDictionary* parameters = @{@"wheelchair":node.wheelchair};
    [[WMWheelmapAPI sharedInstance] requestResource:resource
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                               data:nil
                                             method:@"PUT"
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:failedPuttingWheelChairStatusWithError:)]) {
                                                      [self.delegate dataManager:self failedPuttingWheelChairStatusWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didFinishPuttingWheelChairStatusWithMsg:)])
                                                    [self.delegate dataManager:self didFinishPuttingWheelChairStatusWithMsg:JSON[@"message"]];
                                            }
                                   startImmediately:YES
     ];

    
}

-(void)putNode:(Node *)node
{
    NSLog(@"[WMDataManager] put a node %@", node);
    NSString* resource = [NSString stringWithFormat:@"nodes/%@/", node.id];
    
    NSDictionary* parameters = [self getParamDictFromNode:node];
    
    [[WMWheelmapAPI sharedInstance] requestResource:resource
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                               data:nil
                                             method:@"PUT"
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:failedPuttingNodeWithError:)]) {
                                                      [self.delegate dataManager:self failedPuttingNodeWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didFinishPuttingNodeWithMsg:)])
                                                    [self.delegate dataManager:self didFinishPuttingNodeWithMsg:JSON[@"message"]];
                                            }
                                   startImmediately:YES
     ];

    
}

-(void)postNode:(Node *)node
{
    NSLog(@"[WMDataManager] post a node %@", node);
    NSString* resource = [NSString stringWithFormat:@"nodes"];
    
    NSDictionary* parameters = [self getParamDictFromNode:node];
    
    [[WMWheelmapAPI sharedInstance] requestResource:resource
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                               data:nil
                                             method:@"POST"
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:failedPostingNodeWithError:)]) {
                                                      [self.delegate dataManager:self failedPostingNodeWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didFinishPostingNodeWithMsg:)])
                                                    [self.delegate dataManager:self didFinishPostingNodeWithMsg:JSON[@"message"]];
                                            }
                                   startImmediately:YES
     ];
    
}

-(NSDictionary*)getParamDictFromNode:(Node*)node
{
    NSMutableDictionary* outputDict = [[NSMutableDictionary alloc] init];
    if (node.name)
        [outputDict setObject:node.name forKey:@"name"];
    /*
    NSMutableDictionary* parameters = @{@"name":node.name, @"type":node.node_type.id,
    @"lat":node.lat, @"lon":node.lon};
    @"wheelchair":node.wheelchair,
    @"wheelchair_description":node.wheelchair_description, @"street":node.street,
    @"housenumber":node.housenumber, @"city":node.city, @"postcode":node.postcode,
    @"website":node.website, @"phone":node.phone};
    */
    
    return outputDict;
    
}

#pragma mark - Sync Resources

// use static variables to make sure there's only one sync running at a time
// across all instances of WMDatamanager
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
    syncErrors = nil;
    
    // check if cached assets are available on disk (could have been purged by the system)
    [self.nodeTypes enumerateObjectsUsingBlock:^(NodeType *nodeType, NSUInteger idx, BOOL *stop) {
        if (nodeType.iconPath && ![[NSFileManager defaultManager] fileExistsAtPath:nodeType.iconPath]) {
            if(WMLogDataManager) NSLog(@"... cached icon not found: %@", nodeType.iconPath);
            
            // if any file is missing, reset eTag and modified date to force reload of assets
            [self setETag:nil forEntity:@"Asset"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'icons'"];
            Asset *icon = [[self fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
            icon.modified_at = [NSDate dateWithTimeIntervalSince1970:0];
            
            *stop = YES;
        }
    }];
    
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
    
    // check if we should set eTag
    NSString* eTag;
    if (localeChanged) {
        eTag = nil;
    } else {
        eTag = [self eTagForEntity:@"Category"];
    }
    
    NSOperation *categoriesOperation = [[WMWheelmapAPI sharedInstance] requestResource:@"categories"
                                      apiKey:[self apiKey]
                                  parameters:@{@"locale" :[[NSLocale preferredLanguages] objectAtIndex:0]}
                                        eTag:eTag
                                        data:nil
                                      method:nil
                                       error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (WMLogDataManager) NSLog(@"... error loading categories");
                                               [self syncOperationFailedWithError:error];
                                           });
                                       }
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                         NSUInteger code = response.statusCode;
                                         if (WMLogDataManager) NSLog(@"category sync response status %i", code);
                                         NSString *eTag = [response allHeaderFields][@"ETag"];
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self receivedCategories:JSON[@"categories"] withETag:eTag];
                                         });
                                     }
                            startImmediately:NO
         ];

    // create node types request operation
    if (localeChanged) {
        eTag = nil;
    } else {
        eTag = [self eTagForEntity:@"NodeType"];
    }
    NSOperation *nodeTypesOperation = [[WMWheelmapAPI sharedInstance] requestResource:@"node_types"
                                     apiKey:[self apiKey]
                                 parameters:@{@"locale" :[[NSLocale preferredLanguages] objectAtIndex:0]}
                                       eTag:eTag
                                       data:nil
                                     method:nil
                                      error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (WMLogDataManager) NSLog(@"... error loading node types");
                                              [self syncOperationFailedWithError:error];
                                          });
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
                                                    apiKey:[self apiKey]
                                                parameters:nil
                                                      eTag:[self eTagForEntity:@"Asset"]
                                                      data:nil
                                                    method:nil
                                                     error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             if (WMLogDataManager) NSLog(@"... error loading assets");
                                                             [self syncOperationFailedWithError:error];
                                                             assetDownloadInProgress = NO;
                                                         });
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

- (void) syncOperationFailedWithError:(NSError*)error
{
    if (!syncErrors) syncErrors = [NSMutableArray array];
    [syncErrors addObject:error];
}

- (void) receivedCategories:(NSArray*)categories withETag:(NSString*) eTag
{
    BOOL dataIsUpdated = ![eTag isEqual:[self eTagForEntity:@"Category"]];
    if (WMLogDataManager) NSLog(@"... received %i categories %@", [categories count], dataIsUpdated?@"from cache":@"");
    
    if (dataIsUpdated && categories) {
        NSError *error = nil;
        [self parseDataObject:categories entityName:@"Category" error:&error];
        if (error) {
            [self syncOperationFailedWithError:error];
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
            [self syncOperationFailedWithError:error];
        } else {
            [self setETag:eTag forEntity:@"NodeType"];
        }
    }
}

- (void) receivedAssets:(NSArray*)assets withETag:(NSString*) eTag
{
    if (WMLogDataManager) NSLog(@"... received %i assets", [assets count]);
        
    // if assets are available and eTag has not changed
    if (assets && ![eTag isEqual:[self eTagForEntity:@"Asset"]]) {
       
        // store old icon modified date
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'icons'"];
        Asset *icon = [[self fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
        NSDate *oldLastModified = icon.modified_at;
        
        // parse data
        NSError *error = nil;
        [self parseDataObject:assets entityName:@"Asset" error:&error];
        if (error) {
            [self syncOperationFailedWithError:error];
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
                                                                            [self syncOperationFailedWithError:error];
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
    if (![SSZipArchive unzipFileAtPath:path toDestination:destinationPath overwrite:YES password:nil error:&error delegate:self]) {
        
        if (WMLogDataManager) NSLog(@"... unzipping failed");
        
        [self syncOperationFailedWithError:error];
        assetDownloadInProgress = NO;
        [self finishSync];
        
    } else {
        if (WMLogDataManager) NSLog(@"... unzipping successful");
    }
    
    // NOTE: any files in the destination dir that are not used by the new data will
    // remain on disk. however, since this is in the caches dir, if this dir gets too big,
    // it will eventually be cleaned up by the system. the app should then reload all assets.
}

- (void)zipArchiveDidUnzipFile:(NSString *)destinationPath
{
    NSString *filename = [destinationPath lastPathComponent];
    if (WMLogDataManager) NSLog(@"...... unzipped %@", filename);
    [self.nodeTypes enumerateObjectsUsingBlock:^(NodeType *nodeType, NSUInteger idx, BOOL *stop) {
        if ([nodeType.icon isEqual:filename]) {
            if (WMLogDataManager) NSLog(@"......... set iconPath for type %@", nodeType.identifier);
            nodeType.iconPath = destinationPath;
            // multiple node types might use the same icon, so we don't break this loop here
        }
    }];
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    if (WMLogDataManager) NSLog(@"... did unzip file");
    
    // delete downloaded zip file from tmp folder
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        if (WMLogDataManager) NSLog(@"... can't delete temp file %@", path);
        [self syncOperationFailedWithError:error];
    }
    
    // log icons missing from the archive
    if (WMLogDataManager) {
        [self.nodeTypes enumerateObjectsUsingBlock:^(NodeType *nodeType, NSUInteger idx, BOOL *stop) {
            if (!nodeType.iconPath) {
                NSLog(@"... icon %@ not found for type %@", nodeType.icon, nodeType.identifier);
            }
        }];
    }
       
    assetDownloadInProgress = NO;
    [self finishSync];
}

- (void) finishSync
{
    if (!syncInProgress && !assetDownloadInProgress) {
        
        if (syncErrors) {
            if (WMLogDataManager) NSLog(@"... finished sync and asset download with %i errors", [syncErrors count]);
            if ([self.delegate respondsToSelector:@selector(didFinishSyncingResourcesWithErrors:)]) {
                [self.delegate dataManager:self didFinishSyncingResourcesWithErrors:syncErrors];
            }
        } else {
            if (WMLogDataManager) NSLog(@"... finished sync and asset download");
            if ([self.delegate respondsToSelector:@selector(dataManagerDidFinishSyncingResources:)]) {
                [self.delegate dataManagerDidFinishSyncingResources:self];
            }
        }
    }
}

#pragma mark - Fetching Photo URLs of a Node
- (void) fetchPhotoURLsOfNode:(Node*)node
{
    [[WMWheelmapAPI sharedInstance] requestResource:[NSString stringWithFormat:@"nodes/%@/photos", node.id]
                                             apiKey:[self apiKey]
                                         parameters:nil
                                               eTag:nil
                                               data:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:failedFetchingPhotoURLs:)]) {
                                                      [self.delegate dataManager:self failedFetchingPhotoURLs:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didReceivePhotoURLs:)]) {
                                                    [self.delegate dataManager:self didReceivePhotoURLs:JSON[@"photos"]];
                                                }
                                            }
                                   startImmediately:YES
     ];

}



#pragma mark - Uplaod an image
- (void) uploadImage:(UIImage*)image forNode:(Node*)node
{
    
    [[WMWheelmapAPI sharedInstance] uploadImage:image
                                         nodeID:node.id
                                         apiKey:[self apiKey]
                                          error:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError *error, id JSON) {
                                              if ([self.delegate respondsToSelector:@selector(dataManager:failedPostingImageWithError:)]) {
                                                  [self.delegate dataManager:self failedPostingImageWithError:error];
                                              }
                                        }
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                            if ([self.delegate respondsToSelector:@selector(dataManager:didFinishPostingImageWithMsg:)])
                                                [self.delegate dataManager:self didFinishPostingImageWithMsg:JSON[@"message"]];

        
                                        }
                               startImmediately:YES
    ];
  
}

#pragma mark - Updating/Creating Nodes
- (Node*) updateNode:(Node*)node withPhotoArray:(NSArray*)photoArray;
{
    NSArray* keys = [[[node entity] attributesByName] allKeys];
    NSMutableDictionary* nodeDict = [NSMutableDictionary dictionaryWithDictionary:[node dictionaryWithValuesForKeys:keys]];
    [nodeDict setValue:[NSSet setWithArray:photoArray] forKey:@"photos"];
    
    [self parseDataObject:nodeDict entityName:@"Node" error:nil];

    NSInteger nodeID = [node.id integerValue];
    Node* outputNode = (Node*)[self fetchObjectOfEntity:@"Node" withId:nodeID];
    return outputNode;
    
}

- (Node*) createNode
{
    NSDictionary* nodeDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"id", @"", @"name", @"unknown", @"wheelchair",[NSNumber numberWithDouble:0.00], @"lat", [NSNumber numberWithDouble:0.00], @"lon", nil];
    NSError* error = nil;
    
    NSArray* parsedObjects = [self parseDataObject:[NSArray arrayWithObject:nodeDict] entityName:@"Node" error:&error];
    
    return (Node*)[parsedObjects lastObject];
}

- (void)totalNodeCount
{
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil];
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes"
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:nil
                                               data:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:failedGettingTotalNodeCountWithError:)]) {
                                                      [self.delegate dataManager:self failedGettingTotalNodeCountWithError:error];
                                                  }
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                NSDictionary* meta  = JSON[@"meta"];
                                                if ([self.delegate respondsToSelector:@selector(dataManagerDidFinishGettingTotalNodeCount:)]) {
                                                    [self.delegate dataManagerDidFinishGettingTotalNodeCount:meta[@"item_count_total"]];
                                                }
                                            }
                                   startImmediately:YES
     ];

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
    NSParameterAssert(entityName);
    
    // get meta data from persistent store
    NSMutableDictionary *metaData = [[self.managedObjectContext.persistentStoreCoordinator metadataForPersistentStore:self.persistentStore] mutableCopy];
    
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




