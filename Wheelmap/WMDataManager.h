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
#import <CoreData/CoreData.h>

@class Node;

@interface WMDataManager : NSObject<SSZipArchiveDelegate>

@property (nonatomic, weak) id<WMDataManagerDelegate> delegate;

- (void) authenticateUserWithEmail:(NSString*)email password:(NSString*)password;
- (void) removeUserAuthentication;
- (BOOL) userIsAuthenticated;
- (NSDictionary*) legacyUserCredentials;
- (NSString*)currentUserName;

- (void) fetchNodesNear:(CLLocationCoordinate2D)location;
- (void) fetchNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest northeast:(CLLocationCoordinate2D)northeast;
- (void) fetchNodesWithQuery:(NSString*)query;
- (void) fetchPhotoURLsOfNode:(Node*)node;

- (void) syncResources;

- (NSArray*) categories;
- (NSArray*) nodeTypes;

- (void) searchFor:(NSString*)query;

- (Node*) createNode;
- (Node*) updateNode:(Node*)node withPhotoArray:(NSArray*)photoArray;

- (void) putNode:(Node*)node;
- (void) putWheelChairStatusForNode:(Node*)node;    // the node should already have the changed status!
- (void) postNode:(Node*)node;

- (void) uploadImage:(UIImage*)image forNode:(Node*)node;

extern NSString *WMDataManagerErrorDomain;

enum {
    WMDataManagerManagedObjectCreationError,
    WMDataManagerInvalidUserKeyError
};

@end
