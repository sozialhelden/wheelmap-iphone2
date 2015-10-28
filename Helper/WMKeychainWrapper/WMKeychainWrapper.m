//
//  EFBKeychainWrapper.m
//  EFB
//
//  Created by Dorian Roy on 10.07.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMKeychainWrapper.h"

#ifdef ALPHA
    #define WMKeychainServiceName @"Wheelmap iOS ALPHA"
#elif BETA
    #define WMKeychainServiceName @"Wheelmap iOS BETA"
#else
    #define WMKeychainServiceName @"Wheelmap iOS"
#endif
#define WMLegacyKeychainServiceName @"Wheelmap"

@implementation WMKeychainWrapper

/*
 Returns the name (email address) of the first account found for this app
 */
- (NSString *) userAccount
{
    return [self accountForService:WMKeychainServiceName];
}

/*
 Returns the first token found for the account. If no account is provided, returns the 
 first token found for this app.
 */
- (NSString*) tokenForAccount:(NSString*)account
{  
    return [self passwordForService:WMKeychainServiceName account:account];
}

/*
 Saves a token for the account. If a token already exists, it will be updated.
 */
- (BOOL) saveToken:(NSString*)token forAccount:(NSString*)account
{
    NSParameterAssert(token);
    NSParameterAssert(account);
    
    // create data object from token string
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    
    // prepare query
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrService, (CFStringRef)WMKeychainServiceName);
    CFDictionaryAddValue(query, kSecAttrAccount, (CFStringRef)account);
    
    // check if a token already exists
    OSStatus status;
    if ([self tokenForAccount:account]) {
        // update token
        CFMutableDictionaryRef attributes = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(attributes, kSecValueData, (CFDataRef)tokenData);
        status = SecItemUpdate(query, attributes);
        
    } else {
        // save token
        CFDictionaryAddValue(query, kSecValueData, (CFDataRef)tokenData);
        status = SecItemAdd(query, NULL);
    }
    CFBridgingRelease(query);
  
    return status == noErr;
}

/*
 Deletes all keychain items for this app. If an account is provided, only items that matches
 this account will be deleted.
 */
- (BOOL) deleteTokenForAccount:(NSString *)account
{
    return [self deleteCredentialsForService:WMKeychainServiceName account:account];
}

/*
 Returns a dictionary with password and email of the account saved by legacy versions
 of this app (< v2.0)
 */
- (NSDictionary*) legacyAccountData
{
    NSString *legacyPassword = [self passwordForService:WMLegacyKeychainServiceName account:nil];
    NSString *legacyAccount = [self accountForService:WMLegacyKeychainServiceName];
    
    if (legacyAccount || legacyPassword) {
        return @{@"password":legacyPassword?:[NSNull null], @"email":legacyAccount?:[NSNull null]};
    }
    
    return nil;
}

/*
 Deletes all keychain data saved by legacy versions of this app (< v2.0)
 */
- (BOOL) deleteLegacyAccountData
{
    return [self deleteCredentialsForService:WMLegacyKeychainServiceName account:nil];
}



/*
 Returns the first password that matches the account parameter. If no account is provided, the first password
 found for the service will be returned.
 */
- (NSString*) passwordForService:(NSString*)service account:(NSString*)account
{
    NSParameterAssert(service);
    
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrService, (CFStringRef)service);
    CFDictionaryAddValue(query, kSecReturnData, kCFBooleanTrue);
    if (account) CFDictionaryAddValue(query, kSecAttrAccount, (CFStringRef)account);
    
    CFDataRef result = NULL;
    OSStatus status = SecItemCopyMatching(query, (CFTypeRef *)&result);
    if(status == errSecItemNotFound) {
        CFBridgingRelease(query);
        return nil;
    }
    CFBridgingRelease(query);

    NSString *password = [[NSString alloc] initWithData:CFBridgingRelease(result) encoding: NSUTF8StringEncoding];
    return password;
}

/*
 Returns the name of the first account found for the service
 */
- (NSString*) accountForService:(NSString*)service
{
    NSParameterAssert(service);
    
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrService, (CFStringRef)service);
    CFDictionaryAddValue(query, kSecReturnAttributes, kCFBooleanTrue);
    
    CFDictionaryRef result = NULL;
    OSStatus status = SecItemCopyMatching(query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound) {
        CFBridgingRelease(query);
        return nil;
    }
    CFBridgingRelease(query);
    
    NSDictionary *dict = (__bridge_transfer NSDictionary *)result;
    NSString *account = dict[(__bridge_transfer NSString*)kSecAttrAccount];
    return account;
}

/*
 If no account is provided, this method deletes all keychain items for the service. If an account is provided, 
 deletes only items that matches that account.
 */
- (BOOL) deleteCredentialsForService:(NSString*)service account:(NSString*)account
{
    CFMutableDictionaryRef query = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(query, kSecAttrService, (CFStringRef)service);
    if (account) CFDictionaryAddValue(query, kSecAttrAccount, (CFStringRef)account);
    
    OSStatus status = SecItemDelete(query);
    CFBridgingRelease(query);
    
    return status == noErr;
}


@end


