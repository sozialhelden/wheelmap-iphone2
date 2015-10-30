//
//  WMProtocols.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#ifndef Wheelmap_WMProtocols_h
#define Wheelmap_WMProtocols_h

@class CLLocation, Node;

@protocol WMPOIsListViewDelegate;

@protocol WMPOIsListDataSourceDelegate <NSObject>
- (NSArray*) nodeList;
- (NSArray*)filteredNodeListForUseCase:(WMPOIsListViewControllerUseCase)useCase;
@end

@protocol WMPOIsListDelegate <NSObject>
- (void) nodeListView:(id<WMPOIsListViewDelegate>)nodeListView didSelectDetailsForNode:(Node*)node;
@optional
- (void)nodeListView:(id<WMPOIsListViewDelegate>)nodeListView didSelectNode:(Node*)node;
- (void)updateUserLocation;
- (CLLocationCoordinate2D)currentUserLocation;
@end

@protocol WMPOIsListViewDelegate <NSObject>
@property (nonatomic, weak) IBOutlet id<WMPOIsListDataSourceDelegate> dataSource;
@property (nonatomic, weak) IBOutlet id<WMPOIsListDelegate> delegate;
- (void) nodeListDidChange;
- (void) selectNode:(Node*)node;
@optional
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
@end

@class WMNavigationBar;

@protocol WMNavigationBarDelegate <NSObject>
@required
-(void)pressedBackButton:(WMNavigationBar*)navigationBar;
-(void)pressedDashboardButton:(WMNavigationBar*)navigationBar;
-(void)pressedEditButton:(WMNavigationBar*)navigationBar;
-(void)pressedCancelButton:(WMNavigationBar*)navigationBar;
-(void)pressedSaveButton:(WMNavigationBar*)navigationBar;
-(void)pressedContributeButton:(WMNavigationBar*)navigationBar;
-(void)pressedSearchCancelButton:(WMNavigationBar *)navigationBar;
-(void)pressedSearchButton:(BOOL)selected;
-(void)searchStringIsGiven:(NSString*)query;
@end

#endif