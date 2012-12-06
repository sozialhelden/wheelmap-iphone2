//
//  WMUser.m
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMUser.h"

@implementation WMUser

- (void)loginWithUsername:(NSString *)name andPassword:(NSString *)password {
    [self sendLoginRequestWithUsername:name andPassword:password];
}

- (void)sendLoginRequestWithUsername:(NSString *)name andPassword:(NSString *)password {
    // TODO: implement real api call
    self.isLoggedIn = YES;
    self.apiKey = @"12345";
}

+ (WMUser *)sharedUser {
    static WMUser *sharedInstance;
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[WMUser alloc] init];
        }
        return sharedInstance;
    }
}

@end
