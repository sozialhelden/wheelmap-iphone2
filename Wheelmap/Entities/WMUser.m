//
//  WMUser.m
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMUser.h"
#import "WMWheelmapAPI.h"

@implementation WMUser

- (void)loginWithUsername:(NSString *)name andPassword:(NSString *)password {
    [self sendLoginRequestWithUsername:name andPassword:password];
}

- (void)sendLoginRequestWithUsername:(NSString *)name andPassword:(NSString *)password {
    
    [[WMWheelmapAPI sharedInstance] requestLoginWithUsername:name
                                                    password:password
                                                       error:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               NSLog(@"... login error: %d %@", response.statusCode, error.localizedDescription);
                                                           });
                                                       }
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             NSLog(@"... login success %d", response.statusCode);
                                                         });
                                                     }];
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
