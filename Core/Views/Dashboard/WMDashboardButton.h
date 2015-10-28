//
//  WMDashboardButton.h
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

typedef enum {
    
    WMDashboardButtonTypeNearby,
    WMDashboardButtonTypeMap,
    WMDashboardButtonTypeCategories,
    WMDashboardButtonTypeHelp
    
} WMDashboardButtonType;

@interface WMDashboardButton : WMButton

- (id)initWithFrame:(CGRect)frame andType:(WMDashboardButtonType)type;

@end
