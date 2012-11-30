//
//  WMDataManagerDelegate.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMDataManager;

@protocol WMDataManagerDelegate <NSObject>

- (void) dataManager:(WMDataManager*)dataManager didReceiveNodes:(NSArray*)nodes;
- (void) dataManager:(WMDataManager*)dataManager fetchNodesFailedWithError:(NSError*)error;
- (void) dataManagerDidFinishSyncingResources:(WMDataManager*)dataManager;
- (void) dataManager:(WMDataManager*)dataManager syncResourcesFailedWithError:(NSError*)error;
- (void) dataManager:(WMDataManager*)dataManager didReceiveSearchResults:(NSArray*)results;
- (void) dataManager:(WMDataManager*)dataManager searchFailedWithError:(NSError*)error;

@end
