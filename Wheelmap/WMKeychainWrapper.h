//
//  EFBKeychainWrapper.h
//  EFB
//
//  Created by Dorian Roy on 10.07.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//


@interface WMKeychainWrapper : NSObject

- (NSString*) userAccount;
- (NSString*) tokenForAccount:(NSString*)account;
- (BOOL) saveToken:(NSString*)token forAccount:(NSString*)account;
- (BOOL) deleteTokenForAccount:(NSString*)account;
- (NSDictionary*) legacyAccountData;
- (BOOL) deleteLegacyAccountData;

@end
