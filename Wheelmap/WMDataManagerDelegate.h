//
//  WMDataManagerDelegate.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMDataManager, Node;

@protocol WMDataManagerDelegate <NSObject>

@optional

- (void) dataManagerDidStartOperation:(WMDataManager*)dataManager;
- (void) dataManagerDidStopAllOperations:(WMDataManager*)dataManager;

- (void) dataManagerDidAuthenticateUser:(WMDataManager*)dataManager;
- (void) dataManager:(WMDataManager*)dataManager userAuthenticationFailedWithError:(NSError*)error;

- (void) dataManagerDidUpdateTermsAccepted:(WMDataManager*)dataManager;
- (void) dataManager:(WMDataManager *)dataManager updateTermsAcceptedFailedWithError:(NSError *)error;

- (void) dataManager:(WMDataManager*)dataManager didReceiveNodes:(NSArray*)nodes;
- (void) dataManager:(WMDataManager*)dataManager fetchNodesFailedWithError:(NSError*)error;

- (void) dataManagerDidFinishSyncingResources:(WMDataManager*)dataManager;
- (void) dataManager:(WMDataManager*)dataManager didFinishSyncingResourcesWithErrors:(NSArray*)errors;

- (void) dataManager:(WMDataManager *)dataManager didUpdateWheelchairStatusOfNode:(Node *)node;
- (void) dataManager:(WMDataManager *)dataManager updateWheelchairStatusOfNode:(Node *)node failedWithError:(NSError *)error;

- (void) dataManager:(WMDataManager *)dataManager didUpdateNode:(Node *)node;
- (void) dataManager:(WMDataManager *)dataManager updateNode:(Node *)node failedWithError:(NSError *)error;

- (void) dataManager:(WMDataManager *)dataManager didReceivePhotosForNode:(Node *)node;
- (void) dataManager:(WMDataManager *)dataManager fetchPhotosForNode:(Node *)node failedWithError:(NSError*)error;

- (void) dataManager:(WMDataManager *)dataManager didUploadImageForNode:(Node *)node;
- (void) dataManager:(WMDataManager *)dataManager uploadImageForNode:(Node *)node failedWithError:(NSError *)error;

- (void) dataManager:(WMDataManager *)dataManager didReceiveTotalNodeCount:(NSNumber*)count;
- (void) dataManager:(WMDataManager *)dataManager fetchTotalNodeCountFailedWithError:(NSError*)error;

@end
