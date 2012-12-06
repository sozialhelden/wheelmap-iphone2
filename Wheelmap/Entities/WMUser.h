//
//  WMUser.h
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMUser : NSObject

@property (nonatomic, strong) NSString *apiKey; // the api-key for the logged in user
@property (nonatomic) BOOL isLoggedIn; // indicates whether the current user is logged in

- (void)loginWithUsername:(NSString *)name andPassword:(NSString *)password;

+ (WMUser *)sharedUser;

@end
