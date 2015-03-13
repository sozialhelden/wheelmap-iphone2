//
//  Facebook+Singleton.m
//
//  Created by Barry Murphy on 7/25/11.
//
//  If you use this software in your project, a credit for Barry Murphy
//  and a link to http://barrycenter.com would be appreciated.
//
//  --------------------------------
//  Simplified BSD License (FreeBSD)
//  --------------------------------
//
//  Copyright 2011 Barry Murphy. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//     conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//     of conditions and the following disclaimer in the documentation and/or other materials
//     provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY BARRY MURPHY "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BARRY MURPHY OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Barry Murphy.
//

#import "Facebook+Singleton.h"

@interface Facebook (SingletonPrivate)
- (void)authorize:(NSArray *)permissions localAppId:(NSString *)localAppId;
- (void)authorizeInApp:(NSArray *)permissions localAppId:(NSString *)localAppId;
- (void)authorizeWithFacebookApp:(NSArray *)permissions localAppId:(NSString *)localAppId;
- (void)authorizeWithFBAppAuth:(BOOL)tryFBAppAuth safariAuth:(BOOL)trySafariAuth;
@end

@implementation Facebook (Singleton)

- (id)init {
    if ((self = [super init])) {
        [self initWithAppId:@"289221174426029" andDelegate:self];
        [self authorize];
    }
    return self;
}

- (void)authorize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kFBAccessTokenKey] && [defaults objectForKey:kFBExpirationDateKey]) {
        self.accessToken = [defaults objectForKey:kFBAccessTokenKey];
        self.expirationDate = [defaults objectForKey:kFBExpirationDateKey];
    }
    
    if (![self isSessionValid]) {
        //
        // Only ONE of the following authorize methods should be uncommented.
        //
        
        // This is the method Facebook wants users to use. 
        // It will leave your app and authoize through the Facebook app or Safari.
        //[self authorize:nil localAppId:@"299780320089682"];
        
        // This will authorize from within your app.
        // It will not leave your app nor take advantage of the user logged in elsewhere.
        [self authorizeInApp:nil localAppId:@"289221174426029"];
        
        // This will only leave your app if the user has the Facebook app.
        // Otherwise it will stay within your app.
        //[self authorizeWithFacebookApp:nil localAppId:nil];
    }
}

- (void)authorize:(NSArray *)permissions localAppId:(NSString *)localAppId {
   // self.localAppId = localAppId;
    
    _appId = localAppId;
    _permissions = permissions;
    _sessionDelegate = self;
    
    [self authorizeWithFBAppAuth:YES safariAuth:YES];
}

- (void)authorizeInApp:(NSArray *)permissions localAppId:(NSString *)localAppId {
    //self.localAppId = localAppId;
    _appId = localAppId;
    _permissions = permissions;
    _sessionDelegate = self;
    
    [self authorizeWithFBAppAuth:NO safariAuth:NO];
}

- (void)authorizeWithFacebookApp:(NSArray *)permissions localAppId:(NSString *)localAppId {
    //self.localAppId = localAppId;
    _appId = localAppId;
    _permissions = permissions;
    _sessionDelegate = self;
    
    [self authorizeWithFBAppAuth:YES safariAuth:NO];
}

- (void)logout {
    [self logout:self];
}

#pragma - FBSessionDelegate Methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self accessToken] forKey:kFBAccessTokenKey];
    [defaults setObject:[self expirationDate] forKey:kFBExpirationDateKey];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FBDidLogin" object:self];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FBLoginCancelled" object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FBLoginFailed" object:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FBDidNotLogin" object:self];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kFBAccessTokenKey];
    [defaults removeObjectForKey:kFBExpirationDateKey];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FBDidLogout" object:self];
}

#pragma mark - Singleton Methods

static Facebook *shared = nil;

+ (Facebook *)shared {
    @synchronized(self) {
        if(shared == nil) {
            [[self alloc] init];
        } else {
            if (![shared isSessionValid]) {
                [shared authorize];
            }
        }
    }
        
    return shared;
}
    
+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if(shared == nil)  {
			shared = [super allocWithZone:zone];
			return shared;
		}
	}
	return nil;
}
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
- (id)retain {
	return self;
}
- (unsigned)retainCount {
	return UINT_MAX; //denotes an object that cannot be released
}
- (void)release {
	// never release
}
- (id)autorelease {
	return self;
}

- (void)fbSessionInvalidated {
    
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    
}

@end
