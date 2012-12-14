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

@optional
- (void) dataManagerDidAuthenticateUser:(WMDataManager*)dataManager;
- (void) dataManager:(WMDataManager*)dataManager userAuthenticationFailedWithError:(NSError*)error;

- (void) dataManager:(WMDataManager*)dataManager didReceiveNodes:(NSArray*)nodes;
- (void) dataManager:(WMDataManager*)dataManager fetchNodesFailedWithError:(NSError*)error;

- (void) dataManagerDidFinishSyncingResources:(WMDataManager*)dataManager;
- (void) dataManager:(WMDataManager*)dataManager didFinishSyncingResourcesWithErrors:(NSArray*)errors;

- (void) dataManager:(WMDataManager*)dataManager didReceiveSearchResults:(NSArray*)results;
- (void) dataManager:(WMDataManager*)dataManager searchFailedWithError:(NSError*)error;

- (void) dataManager:(WMDataManager *)dataManager didFinishPuttingWheelChairStatusWithMsg:(NSString*)msg;
- (void) dataManager:(WMDataManager *)dataManager failedPuttingWheelChairStatusWithError:(NSError *)error;

- (void) dataManager:(WMDataManager *)dataManager didFinishPuttingNodeWithMsg:(NSString*)msg;
- (void) dataManager:(WMDataManager *)dataManager failedPuttingNodeWithError:(NSError *)error;

- (void) dataManager:(WMDataManager *)dataManager didFinishPostingNodeWithMsg:(NSString*)msg;
- (void) dataManager:(WMDataManager *)dataManager failedPostingNodeWithError:(NSError *)error;

- (void) dataManager:(WMDataManager *)dataManager didFinishPostingImageWithMsg:(NSString*)msg;
- (void) dataManager:(WMDataManager *)dataManager failedPostingImageWithError:(NSError *)error;
@end
