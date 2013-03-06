//
//  WMResourceManager.h
//  Wheelmap
//
//  Created by Taehun Kim on 3/6/13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMResourceManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *iconFactory;
@property (nonatomic, strong) NSString *iconImageRootPath;

+ (WMResourceManager *)sharedManager;

- (UIImage*)iconForName:(NSString*)iconName;
- (void)setIcon:(UIImage*)image withIconName:(NSString*)iconName;
@end
