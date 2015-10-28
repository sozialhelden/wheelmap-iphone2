//
//  WMResourceManager.m
//  Wheelmap
//
//  Created by Taehun Kim on 3/6/13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMResourceManager.h"

@implementation WMResourceManager


+(WMResourceManager*)sharedManager
{
    static WMResourceManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            _sharedManager = [[WMResourceManager alloc] init];
    });
    
    return _sharedManager;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *rootPath = [paths objectAtIndex:0];
        self.iconImageRootPath = [NSString stringWithFormat:@"%@/icons/", rootPath];
        self.iconFactory = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}
- (UIImage*)iconForName:(NSString*)iconName{
    UIImage * retImage = [self.iconFactory objectForKey:iconName];
    
    if (!retImage) {
        retImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",self.iconImageRootPath, iconName]];
        [self setIcon:retImage withIconName:iconName];
    }
    
    return retImage;
}

- (void)setIcon:(UIImage*)image withIconName:(NSString*)iconName
{
    if (image) {
        [self.iconFactory setObject:image forKey:iconName];
    }
}

@end
