//
//  WMDataManager.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WMDataManagerDelegate.h"
#import "SSZipArchive.h"
#import "Reachability.h"

@class Node;

@interface WMDataManager : NSObject<SSZipArchiveDelegate>

@property (nonatomic, weak) id<WMDataManagerDelegate> delegate;

/*
 * useForTemporaryObjects must be turned on when the data manager is used in 
 * VCs which create and submit a new node. The new node will have a temporary
 * context. CreateNode will throw an exception if this is not set to YES. 
 * If set, categories and nodeTypes will return objects fetched from  
 * the temporary context to be able to assign them to the new node.
 * All other operations will still use the main context.
 */
@property (nonatomic) BOOL useForTemporaryObjects;
@property (nonatomic, readonly) BOOL syncInProgress;
@property (nonatomic, strong) NSString *iconImageRootPath;

- (void) authenticateUserWithEmail:(NSString*)email password:(NSString*)password;
- (void) updateTermsAccepted:(BOOL)accepted;
- (void) removeUserAuthentication;
- (BOOL) userIsAuthenticated;
- (BOOL)areUserTermsAccepted;
- (void)userDidAcceptTerms;
- (void)userDidNotAcceptTerms;
- (BOOL)isFirstLaunch;
- (void)firstLaunchOccurred;

- (NSDictionary*) legacyUserCredentials;
- (NSString*)currentUserName;

- (NSArray*) fetchNodesNear:(CLLocationCoordinate2D)location;
- (void) fetchNodesWithQuery:(NSString*)query;
- (NSArray*) fetchNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest
                          northeast:(CLLocationCoordinate2D)northeast
                              query:(NSString*)query;

- (void) syncResources;
- (void) updateWheelchairStatusOfNode:(Node*)node;
- (void) updateNode:(Node*)node;

- (void) fetchPhotosForNode:(Node*)node;
- (void) uploadImage:(UIImage*)image forNode:(Node*)node;

- (void) fetchTotalNodeCount;
- (NSNumber *)totalNodeCountFromUserDefaults;

- (NSArray*) categories;
- (NSArray*) nodeTypes;

- (BOOL)isInternetConnectionAvailable;
- (Reachability*) internetReachble;

- (void)saveNewFilterSettingsWithGreen:(BOOL)greenSelected yellow:(BOOL)yellowSelected red:(BOOL)redSelected none:(BOOL)noneSelected;
- (BOOL)getGreenFilterStatus;
- (BOOL)getYellowFilterStatus;
- (BOOL)getRedFilterStatus;
- (BOOL)getNoneFilterStatus;

/* Returns a node in the temporary context. It serves only to pass node data to
 * updateNode: The context should not be saved. Throws an exception if 
 * useForTemporaryObjects is not set
 */
- (Node*) createNode;

- (void) cleanUpCache;


extern NSString *WMDataManagerErrorDomain;

enum {
    WMDataManagerManagedObjectCreationError,
    WMDataManagerInvalidUserKeyError,
    WMDataManagerInvalidRemoteDataError
};

@end
