//
//  WMWheelmapAPI.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMWheelmapAPI : NSObject

@property (nonatomic) NSString* userId;
@property (nonatomic) NSString* userAPIKey;

- (NSOperation*) requestResource:(NSString *)resource
                                 parameters:(NSDictionary *)parameters
                                       eTag:(NSString *)eTag
                                       data:(id)data
                                     method:(NSString *)method
                                      error:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))errorBlock
                                    success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))successBlock
                           startImmediately:(BOOL)startImmediately;

@end
