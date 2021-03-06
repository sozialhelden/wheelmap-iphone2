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
- (void)pressedBackButton:(WMNavigationBar*)navigationBar;
- (void)pressedDashboardButton:(WMNavigationBar*)navigationBar;
- (void)pressedEditButton:(WMNavigationBar*)navigationBar;
- (void)pressedCancelButton:(WMNavigationBar*)navigationBar;
- (void)pressedSaveButton:(WMNavigationBar*)navigationBar;
- (void)pressedSearchCancelButton:(WMNavigationBar *)navigationBar;
- (void)pressedSearchButton:(BOOL)selected;
- (void)searchStringIsGiven:(NSString*)query;
@optional
- (void)pressedCreatePOIButton:(WMNavigationBar*)navigationBar;
@end

@protocol WMEditPOIStateDelegate <NSObject>
- (void)didSelectStatus:(NSString *)state forStatusType:(WMPOIStateType)statusType;
@end

@protocol WMEditPOIStateButtonViewDelegate <NSObject>
- (void)didSelectStatus:(NSString *)state;
@end

@protocol WMPOIStateButtonViewDelegate <NSObject>
- (void)didPressedEditStateButton:(NSString *)state forStateType:(WMPOIStateType)stateType;
@end

@protocol WMPOIStateFilterButtonViewDelegate <NSObject>
- (void)didPressPOIStateFilterButtonForStateType:(WMPOIStateType)stateType;
@end

@protocol WMPOIStateFilterPopoverViewDelegate <NSObject>
- (void)didSelect:(BOOL)selected dot:(DotType)dotType forStateType:(WMPOIStateType)stateType;
@end

@class WMToolbar;
@protocol WMToolbarDelegate <NSObject>
@required
- (void)pressedMapListToggleButton:(WMToolbar*)toolBar;
- (void)pressedCurrentLocationButton:(WMToolbar*)toolBar;
- (void)pressedSearchButton:(BOOL)selected;
- (void)pressedWheelchairStateFilterButton:(WMToolbar*)toolBar sourceView:(UIView *)view;
- (void)pressedToiletStateFilterButton:(WMToolbar*)toolBar sourceView:(UIView *)view;
- (void)pressedCategoryFilterButton:(WMToolbar*)toolBar sourceView:(UIView *)view;
@optional
- (void)pressedLoginButton:(WMToolbar*)toolBar;
- (void)pressedCreditsButton:(WMToolbar*)toolBar;
- (void)pressedContributeButton:(WMToolbar*)toolBar;
@end

@protocol WMSmallGalleryButtonCollectionViewCellDelegate <NSObject>
- (void)didPressCameraButton;
@end

#endif