//
//  WMNavigationBarDelegate.h
//  Wheelmap
//
//  Created by npng on 12/4/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMNavigationBar;

@protocol WMNavigationBarDelegate <NSObject>
@required
-(void)pressedBackButton:(WMNavigationBar*)navigationBar;
-(void)pressedDashboardButton:(WMNavigationBar*)navigationBar;
-(void)pressedEditButton:(WMNavigationBar*)navigationBar;
-(void)pressedCancelButton:(WMNavigationBar*)navigationBar;
-(void)pressedSaveButton:(WMNavigationBar*)navigationBar;
-(void)pressedContributeButton:(WMNavigationBar*)navigationBar;

-(void)searchStringIsGiven:(NSString*)query;

@end
