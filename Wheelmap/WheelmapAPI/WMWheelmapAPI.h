//
//  WMWheelmapAPI.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMWheelmapAPIRequest;

@interface WMWheelmapAPI : NSObject

@property (nonatomic) NSString* userId;
@property (nonatomic) NSString* userAPIKey;

- (WMWheelmapAPIRequest*) requestResource:(NSString *)resource
                               parameters:(NSDictionary *)parameters
                                     eTag:(NSString *)eTag
                                     data:(id)data
                                   method:(NSString *)method
                                    error:(void(^)(NSError*))errorBlock
                                  success:(void(^)(id, NSString*))successBlock;

@end
