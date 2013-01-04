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

@class Node;

@interface WMDataManager : NSObject<SSZipArchiveDelegate>

@property (nonatomic, weak) id<WMDataManagerDelegate> delegate;

@property (nonatomic, readonly) BOOL syncInProgress;

- (void) authenticateUserWithEmail:(NSString*)email password:(NSString*)password;
- (void) removeUserAuthentication;
- (BOOL) userIsAuthenticated;
- (NSDictionary*) legacyUserCredentials;
- (NSString*)currentUserName;

- (void) fetchNodesNear:(CLLocationCoordinate2D)location;
- (void) fetchNodesWithQuery:(NSString*)query;
- (void) fetchNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest
                          northeast:(CLLocationCoordinate2D)northeast
                              query:(NSString*)query;

- (void) syncResources;

- (void) updateWheelchairStatusOfNode:(Node*)node;
- (void) updateNode:(Node*)node;

- (void) fetchPhotosForNode:(Node*)node;
- (void) uploadImage:(UIImage*)image forNode:(Node*)node;

- (void) fetchTotalNodeCount;

- (NSArray*) categories;
- (NSArray*) nodeTypes;

- (Node*) createNode;
- (void) deleteNode:(Node*)node;


extern NSString *WMDataManagerErrorDomain;

enum {
    WMDataManagerManagedObjectCreationError,
    WMDataManagerInvalidUserKeyError,
    WMDataManagerInvalidRemoteDataError
};

@end
