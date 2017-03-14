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
#import "WMCategory.h"
#import "Tile.h"
#import "WMDataParser.h"
#import "WMWheelmapAPI.h"

#define WMSearchRadius 0.004
#define WMCacheSize 10000
#define boundingBoxSize 100.0

// Max number of nodes per page that should be returned for a bounding box request, based on experience.
// The API limits this value currently to 500 (as of 12/29/2012)
// Setting a high limit here is necessary to avoid a nasty problem where newly added nodes
// won't show in results, because nodes are returned with ascending id from the server,
// so the newest nodes come last (that"s why using pages doesn't make any sense here).
// If you experience this problem, try to use smaller bounding boxes before raising this number.
#define WMNodeLimit 1000 // removed as parameter should be configurable in backend

#define UserTermsPrefix @"terms"

// TODO: fix etag check

#define WM_NODE_COUNT_KEY @"WMNodeCount"

#define WM_ALREADY_LAUNCHED_KEY @"WMFirstLaunch"

@interface WMDataManager()
@property (nonatomic, readonly) NSManagedObjectContext *mainMOC;
@property (nonatomic, readonly) NSManagedObjectContext *backgroundMOC;
@property (nonatomic) NSManagedObjectContext *temporaryMOC;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
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
    NSUInteger numRunningOperations;
    
    BOOL assetAvaialbleOnLocalDevice;
}

@synthesize managedObjectModel = __managedObjectModel;

-(id)init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}


- (BOOL)isInternetConnectionAvailable
{
    return [[[WMWheelmapAPI sharedInstance] internetReachable] isReachable];
}

- (Reachability*)internetReachble
{
    return [[WMWheelmapAPI sharedInstance] internetReachable];
}

#pragma mark - Operations Count

- (void) incrementRunningOperations
{
    numRunningOperations++;
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"Incremented number of operations to: %lu", (unsigned long)numRunningOperations);
    
    if (numRunningOperations==1 && [self.delegate respondsToSelector:@selector(dataManagerDidStartOperation:)]) {
        [self.delegate dataManagerDidStartOperation:self];
    }
}

- (void) decrementRunningOperations
{
    numRunningOperations = MAX(0, --numRunningOperations);
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"Decremented number of operations to: %lu", (unsigned long)numRunningOperations);
    
    if (numRunningOperations==0) {
        if ([self.delegate respondsToSelector:@selector(dataManagerDidStopAllOperations:)]) {
            [self.delegate dataManagerDidStopAllOperations:self];
        }
        
        // now that no operations are running, it might be a good time for some housekeeping
        [self cleanUpCache];
    }
}


#pragma mark - Clean Up Cache

- (void) cleanUpCache
{
    // count all nodes that have a tile i.e. that are cached
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Node"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"tile!=nil"];
    NSUInteger totalNodes = [self.mainMOC countForFetchRequest:fetchRequest error:&error];
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_THREE), @"Cleaning up cache. Total number of nodes: %lu", (unsigned long)totalNodes);
    
    if (totalNodes > WMCacheSize) {

        // delete oldest tiles in background
        [self.backgroundMOC performBlock:^{
            
            NSUInteger currentNumberOfNodes = totalNodes;
            
            // get all tiles sorted by creation date
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tile"];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:YES];
            fetchRequest.sortDescriptors = @[sortDescriptor];
            NSError *error = nil;
            NSMutableArray *tiles = [[self.backgroundMOC executeFetchRequest:fetchRequest error:&error] mutableCopy];
            
            if ([tiles count]) {
                
                // delete tiles as long as number of tiles is higher than than max
                while (currentNumberOfNodes > WMCacheSize) {
                    
                    Tile *oldestTile = tiles[0];
                    [tiles removeObjectAtIndex:0];
                    NSUInteger numNodesInTile = [oldestTile.nodes count];
                    
                    // deleting the tile will delete its nodes through cascading rule 
                    [self.backgroundMOC deleteObject:oldestTile];
                    
                    currentNumberOfNodes -= numNodesInTile;
                    
                    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"Deleted tile with %lu nodes", (unsigned long)numNodesInTile);
                }
                
                // save background moc
                NSError *saveTempMocError = nil;
                if (![self.backgroundMOC save:&saveTempMocError]) {
                    // TODO: handle error
                    
                } else {
                    
                    [self.mainMOC performBlock:^{
                        
                        // save parent moc to disk
                        NSError *saveParentMocError = nil;
                        if (![self.mainMOC save:&saveParentMocError]) {
                            // TODO: handle error
                        } else {
                            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"New node count=%lu, saved to main moc", (unsigned long)currentNumberOfNodes);
                        }
                    }];
                }
                
            } else {
                // TODO: handle error
            }
        }];
    }
    
    // TODO: delete nodes with no tile, which may result from requests with search query or filter parameters
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
        appApiKey = K_API_KEY;
    }

    return appApiKey;
}


#pragma mark - Authentication

- (void)authenticateUserWithEmail:(NSString *)email password:(NSString *)password {
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Authenticating user with email:%@ password:%@", email, password);
    
    if (email == nil) {
        email = @"";
    }
    if (password == nil) {
        password = @"";
    }
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"users/authenticate"
                                             apiKey:[self apiKey]
                                         parameters:@{@"email":email, @"password":password}
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([self.delegate respondsToSelector:@selector(dataManager:userAuthenticationFailedWithError:)]) {
                                                      [self.delegate dataManager:self userAuthenticationFailedWithError:error];
                                                  }
                                                  [self decrementRunningOperations];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"req:%@ \nresp:%@", request, response);
                                                [self didReceiveAuthenticationData:JSON[@"user"] forAccount:email];
                                                [self decrementRunningOperations];
                                            }
                                   startImmediately:YES
     ];
    
    [self incrementRunningOperations];
}

- (void) didReceiveAuthenticationData:(NSDictionary*)user forAccount:(NSString*)account
{
    NSString *userToken = user[@"api_key"];
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Did receive user token %@", userToken);
    
    if (userToken) {
        
        // save token to keychain
        BOOL saveSuccess = [self.keychainWrapper saveToken:userToken forAccount:account];
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Saved user token to keychain with %@", saveSuccess ? @"success" : @"error");
        
        if (saveSuccess) {
            // now that we have saved a token, we can delete legacy keychain data
            [self.keychainWrapper deleteLegacyAccountData];
            // save last login email into the userdefault (this should be improved..)
            NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:[self currentUserName] forKey:@"WheelmapLastUserName"];
            
            BOOL termsAccepted = ([user[@"terms_accepted"] boolValue] & [user[@"privacy_accepted"] boolValue]);
            if (termsAccepted) {
                [self userDidAcceptTerms];  // save to local device
            } else {
                // remove terms key if necessary
                if ([[NSUserDefaults standardUserDefaults] objectForKey:[self currentUserTermsKey]])
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self currentUserTermsKey]];
            }
            
        }
        
        if ([self.delegate respondsToSelector:@selector(dataManagerDidAuthenticateUser:)]) {
            [self.delegate dataManagerDidAuthenticateUser:self];
        }
        
    } else if ([self.delegate respondsToSelector:@selector(dataManager:userAuthenticationFailedWithError:)]) {
        NSError *error = [NSError errorWithDomain:WMDataManagerErrorDomain code:WMDataManagerInvalidUserKeyError userInfo:nil];
        [self.delegate dataManager:self userAuthenticationFailedWithError:error];
    }
}

- (void)updateTermsAccepted:(BOOL)accepted
{
    NSString *value = accepted ? @"true" : @"false";
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"ACCEPTED VALUE = %@", value);
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"user/accept_terms"
                                             apiKey:[self apiKey]
                                         parameters:@{@"terms_accepted": value, @"privacy_accepted": value}
                                               eTag:nil
                                             method:@"POST"
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                if ([self.delegate respondsToSelector:@selector(dataManager:updateTermsAcceptedFailedWithError:)]) {
                                                    [self.delegate dataManager:self updateTermsAcceptedFailedWithError:error];
                                                }
                                                [self decrementRunningOperations];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                id user = JSON[@"user"];
                                                id termsAccepted = user[@"terms_accepted"];
                                                id privacyAccepted = user[@"privacy_accepted"];
                                                BOOL termsAcc = [termsAccepted boolValue] && [privacyAccepted boolValue];
                                                if ([self.delegate respondsToSelector:@selector(dataManagerDidUpdateTermsAccepted:withValue:)]) {
                                                    [self.delegate dataManagerDidUpdateTermsAccepted:self withValue:termsAcc];
                                                }
                                                [self decrementRunningOperations];
                                            }
                                   startImmediately:YES
     ];
    
    [self incrementRunningOperations];

}

- (BOOL)userIsAuthenticated {
    NSString *userToken = [self.keychainWrapper tokenForAccount:nil];
    return ([userToken length] > 0 && [self areUserTermsAccepted]);
}

- (void)removeUserAuthentication {
    BOOL deleteSuccess = [self.keychainWrapper deleteTokenForAccount:nil];
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Removed user token from keychain with %@", deleteSuccess ? @"success" : @"error");
}

- (NSDictionary *) legacyUserCredentials
{
    return [self.keychainWrapper legacyAccountData];
}

- (NSString*) currentUserName
{
    return self.keychainWrapper.userAccount;
}

- (NSString *)currentUserTermsKey {
    return [NSString stringWithFormat:@"%@%@",UserTermsPrefix, [self currentUserName]];
}

- (void)userDidAcceptTerms {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"YES" forKey:[self currentUserTermsKey]];
    [defaults synchronize];
}

- (void)userDidNotAcceptTerms {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:[self currentUserTermsKey]];
    [defaults synchronize];
}

- (BOOL)areUserTermsAccepted {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:[self currentUserTermsKey]] != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isFirstLaunch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ![defaults boolForKey:WM_ALREADY_LAUNCHED_KEY];
}

- (void)firstLaunchOccurred {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:WM_ALREADY_LAUNCHED_KEY];
    [defaults synchronize];
}

#pragma mark - Fetch Nodes

- (void) fetchNodesForMap:(MKMapView *)mapView query:(NSString *)query {

	CLLocationCoordinate2D northEastCoordinates = [mapView convertPoint:CGPointMake(mapView.frameWidth, 0) toCoordinateFromView:mapView];
	CLLocationCoordinate2D southWestCoordinates = [mapView convertPoint:CGPointMake(0, mapView.frameHeight) toCoordinateFromView:mapView];

	return [self fetchNodesForSouthWestCoordinate:southWestCoordinates northEastCoordinate:northEastCoordinates query:query];
}

- (void)fetchNodesForSouthWestCoordinate:(CLLocationCoordinate2D)southWestCoordinates northEastCoordinate:(CLLocationCoordinate2D)northEastCoordinates query:(NSString *)query {

	CLLocation *northEastLocation = [[CLLocation alloc] initWithLatitude:northEastCoordinates.latitude longitude:northEastCoordinates.longitude];
	CLLocation *southWestLocation = [[CLLocation alloc] initWithLatitude:southWestCoordinates.latitude longitude:southWestCoordinates.longitude];
	return [self fetchNodesForSouthWestLocation:southWestLocation northEastLocation:northEastLocation query:query];
}


- (void)fetchNodesForSouthWestLocation:(CLLocation *)southWestLocation northEastLocation:(CLLocation *)northEastLocation query:(NSString *)query {
	// Fetch all nodes for the specified area + space around. This will be done with 5 tiles. One center tile and a left, top, right and bottom tile.

	CLLocation *southEastLocation = [[CLLocation alloc] initWithLatitude:southWestLocation.coordinate.latitude longitude:northEastLocation.coordinate.longitude];
	CLLocation *northWestLocation = [[CLLocation alloc] initWithLatitude:northEastLocation.coordinate.latitude longitude:southWestLocation.coordinate.longitude];

	CGFloat originalAreaLongitudeDistance = [northEastLocation distanceFromLocation:northWestLocation];
	CGFloat tileHorizontalPaddingDistance = originalAreaLongitudeDistance / 5;
	CGFloat originalAreaLatitudeDistance = [southWestLocation distanceFromLocation:northWestLocation];
	CGFloat tileVerticalPaddingDistance = originalAreaLatitudeDistance / 5;
	if (tileVerticalPaddingDistance > tileHorizontalPaddingDistance) {
		tileVerticalPaddingDistance = tileHorizontalPaddingDistance;
	}

	// fetch center tile
	CLLocationCoordinate2D centerTileNETCoordinate = [WMHelper locationCoordinate:northEastLocation.coordinate WithLatitudeOffset:tileVerticalPaddingDistance longitudeOffset:-tileHorizontalPaddingDistance];
	CLLocationCoordinate2D centerTileSWCoordinate = [WMHelper locationCoordinate:southWestLocation.coordinate WithLatitudeOffset:-tileVerticalPaddingDistance longitudeOffset:tileHorizontalPaddingDistance];

	[self fetchNodesTileForSouthWest:centerTileSWCoordinate northEast:centerTileNETCoordinate query:query];

	// fetch left tile
	CLLocationCoordinate2D leftTileNETCoordinate = [WMHelper locationCoordinate:northWestLocation.coordinate WithLatitudeOffset:tileVerticalPaddingDistance longitudeOffset:tileHorizontalPaddingDistance];
	CLLocationCoordinate2D leftTileSWCoordinate = [WMHelper locationCoordinate:southWestLocation.coordinate WithLatitudeOffset:-tileVerticalPaddingDistance longitudeOffset:-tileHorizontalPaddingDistance];

	[self fetchNodesTileForSouthWest:leftTileSWCoordinate northEast:leftTileNETCoordinate query:query];

	// fetch top tile
	CLLocationCoordinate2D topTileNETCoordinate = [WMHelper locationCoordinate:northEastLocation.coordinate WithLatitudeOffset:-tileVerticalPaddingDistance longitudeOffset:tileHorizontalPaddingDistance];
	CLLocationCoordinate2D topTileSWCoordinate = [WMHelper locationCoordinate:northWestLocation.coordinate WithLatitudeOffset:tileVerticalPaddingDistance longitudeOffset:-tileHorizontalPaddingDistance];

	[self fetchNodesTileForSouthWest:topTileSWCoordinate northEast:topTileNETCoordinate query:query];

	// fetch right tile
	CLLocationCoordinate2D rightTileNETCoordinate = [WMHelper locationCoordinate:northEastLocation.coordinate WithLatitudeOffset:tileVerticalPaddingDistance longitudeOffset:tileHorizontalPaddingDistance];
	CLLocationCoordinate2D rightTileSWCoordinate = [WMHelper locationCoordinate:southEastLocation.coordinate WithLatitudeOffset:-tileVerticalPaddingDistance longitudeOffset:-tileHorizontalPaddingDistance];

	[self fetchNodesTileForSouthWest:rightTileSWCoordinate northEast:rightTileNETCoordinate query:query];

	// fetch bottom tile
	CLLocationCoordinate2D bottomTileNETCoordinate = [WMHelper locationCoordinate:southEastLocation.coordinate WithLatitudeOffset:-tileVerticalPaddingDistance longitudeOffset:tileHorizontalPaddingDistance];
	CLLocationCoordinate2D bottomTileSWCoordinate = [WMHelper locationCoordinate:southWestLocation.coordinate WithLatitudeOffset:tileVerticalPaddingDistance longitudeOffset:-tileHorizontalPaddingDistance];

	[self fetchNodesTileForSouthWest:bottomTileSWCoordinate northEast:bottomTileNETCoordinate query:query];
}


- (void)fetchNodesTileForSouthWest:(CLLocationCoordinate2D)southWest northEast:(CLLocationCoordinate2D)northEast query:(NSString *)query {

	DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @".. fetch nodes tile between SW: %.4f,%.4f; NE: %.4f,%.4f", southWest.latitude, southWest.longitude, northEast.latitude, northEast.longitude);

	// for search call fetch directly, toherwise make head request first
	if (query) {
		[self fetchRemoteNodesBetweenSouthwest:southWest northeast:northEast query:query];
	} else {
		[self fetchRemoteNodesHeadBetweenSouthwest:southWest northeast:northEast];
	}
}

- (Tile*) managedObjectContext:(NSManagedObjectContext*)moc tileForLocation:(CLLocationCoordinate2D)coordinates
{
    // round coordinates to tile bounds
    NSInteger swLat = coordinates.latitude * 100.0;
    NSInteger swLon = coordinates.longitude * 100.0;

    Tile *tile = [self managedObjectContext:moc cachedTileForSwLat:swLat swLon:swLon];
    
    if  (!tile) tile = [self managedObjectContext:moc createTileForSwLat:swLat swLon:swLon];

    return tile;
}

- (Tile*) managedObjectContext:(NSManagedObjectContext*)moc cachedTileForLocation:(CLLocationCoordinate2D)coordinates
{
    // round coordinates to tile bounds
    NSInteger swLat = coordinates.latitude * 100.0;
    NSInteger swLon = coordinates.longitude * 100.0;
    
    return [self managedObjectContext:moc cachedTileForSwLat:swLat swLon:swLon];
}

- (Tile*)managedObjectContext:(NSManagedObjectContext*)moc cachedTileForSwLat:(NSInteger)swLat swLon:(NSInteger)swLon {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"swLat==%i && swLon==%i", swLat, swLon];
    NSArray *results = [self managedObjectContext:moc fetchObjectsOfEntity:@"Tile" withPredicate:predicate];
    
    if (K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_FOUR) {
        Tile* tile = [results lastObject];
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_FOUR), @".........fetched existing tile: %@ %lu", tile?[NSString stringWithFormat:@"%@/%@",tile.swLat,tile.swLon]:nil, (unsigned long)(tile?tile.nodes.count:0));
        if (tile && tile.nodes.count > 0) {
            for (Node *node in tile.nodes) {
                DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_FOUR), @"Node lat %@ lon %@", node.lat, node.lon);
                break;
            }
        }
    }
    
    return [results lastObject];
}

- (Tile*)managedObjectContext:(NSManagedObjectContext*)moc createTileForSwLat:(NSInteger)swLat swLon:(NSInteger)swLon {
    __block Tile *newTile = nil;
    [moc performBlockAndWait:^{
        newTile = [NSEntityDescription insertNewObjectForEntityForName:@"Tile" inManagedObjectContext:moc];
        newTile.swLat = @(swLat);
        newTile.swLon = @(swLon);
    }];
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_THREE), @"......created new tile: %@/%@", newTile.swLat, newTile.swLon);
    
    return newTile;
}

- (void)fetchRemoteNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest northeast:(CLLocationCoordinate2D)northeast query:(NSString *)query
{
    
    if (self.syncInProgress) {
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"Sync in progress, do not fetch");
        return;
    }
    
    if (![self isInternetConnectionAvailable]) {
        return;
    }
        
    NSString *southwestLong = [self roundDown:southwest.longitude];
    NSString * southwestLat = [self roundDown:southwest.latitude];
    NSString * northeastLong = [self roundUp:northeast.longitude];
    NSString * northeastLat = [self roundUp:northeast.latitude];
    
    NSString *eTagID = [NSString stringWithFormat:@"%@,%@,%@,%@",
                        southwestLong,
                        southwestLat,
                        northeastLong,
                        northeastLat];
    
    NSString *coords = [NSString stringWithFormat:@"%f,%f,%f,%f",
                        southwest.longitude,
                        southwest.latitude,
                        northeast.longitude,
                        northeast.latitude];
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Fetching rounded coordinates: %@", coords);
	DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Original coordinates: %@", [NSString stringWithFormat:@"%f,%f,%f,%f",
                                        southwest.longitude,
                                        southwest.latitude,
                                        northeast.longitude,
                                        northeast.latitude]);

    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[@"bbox"] = coords;
    parameters[@"per_page"] = @WMNodeLimit;
    if (query) parameters[@"q"] = query;
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"fetching nodes in bbox %@", coords);
    
    [[WMWheelmapAPI sharedInstance] requestResource:query ? @"nodes/search" : @"nodes"
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:[self eTagForEntity:eTagID]
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  [self fetchNodesFailedWithError:error];
                                                  [self decrementRunningOperations];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                NSString *eTag = [response allHeaderFields][@"ETag"];

                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:eTagID]];

                                                if (eTagChanged) {
                                                    
                                                    if (!query) {
                                                        [self setETag:eTag forEntity:eTagID];
                                                    }
                                                    [self didReceiveNodes:JSON[@"nodes"] fromQuery:query];
                                                } else {
                                                    [self decrementRunningOperations];
                                                }
                                                
                                            }
                                   startImmediately:YES
     ];
    
    [self incrementRunningOperations];
}

// HEAD request to check etag header
- (void)fetchRemoteNodesHeadBetweenSouthwest:(CLLocationCoordinate2D)southwest northeast:(CLLocationCoordinate2D)northeast
{
    
    if (![self isInternetConnectionAvailable]) {
        return;
    }
    
    NSString *southwestLong = [self roundDown:southwest.longitude];
    NSString * southwestLat = [self roundDown:southwest.latitude];
    NSString * northeastLong = [self roundUp:northeast.longitude];
    NSString * northeastLat = [self roundUp:northeast.latitude];
    
    NSString *eTagID = [NSString stringWithFormat:@"%@,%@,%@,%@",
                        southwestLong,
                        southwestLat,
                        northeastLong,
                        northeastLat];
    
    NSString *coords = [NSString stringWithFormat:@"%f,%f,%f,%f",
                        southwest.longitude,
                        southwest.latitude,
                        northeast.longitude,
                        northeast.latitude];
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Fetching rounded coordinates: %@", coords);
	DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Original coordinates: %@", [NSString stringWithFormat:@"%f,%f,%f,%f",
                                            southwest.longitude,
                                            southwest.latitude,
                                            northeast.longitude,
                                            northeast.latitude]);
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[@"bbox"] = coords;
    parameters[@"per_page"] = @WMNodeLimit;
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"fetching nodes head in bbox %@", coords);
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes"
                                             apiKey:[self apiKey]
                                         parameters:parameters
                                               eTag:[self eTagForEntity:eTagID]
                                             method:@"HEAD"
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                NSString *eTag = [response allHeaderFields][@"ETag"];
                                                
                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:eTagID]];
                                                
                                                if (eTagChanged) {
                                                    [self fetchRemoteNodesBetweenSouthwest:southwest northeast:northeast query:nil];
                                                }
                                                
                                            }
                                   startImmediately:YES
     ];
    
}


- (NSString *)roundUp:(double)input {
    NSNumberFormatter *format = [[NSNumberFormatter alloc]init];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    [format setRoundingMode:NSNumberFormatterRoundUp];
    [format setMaximumFractionDigits:4];
    [format setMinimumFractionDigits:4];
    return [format stringFromNumber:[NSNumber numberWithDouble:input]];
}

- (NSString *)roundDown:(double)input {
    NSNumberFormatter *format = [[NSNumberFormatter alloc]init];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    [format setRoundingMode:NSNumberFormatterRoundDown];
    [format setMaximumFractionDigits:4];
    [format setMinimumFractionDigits:4];
    return [format stringFromNumber:[NSNumber numberWithDouble:input]];
}

- (void)fetchNodesWithQuery:(NSString*)query
{
    
    if (query == nil) {
        return;
    }
    
    if (![self isInternetConnectionAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FetchNodesFails", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        
        [alert show];
        return;
    }
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"fetchNodesWithQuery:%@", query);
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes/search"
                                             apiKey:[self apiKey]
                                         parameters: @{@"q":query}
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  [self fetchNodesFailedWithError:error];
                                                  [self decrementRunningOperations];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                [self didReceiveNodes:JSON[@"nodes"] fromQuery:query];
                                            }
                                   startImmediately:YES
     ];
    
    [self incrementRunningOperations];
}

- (void) fetchNodesFailedWithError:(NSError*) error
{
    if ([self.delegate respondsToSelector:@selector(dataManager:fetchNodesFailedWithError:)]) {
        [self.delegate dataManager:self fetchNodesFailedWithError:error];
    }
}

- (void) didReceiveNodes:(NSArray *)nodes fromQuery:(NSString*)query
{
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"received %lu nodes", (unsigned long)[nodes count]);


    [self parseDataObjectInBackground:nodes
               entityName:@"Node"
              postProcess:^(id parsedNodes) {
                  
                  // assign tile to each parsed node if this is not a search result
                  if (!query) {                      
                      [(NSArray*)parsedNodes enumerateObjectsUsingBlock:^(Node* node, NSUInteger idx, BOOL *stop) {
						  // Make sure the object is still valid in the context and update the tile.
						  if ((node == nil) || ([self.backgroundMOC existingObjectWithID:node.objectID error:NULL] == nil)) {
							  CLLocationCoordinate2D location = CLLocationCoordinate2DMake([node.lat doubleValue], [node.lon doubleValue]);
							  Tile *tile = [self managedObjectContext:self.backgroundMOC tileForLocation:location];
							  tile.lastModified = [NSDate date];
							  node.tile = tile;
						  }
                      }];
                  }
              }
                    error:^(NSError *error) {
                        if ([self.delegate respondsToSelector:@selector(dataManager:fetchNodesFailedWithError:)]) {
                            [self.delegate dataManager:self fetchNodesFailedWithError:error];
                        }
                        [self decrementRunningOperations];
                    }
                  success:^(id parsedNodes) {
                      if ((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_FOUR)) {
                          NSError *error = nil;
                          NSUInteger totalNodes = [self.mainMOC countForFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Node"] error:&error];
                           DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_FOUR), @"parsed %lu nodes. Total count is now %lu", (unsigned long)[(NSArray*)parsedNodes count], (unsigned long)totalNodes);
                      } else if ((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE)) {
                         DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"parsed %lu nodes", (unsigned long)[(NSArray*)parsedNodes count]);
                      }
     
                      if ([self.delegate respondsToSelector:@selector(dataManager:didReceiveNodes:)]) {
                          [self.delegate dataManager:self didReceiveNodes:parsedNodes];
                      }
                      
                      [self decrementRunningOperations];
                  }
     ];
}

- (void) parseDataObjectInBackground:(id)object
                          entityName:(NSString*)entityName
                         postProcess:(void (^)(id parsedObject))postProcessBlock
                               error:(void (^)(NSError *error))errorBlock
                             success:(void (^)(id parsedObject))successBlock
{
    // perform parsing on private queue and perform result blocks on current queue
    [self.backgroundMOC performBlock:^{
        
        NSDate *startTime = [NSDate date];
        
        // create parser with temporary context
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"------ PARSING DATA OBJECT IN BACKGROUND ------");
        WMDataParser *parser = [[WMDataParser alloc] initWithManagedObjectContext:self.backgroundMOC];
        
        // parse data
        NSError *parseError = nil;
        id parsedObject = [parser parseDataObject:object entityName:entityName error:&parseError];
        
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_THREE), @"......parsed after %.2f sec", -[startTime timeIntervalSinceNow]);
        
        if (!parsedObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(parseError);
            });
            
        } else {
            
            NSArray *result = (NSArray*)parsedObject;
            
            // execute post process block in background context
            if (postProcessBlock) postProcessBlock(parsedObject);
            
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
                    
                    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_THREE), @"......saved to child moc after %.2f sec", -[startTime timeIntervalSinceNow]);
                    
                    [self.mainMOC performBlock:^{
                        
                        // save parent moc to disk
                        NSError *saveParentMocError = nil;
                        if (![self.mainMOC save:&saveParentMocError]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                errorBlock(saveParentMocError);
                            });
                            
                        } else {
                            
                            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_THREE), @"......saved to main moc after %.2f sec", -[startTime timeIntervalSinceNow]);
                            
                            // fetch result objects from main moc
                            NSMutableArray *resultObjectsInMainMoc = [NSMutableArray arrayWithCapacity:[result count]];
                            [result enumerateObjectsUsingBlock:^(NSManagedObject* obj, NSUInteger idx, BOOL *stop) {
                                [resultObjectsInMainMoc addObject:[self.mainMOC objectWithID:obj.objectID]];
                            }];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                successBlock(resultObjectsInMainMoc);
                                DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_THREE), @"......finished after %.2f sec", -[startTime timeIntervalSinceNow]);
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
    
    if (node.wheelchair == nil) {
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Cannot update wheelchair status to null!");
        return;
    }
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"update wheelchair status to %@", node.wheelchair);
    
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
                                                  [self decrementRunningOperations];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didUpdateWheelchairStatusOfNode:)]) {
                                                    [self.delegate dataManager:self didUpdateWheelchairStatusOfNode:node];
                                                }
                                                [self decrementRunningOperations];
                                            }
                                   startImmediately:YES
     ];
    [self incrementRunningOperations];
}

- (void)updateToiletStateOfNode:(Node *)node {

	if (node.wheelchair_toilet == nil) {
		DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Cannot update toilet state to null!");
		return;
	}

	DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"update toilet status to %@", node.wheelchair_toilet);

	NSDictionary* parameters = @{@"wheelchair_toilet":node.wheelchair_toilet};
	[[WMWheelmapAPI sharedInstance] requestResource:[NSString stringWithFormat:@"nodes/%@/update_toilet", node.id]
											 apiKey:[self apiKey]
										 parameters:parameters
											   eTag:nil
											 method:@"PUT"
											  error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
												  if ([self.delegate respondsToSelector:@selector(dataManager:updateToiletStatusOfNode:failedWithError:)]) {
													  [self.delegate dataManager:self updateToiletStatusOfNode:node failedWithError:error];
												  }
												  [self decrementRunningOperations];
											  }
											success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
												if ([self.delegate respondsToSelector:@selector(dataManager:didUpdateToiletStatusOfNode:)]) {
													[self.delegate dataManager:self didUpdateToiletStatusOfNode:node];
												}
												[self decrementRunningOperations];
											}
								   startImmediately:YES
	 ];
	[self incrementRunningOperations];
}

- (void)updateNode:(Node *)node {
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"update node %@ %@", node.name, node.id);

    // if this is a put
    if (node.id) {

        // validate node
        NSError *validationError = nil;
        if (![node validateForUpdate:&validationError]) {
            if (K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE) [self logValidationError:validationError];
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
		@"wheelchair_toilet" : node.wheelchair_toilet ?: [NSNull null],
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
                                                  [self decrementRunningOperations];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                // save changes to disk if this was a put
                                                if (node.id) {
                                                    [self.mainMOC performBlock:^{
                                                        NSError *saveParentMocError = nil;
                                                        if (![self.mainMOC save:&saveParentMocError]) {
                                                            if (K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE) [self logValidationError:saveParentMocError];
                                                            NSAssert(YES, @"error saving moc after node PUT");
                                                            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"error saving moc after node PUT");
                                                        } else {
                                                            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"POI saved to disk");
                                                        }
                                                    }];
                                                }
                                                
                                                if ([self.delegate respondsToSelector:@selector(dataManager:didUpdateNode:)]) {
                                                    [self.delegate dataManager:self didUpdateNode:node];
                                                }
                                                [self decrementRunningOperations];
                                            }
                                   startImmediately:YES
     ];
    [self incrementRunningOperations];
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
   
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"syncResources");
    if (K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO) {
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... num categories: %lu", (unsigned long)[[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"WMCategory" withPredicate:nil] count]);
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... num node types: %lu", (unsigned long)[[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"NodeType" withPredicate:nil] count]);
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... num assets: %lu", (unsigned long)[[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Asset" withPredicate:nil] count]);
    }
    
    // make sure there's only one sync running at a time
    if (self.syncInProgress) {
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... sync already in progress, skipping");
        return;
    }
    
    nodeTypeSyncInProgress = YES;
    categorySyncInProgress = YES;
    assetSyncInProgress = YES;
    
    syncErrors = nil;
    
    assetAvaialbleOnLocalDevice = YES;
    
    // check cached categories.
    if (!self.categories || self.categories.count == 0) {
        assetAvaialbleOnLocalDevice = NO;
    }
    
    // check if cached assets are available on disk (could have been purged by the system)
    [self.nodeTypes enumerateObjectsUsingBlock:^(NodeType *nodeType, NSUInteger idx, BOOL *stop) {
        if (nodeType.iconPath && ![[NSFileManager defaultManager] fileExistsAtPath:nodeType.iconPath]) {
            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... cached icon not found: %@", nodeType.iconPath);
            
            // if any file is missing, reset eTag and modified date to force reload of assets
            [self setETag:nil forEntity:@"Asset"];
            assetAvaialbleOnLocalDevice = NO;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'icons'"];
            Asset *icon = [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
            icon.modified_at = [NSDate dateWithTimeIntervalSince1970:0];
            
            *stop = YES;
        }
    }];
    
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"RE-SYNC RESOUCES!");
    
    //
    // no asset on local device available and no internet connection -> we can not sync resources.
    if (!assetAvaialbleOnLocalDevice && ![self isInternetConnectionAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"NoResources", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        
        [alert show];
        return;
    }
    
    
    // make string consistent with v1.0 --> syncing resources over backend is a new feature in the version 2.0
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

	// Remove the country part from the string. EG. "-GB" part from "en-GB". THe backend can't handle it otherwise.
	NSString *localeString = [[NSLocale preferredLanguages] objectAtIndex:0];
	if (localeString != nil) {
		NSUInteger separetorLocation = [localeString rangeOfString:@"-"].location;
		if (separetorLocation != NSNotFound) {
			localeString = [localeString substringToIndex:separetorLocation];
		}
	}

    // create categories request operation    
    [[WMWheelmapAPI sharedInstance] requestResource:@"categories"
                                             apiKey:[self apiKey]
                                         parameters:@{@"locale" :localeString}
                                               eTag:localeChanged ? nil : [self eTagForEntity:@"WMCategory"]
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... error loading categories");
                                                  categorySyncInProgress = NO;
                                                  [self syncOperationFailedWithError:error];
                                                  [self finishSync];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                
                                                NSString *eTag = [response allHeaderFields][@"ETag"];
                                                id categories = JSON[@"categories"];
                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:@"WMCategory"]];
                                                DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... received %lu categories, %@", (unsigned long)[categories count], eTagChanged?@"eTag changed":@"eTag is same");
                                                
                                                if (eTagChanged && categories) {

                                                    [self parseDataObjectInBackground:categories
                                                                           entityName:@"WMCategory"
                                                                          postProcess:nil
                                                                                error:^(NSError *error) {
                                                                                    categorySyncInProgress = NO;
                                                                                    [self syncOperationFailedWithError:error];
                                                                                    [self finishSync];
                                                                                }
                                                                              success:^(id parsedObject) {
                                                                                  categorySyncInProgress = NO;
                                                                                  [self setETag:eTag forEntity:@"WMCategory"];
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
                                         parameters:@{@"locale" : localeString}
                                               eTag:localeChanged ? nil : [self eTagForEntity:@"NodeType"]
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... error loading node types");
                                                  nodeTypeSyncInProgress = NO;
                                                  [self syncOperationFailedWithError:error];
                                                  [self finishSync];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                
                                                NSString *eTag = [response allHeaderFields][@"ETag"];
                                                id nodeTypes = JSON[@"node_types"];
                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:@"NodeType"]];
                                                DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... received %lu node types %@", (unsigned long)[nodeTypes count], eTagChanged?@"eTag changed":@"eTag is same");
                                                
                                                if (eTagChanged && nodeTypes) {
                                                    
                                                    [self parseDataObjectInBackground:nodeTypes
                                                                           entityName:@"NodeType"
                                                                          postProcess:nil
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
                                                  DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... error loading assets");
                                                  assetSyncInProgress = NO;
                                                  [self syncOperationFailedWithError:error];
                                                  [self finishSync];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                
                                                NSString *eTag = [response allHeaderFields][@"ETag"];
                                                id assets = JSON[@"assets"];
                                                BOOL eTagChanged = ![eTag isEqual:[self eTagForEntity:@"Asset"]];
                                                DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... received %lu assets %@", (unsigned long)[assets count], eTagChanged?@"eTag changed":@"eTag is same");
                                                
                                                if (eTagChanged && assets) {
                                                    
                                                    // store old icon modified date
                                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like 'icons'"];
                                                    Asset *oldIcon = [[self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"Asset" withPredicate:predicate] lastObject];
                                                    NSDate *oldIconModifiedAt = oldIcon.modified_at;
                                                    
                                                    // parse data
                                                    [self parseDataObjectInBackground:assets
                                                                           entityName:@"Asset"
                                                                          postProcess:nil
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
    
    [self incrementRunningOperations];
}

- (void) downloadFilesForAsset:(Asset*)asset
{
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... download file for asset %@ from %@", asset.name, asset.url);

    // use /tmp dir for archive download
    NSString *path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.zip", asset.name];

    [[WMWheelmapAPI sharedInstance] downloadFile:[NSURL URLWithString:asset.url]
                                          toPath:path
                                           error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"... file download error");
                                               assetSyncInProgress = NO;
                                               [self syncOperationFailedWithError:error];
                                               [self finishSync];
                                           }
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response) {
                                             DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"... download success");
                                             // get path where file should be unzipped
                                             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                             NSString *destinationPath = [paths objectAtIndex:0];
                                             
                                             // init dictionary to save the local paths of unzipped files
                                             iconPaths = [NSMutableDictionary dictionary];
                                             
                                             // unzip file
                                             NSError *error = nil;
                                             if (![SSZipArchive unzipFileAtPath:path toDestination:destinationPath overwrite:YES password:nil error:&error delegate:self]) {
                                                 
                                                 DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"... unzipping failed");
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
			[self.backgroundMOC performBlock:^{

                NSArray *nodeTypes = [self managedObjectContext:self.backgroundMOC fetchObjectsOfEntity:@"NodeType" withPredicate:nil];
                [nodeTypes enumerateObjectsUsingBlock:^(NodeType *nodeType, NSUInteger idx, BOOL *stop) {
                
                    NSString *iconPath = nil;
                    if (nodeType.icon) {
                        iconPath = iconPaths[nodeType.icon];
                        
                    } else if (K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO) {
                        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... no icon set for nodeType %@", nodeType.identifier);
                    }
                    
                    nodeType.iconPath = iconPath;
                        
                    if ((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO) && !iconPath) {
                        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... icon %@ not found for nodeType %@", nodeType.icon, nodeType.identifier);
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
            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... finished sync with %lu errors", (unsigned long)[syncErrors count]);
            if ([self.delegate respondsToSelector:@selector(dataManager:didFinishSyncingResourcesWithErrors:)]) {
                [self.delegate dataManager:self didFinishSyncingResourcesWithErrors:syncErrors];
            }
        } else {
            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... finished sync with no errors");
            
            if (K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE) {
                NSArray *categories = [self managedObjectContext:self.mainMOC  fetchObjectsOfEntity:@"WMCategory" withPredicate:nil];
                NSArray *nodeTypes = [self managedObjectContext:self.mainMOC fetchObjectsOfEntity:@"NodeType" withPredicate:nil];
                DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"counting %lu NodeType, %lu Category", (unsigned long)[categories count], (unsigned long)[nodeTypes count]);
            }
            
            if ([self.delegate respondsToSelector:@selector(dataManagerDidFinishSyncingResources:)]) {
                [self.delegate dataManagerDidFinishSyncingResources:self];
            }
        }
        
        [self decrementRunningOperations];
    }
}


#pragma mark -  ZIP Archive Delegate

- (void)zipArchiveDidUnzipFile:(NSString *)destinationPath
{
    NSString *filename = [destinationPath lastPathComponent];
    [iconPaths setObject:destinationPath forKey:filename];
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_THREE), @"...... unzipped %@", filename);
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"... did unzip archive");
    
    // delete downloaded zip file from tmp folder
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_TWO), @"... can't delete temp file %@", path);
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
                                                  [self decrementRunningOperations];
                                              }
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                [self didReceivePhotos:JSON[@"photos"] forNode:node];
                                                [self decrementRunningOperations];
                                            }
                                   startImmediately:YES
     ];
    
    [self incrementRunningOperations];
}

- (void) didReceivePhotos:(NSArray*)photos forNode:(Node*)node
{
    
    [self parseDataObjectInBackground:photos
               entityName:@"Photo"
              postProcess:nil
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
                                              [self decrementRunningOperations];
                                        }
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                            if ([self.delegate respondsToSelector:@selector(dataManager:didUploadImageForNode:)]) {
                                                [self.delegate dataManager:self didUploadImageForNode:node];
                                            }
                                            [self decrementRunningOperations];
                                        }
                               startImmediately:YES
    ];
    
    [self incrementRunningOperations];
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
    
    if (![self isInternetConnectionAvailable]) {
        DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Fetching node count failed. No internet available.");
        [self.delegate dataManager:self fetchTotalNodeCountFailedWithError:nil];
        return;
    }
    
    //
    // request total node counts
    //
    
    [[WMWheelmapAPI sharedInstance] requestResource:@"nodes"
                                             apiKey:[self apiKey]
                                         parameters:@{@"per_page":@1}
                                               eTag:nil
                                             method:nil
                                              error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                  if ([response statusCode] == 401) {
                                                      [self removeUserAuthentication];
                                                  }
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
                                         parameters:@{@"per_page":@1, @"wheelchair":K_STATE_UNKNOWN}
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

- (void)writeNodeCountToUserDefaults {
    
    if (self.totalNodeCount == nil) {
        return;
    }
    
    NSNumber *nodeCount = [NSNumber numberWithDouble:[self.totalNodeCount doubleValue] - [self.unknownNodeCount doubleValue]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nodeCount forKey:WM_NODE_COUNT_KEY];
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Setting total node count to file: %@", nodeCount);
    [defaults synchronize];
}

- (NSNumber *)totalNodeCountFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Getting total node count from file: %@", [defaults objectForKey:WM_NODE_COUNT_KEY]);
    return [defaults objectForKey:WM_NODE_COUNT_KEY];
}

-(void)notifyDelegateMarkedNodeCount
{
    if (self.totalNodeCount && self.unknownNodeCount) {
        NSNumber *nodeCount = [NSNumber numberWithDouble:[self.totalNodeCount doubleValue] - [self.unknownNodeCount doubleValue]];
        
        [self writeNodeCountToUserDefaults];
        
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
    NSArray* categories = [self managedObjectContext:context fetchObjectsOfEntity:@"WMCategory" withPredicate:nil];
    
    return [categories sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        WMCategory *c1 = (WMCategory*)a;
        WMCategory *c2 = (WMCategory*)b;
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
        //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WMDataModel" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [self managedObjectModel];//[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
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
            // ... we ignore the error, and if the file already exists but is not compatible, we try to replace it with a new store file
            if ([[NSFileManager defaultManager] fileExistsAtPath:persistentStoreURL.path]) {
                
                // get metadata of existing store
                NSDictionary *metaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:persistentStoreURL error:NULL];
                
                // if meta data can't be read or model is not compatible
                if (!metaData || ![managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:metaData]) {
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
            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"cannot add persistent store, aborting");
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

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return __managedObjectModel;
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
	if (K_USE_ETAGS == YES) {
		NSDictionary *metaData = [self.mainMOC.persistentStoreCoordinator metadataForPersistentStore:self.persistentStore];
		NSDictionary *eTags = metaData[K_DATA_KEY_ETAGS];
		return eTags[entityName];
	} else {
		return @"";
	}
}

- (void) setETag:(NSString*)eTag forEntity:(NSString*)entityName
{
    NSParameterAssert(entityName);
    
    [self.mainMOC performBlock:^{
        
        // get meta data from persistent store
        NSMutableDictionary *metaData = [[self.mainMOC.persistentStoreCoordinator metadataForPersistentStore:self.persistentStore] mutableCopy];
        
        // create eTags dictionary if necessary
        NSMutableDictionary *eTags = [[metaData objectForKey:K_DATA_KEY_ETAGS] mutableCopy] ?: [NSMutableDictionary dictionary];
        
        // use entity name as key of eTag
        if (eTag) {
            eTags[entityName] = eTag;
            
        } else {
            // remove key if eTag is nil
            [eTags removeObjectForKey:entityName];
        }
        
        // save new eTags dictionary in meta data
        [metaData setObject:eTags forKey:K_DATA_KEY_ETAGS];
        
        // save altered meta data to persistent store
        [self.mainMOC.persistentStoreCoordinator setMetadata:metaData forPersistentStore:self.persistentStore];
        
        NSError *error = nil;
        if (![self.mainMOC save:&error]) {
            [self logValidationError:error];
        } else {
            DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Context saved");
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
    DKLog((K_VERBOSE_DATA_MANAGER_LEVEL >= K_VERBOSE_LOG_LEVEL_ONE), @"Error: %@.%@ couldn't be validated. Validation error keys: %@", entityName, object_id, validationErrorKey);
}

#pragma mark - Filter settings

#pragma mark - POI State Filter - Save

- (void)savePOIWheelchairStateFilterSettingsWithYes:(BOOL)yesSelected limited:(BOOL)limitedSelected no:(BOOL)noSelected unknown:(BOOL)unknownSelected {
    [NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithBool:yesSelected] forKey:K_UD_POI_WHEELCHAIR_STATE_YES_KEY];
    [NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithBool:limitedSelected] forKey:K_UD_POI_WHEELCHAIR_STATE_LIMITED_KEY];
    [NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithBool:noSelected] forKey:K_UD_POI_WHEELCHAIR_STATE_NO_KEY];
    [NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithBool:unknownSelected] forKey:K_UD_POI_WHEELCHAIR_STATE_UNKNOWN_KEY];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)savePOIToiletStateFilterSettingsWithYes:(BOOL)yesSelected no:(BOOL)noSelected unknown:(BOOL)unknownSelected {
	[NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithBool:yesSelected] forKey:K_UD_POI_TOILET_STATE_YES_KEY];
	[NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithBool:noSelected] forKey:K_UD_POI_TOILET_STATE_NO_KEY];
	[NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithBool:unknownSelected] forKey:K_UD_POI_TOILET_STATE_UNKNOWN_KEY];
	[NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark - POI State Filter - Getter

- (BOOL)getPOIStateYesFilterStatus:(WMPOIStateType)stateType {
	NSString *userDefaultsKey;
	if (stateType == WMPOIStateTypeWheelchair) {
		userDefaultsKey = K_UD_POI_WHEELCHAIR_STATE_YES_KEY;
	} else {
		userDefaultsKey = K_UD_POI_TOILET_STATE_YES_KEY;
	}
	return [self getPOIStateFilterStatusForKey:userDefaultsKey];
}

- (BOOL)getPOIStateLimitedFilterStatus:(WMPOIStateType)stateType {
	NSString *userDefaultsKey;
	if (stateType == WMPOIStateTypeWheelchair) {
		userDefaultsKey = K_UD_POI_WHEELCHAIR_STATE_LIMITED_KEY;
	} else {
		userDefaultsKey = K_UD_POI_TOILET_STATE_LIMITED_KEY;
	}
	return [self getPOIStateFilterStatusForKey:userDefaultsKey];
}

- (BOOL)getPOIStateNoFilterStatus:(WMPOIStateType)stateType {
	NSString *userDefaultsKey;
	if (stateType == WMPOIStateTypeWheelchair) {
		userDefaultsKey = K_UD_POI_WHEELCHAIR_STATE_NO_KEY;
	} else {
		userDefaultsKey = K_UD_POI_TOILET_STATE_NO_KEY;
	}
	return [self getPOIStateFilterStatusForKey:userDefaultsKey];
}

- (BOOL)getPOIStateUnkownFilterStatus:(WMPOIStateType)stateType {
	NSString *userDefaultsKey;
	if (stateType == WMPOIStateTypeWheelchair) {
		userDefaultsKey = K_UD_POI_WHEELCHAIR_STATE_UNKNOWN_KEY;
	} else {
		userDefaultsKey = K_UD_POI_TOILET_STATE_UNKNOWN_KEY;
	}
	return [self getPOIStateFilterStatusForKey:userDefaultsKey];
}

- (BOOL)getPOIStateFilterStatusForKey:(NSString *)key {
	if ([NSUserDefaults.standardUserDefaults valueForKey:key] == nil) {
		return YES;
	}
	return [[NSUserDefaults.standardUserDefaults valueForKey:key] boolValue];
}

@end

NSString *WMDataManagerErrorDomain = @"WMDataManagerErrorDomain";




